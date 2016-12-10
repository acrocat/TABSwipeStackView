//
//  TABswipeStackView.swift
//  TABswipeStackView
//
//  Created by Dale Webster on 05/12/2016.
//  Copyright © 2016 TabApps. All rights reserved.
//

import UIKit

@objc public protocol TABSwipeStackViewDataSource
{
    @objc func swipeStackView (_ swipeStackView : TABSwipeStackView , bufferViewForIndex index : Int) -> UIView?
}

@objc public protocol TABSwipeStackViewDelegate
{
    @objc optional func swipeStackView (_ swipeStackView : TABSwipeStackView , pannedView view : UIView , atIndex index : Int , inDirection direction : TABSwipeStackViewSwipeDirection)
    @objc optional func swipeStackView (_ swipeStackView : TABSwipeStackView , cancelledPanningOnView view : UIView , atIndex index : Int , inDirection direction : TABSwipeStackViewSwipeDirection)
    @objc optional func swipeStackView (_ swipeStackView : TABSwipeStackView , dismissedView view : UIView , atIndex index : Int , inDirection direction : TABSwipeStackViewSwipeDirection)
    @objc optional func reachedEndOfBufferInSwipeStackView (_ swipStackView : TABSwipeStackView)
}

@objc public protocol TABSwipeStackViewDelegateAnimator
{
    @objc optional func swipeStackView (_ swipeStackView : TABSwipeStackView , transformationsForSurfaceView view : UIView , atKeyframe keyframe : Int)
    @objc optional func swipeStackView (_ swipeStackView : TABSwipeStackView , transformationForSubsequentView view : UIView , atKeyframe keyframe : Int)
}

@objc public enum TABSwipeStackViewSwipeDirection : Int
{
    case left = 0
    case right = 1
}

open class TABSwipeStackView: UIView
{
    // ---------------------------------------------------------------------------
    // MARK: - Class Properties
    // ---------------------------------------------------------------------------
    
    private static let BUFFER_SIZE : Int = 2
    private static let MAX_VIEW_DISPLACEMENT : Int = 100
    private static let DISMISSED_VIEW_DISPLACEMENT : Int = 150
    
    // ---------------------------------------------------------------------------
    // MARK: - Properties
    // ---------------------------------------------------------------------------

    private var _delegate : TABSwipeStackViewDelegate?
    private var _dataSource : TABSwipeStackViewDataSource?
    private var _delegateAnimator : TABSwipeStackViewDelegateAnimator?
    
    public var index : Int = 0
    private let panGesture : UIPanGestureRecognizer = UIPanGestureRecognizer()
    
    private var dismissViewAnimation : TABDismissViewAnimation!
    private var scaleViewAnimation : TABScaleViewAnimation!
    public private(set) var viewBuffer : Array<UIView> = []
    
    // ---------------------------------------------------------------------------
    // MARK: - Getters and Setters
    // ---------------------------------------------------------------------------

    open var delegate : TABSwipeStackViewDelegate? {
        get { return self._delegate }
        set { self._delegate = newValue }
    }
    
    open var dataSource : TABSwipeStackViewDataSource? {
        get { return self._dataSource }
        set {
            self._dataSource = newValue
            
            // Reload data
            self.reloadData()
        }
    }
    
    open var delegateAnimator : TABSwipeStackViewDelegateAnimator? {
        get { return self._delegateAnimator }
        set { self._delegateAnimator = newValue }
    }
    
    // ---------------------------------------------------------------------------
    // MARK: - Init
    // ---------------------------------------------------------------------------

    /**
     Init
     */
    public init ()
    {
        super.init(frame: CGRect.zero)
        
        self.setup()
    }

    /**
     Init with coder
     */
    public required init? (coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        
        self.setup()
    }

    /**
     Config properties
     */
    private func setup ()
    {
        self.addGestureRecognizer(self.panGesture)
        self.panGesture.addTarget(self, action: #selector(TABSwipeStackView.pan))
    }

    /**
     Clear the existing buffer and re populate it by retrieving data from the delegate
     */
    public func reloadData ()
    {
        // Reset the index
        self.index = 0
        
        // Clear the buffer
        self.clearBuffer()
        
        // Repopulate the buffer
        self.bufferViews()
        
        // Now that the views have been buffered, we need to lay them out
        self.layoutSubviews()
    }
    
    /**
     Requests views from the delegate to fill up the buffer
     */
    private func bufferViews ()
    {
        var iterator : Int = self.index + self.viewBuffer.count
        
        while self.viewBuffer.count < TABSwipeStackView.BUFFER_SIZE
        {
            if let view = self.dataSource?.swipeStackView(self, bufferViewForIndex: iterator)
            {
                self.viewBuffer.insert(view, at: 0)
            }
            else
            {
                break
            }
            
            iterator += 1
        }
    }
    
    /**
     Takes the buffer of views and adds them to the superview, and sets their animation properties
     */
    open override func layoutSubviews ()
    {
        super.layoutSubviews()
        
        for (index , view) in self.viewBuffer.enumerated()
        {
            if view.superview == nil
            {
                // Add the view and set frame
                self.insertSubview(view, at: index)
                view.frame = self.bounds
            }
        }
        
        // Create animation for the surface card
        self.setupAnimations()
    }
    
    /**
     A number of animations are used in this view. This method is used to set them up, and reconfigure when the view changes
     */
    private func setupAnimations ()
    {
        // Attach the translate animation to the surface card
        if let surfaceView = self.getSurfaceView()
        {
//            self.dismissViewAnimation = TABDismissViewAnimation(withView: surfaceView)
        }
        
        // Attach a scale animation to the hidden card
        if let upcomingView = self.getSubsequentView()
        {
            self.scaleViewAnimation = TABScaleViewAnimation(withView: upcomingView)
        }
        else
        {
            self.scaleViewAnimation = TABScaleViewAnimation(withView: UIView())
        }
    }

    /**
     * Returns the card that is currently presenting in the window
     *
     * - returns: View on the surface of the stack
     */
    public func getSurfaceView () -> UIView?
    {
        return self.viewBuffer.last
    }

    /**
     Get the card that appears behind the surface card
     */
    public func getSubsequentView () -> UIView?
    {
        return (self.viewBuffer.count > 1) ? self.viewBuffer[self.viewBuffer.count - 2] : nil
    }

    /**
     Move forwards through the stack
     */
    public func cycleForwards (direction : TABSwipeStackViewSwipeDirection)
    {
        if let view = self.getSurfaceView()
        {
            // Reset the view that we just discarded
//            self.dismissViewAnimation.animator.animate(0)
            self.applyKeyframeToSurfaceView(0)
            
            // Remove the view from the superview
            view.removeFromSuperview()
            
            // Remove from the buffer
            self.viewBuffer.remove(at: self.viewBuffer.count - 1)
            
            // Tell the delegate
            self.delegate?.swipeStackView?(self, dismissedView: view, atIndex: self.index, inDirection: direction)
            
            // Increment the index
            self.index += 1
            
            // Refill the buffer and display the views
            self.bufferViews()
            self.layoutSubviews()
            
            // If the view buffer is now empty, we need to tell the delegate that we're out of views
            if self.viewBuffer.isEmpty
            {
                self.delegate?.reachedEndOfBufferInSwipeStackView?(self)
            }
        }
    }
    
    /**
     * Move backwards through the stack
     */
    public func cycleBackwards ()
    {
        if self.index > 0
        {
            self.index -= 1
            
            // Get the view from the delegate
            if let view = self.dataSource?.swipeStackView(self, bufferViewForIndex: self.index)
            {
                // Get the hiddenview
                self.getSubsequentView()?.removeFromSuperview()
                
                // Insert the view into the start of the buffer
                self.viewBuffer.remove(at: 0)
                self.viewBuffer.append(view)
                
                self.layoutSubviews()
                
//                self.dismissViewAnimation.animator.animate(150)
                self.applyKeyframeToSurfaceView(150)
                UIView.animate(withDuration: 0.3, animations: { 
//                    self.dismissViewAnimation.animator.animate(0)
                    self.applyKeyframeToSurfaceView(0)
                })
            }
        }
    }
    
    /**
     Removed the card at the top of the deck and buffer replacements
     */
    private func dismissSurfaceView (direction : TABSwipeStackViewSwipeDirection , animated :  Bool)
    {
        let resetDisplacement : CGFloat = (direction == .right) ? CGFloat(TABSwipeStackView.MAX_VIEW_DISPLACEMENT) : CGFloat(TABSwipeStackView.MAX_VIEW_DISPLACEMENT) * -1
        let maxDisplacement : CGFloat = (direction == .right) ? CGFloat(TABSwipeStackView.DISMISSED_VIEW_DISPLACEMENT) : CGFloat(TABSwipeStackView.DISMISSED_VIEW_DISPLACEMENT) * -1
        
        // This entire block is a hack solution beacuse UIView is broken lawl
        UIView.animateKeyframes(withDuration: 0.4, delay: 0.0, options: [.calculationModeCubic], animations: { () -> Void in
            //reset start point
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.01, animations: { () -> Void in
//                self.dismissViewAnimation.animator.animate(resetDisplacement)
                self.applyKeyframeToSurfaceView(Int(resetDisplacement))
                self.scaleViewAnimation.animator.animate(resetDisplacement)
            })
            
            UIView.addKeyframe(withRelativeStartTime: 0.01, relativeDuration: 0.99, animations: { () -> Void in
//                self.dismissViewAnimation.animator.animate(maxDisplacement)
                self.applyKeyframeToSurfaceView(Int(maxDisplacement))
                self.scaleViewAnimation.animator.animate(maxDisplacement)
            })
        }, completion: {completed in
            self.cycleForwards(direction: direction)
        })
    }

    /**
     Empties cards that have already been loaded and removes them from view
     */
    private func clearBuffer ()
    {
        for view in self.viewBuffer
        {
            view.removeFromSuperview()
        }
        
        self.viewBuffer = []
    }

    // ---------------------------------------------------------------------------
    // MARK: - Touches
    // ---------------------------------------------------------------------------

    /**
     Pan
     */
    @objc private func pan (recognizer : UIPanGestureRecognizer)
    {
        var translation = recognizer.translation(in: self).x * 0.75
        
        // Tell the delegate that the user is panning the view and the direction
        self.delegate?.swipeStackView?(self, pannedView: self.getSurfaceView() ?? UIView(), atIndex: self.index, inDirection: (translation > 0) ? .right : .left)
        
        if translation > CGFloat(TABSwipeStackView.MAX_VIEW_DISPLACEMENT)
        {
            translation = CGFloat(TABSwipeStackView.MAX_VIEW_DISPLACEMENT)
        }
        else if translation < (CGFloat(TABSwipeStackView.MAX_VIEW_DISPLACEMENT) * -1)
        {
            translation = (CGFloat(TABSwipeStackView.MAX_VIEW_DISPLACEMENT) * -1)
        }
        
        if recognizer.state == .ended
        {
            // The user has stoped paning. If the view is at its max dispalcement, we will dismiss it
            if abs(translation) == CGFloat(TABSwipeStackView.MAX_VIEW_DISPLACEMENT)
            {
                self.dismissSurfaceView(direction: (translation > 0) ? .right : .left , animated: true)
            }
            else
            {
                // They hadn't moved the view enough, move it back to its original position
                
                // Tell the delegate that the panning was cancelled
                self.delegate?.swipeStackView?(self, cancelledPanningOnView: self.getSurfaceView() ?? UIView(), atIndex: self.index, inDirection: (translation > 0) ? .right : .left)
                
                UIView.animate(withDuration: 0.4, animations: {
//                    self.dismissViewAnimation.animator.animate(0)
                    self.applyKeyframeToSurfaceView(0)
                    self.scaleViewAnimation.animator.animate(0)
                })
            }
        }
        else
        {
            // Move the view with the user's finger
//            self.dismissViewAnimation.animator.animate(translation)
            let keyframe : Int = Int(translation)
            
            self.applyKeyframeToSurfaceView(keyframe)
            self.scaleViewAnimation.animator.animate(translation)
        }
    }
    
    // ---------------------------------------------------------------------------
    // MARK: - Keyframe Animations
    // ---------------------------------------------------------------------------
    
    private func applyKeyframeToSurfaceView (_ keyframe : Int)
    {
        if let surfaceView = self.getSurfaceView()
        {
            self.delegateAnimator?.swipeStackView?(self, transformationsForSurfaceView: surfaceView, atKeyframe: keyframe)
        }
    }
    
    private func applyKeyframeToSeubsequentView (_ keyframe : Int)
    {
        if let subsequentView = self.getSubsequentView()
        {
            self.delegateAnimator?.swipeStackView?(self, transformationForSubsequentView: subsequentView, atKeyframe: keyframe)
        }
    }
    
    // ---------------------------------------------------------------------------
    // ---------------------------------------------------------------------------
}
