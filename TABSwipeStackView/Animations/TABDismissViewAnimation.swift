//
//  HDLDismissNewsCardAnimation.swift
//  Headline
//
//  Created by Dale Webster on 31/10/2016.
//  Copyright © 2016 TabApps. All rights reserved.
//

import UIKit
import RazzleDazzle

public class TABDismissViewAnimation : NSObject , TABSwipeStackViewDelegateAnimator
{
    // ---------------------------------------------------------------------------
    // MARK: - Surface Card Properties
    // ---------------------------------------------------------------------------
    
    //private static let MAX_ROTATION : CGFloat = 5
    private static let COMPLETE_ROTATION : CGFloat = 25
    private static let COMPLETE_TRANSLATION : CGFloat = 500
    
    // ---------------------------------------------------------------------------
    // MARK: - TABSwipeStackDelegateAnimator Methods
    // ---------------------------------------------------------------------------
    
    public func swipeStackView(_ swipeStackView: TABSwipeStackView, transformationsForSurfaceView view: UIView, atKeyframe keyframe: Int)
    {
        view.transform = .identity
        view.transform = CGAffineTransform(translationX: CGFloat(keyframe) / 150 * TABDismissViewAnimation.COMPLETE_TRANSLATION, y: 0).rotated(by: CGFloat(keyframe) * TABDismissViewAnimation.COMPLETE_ROTATION)
    }
    
    public func swipeStackView(_ swipeStackView: TABSwipeStackView, transformationForSubsequentView view: UIView, atKeyframe keyframe: Int)
    {
        
    }
    
    // ---------------------------------------------------------------------------
    // ---------------------------------------------------------------------------
}

//public class TABDismissViewAnimation_old: NSObject
//{
//    // ---------------------------------------------------------------------------
//    // MARK: - Properties
//    // ---------------------------------------------------------------------------
//    
//    public let animator : Animator = Animator()
//    public var rotationAnimation : RotationAnimation!
//    public var translationAnimation : TranslationAnimation!
//    
//    // ---------------------------------------------------------------------------
//    // MARK: - UI Components
//    // ---------------------------------------------------------------------------
//    
//    // ---------------------------------------------------------------------------
//    // MARK: - Init
//    // ---------------------------------------------------------------------------
//    
//    convenience public init (withView view : UIView)
//    {
//        self.init()
//        
//        self.rotationAnimation = RotationAnimation(view: view)
//        self.translationAnimation = TranslationAnimation(view: view)
//        
//        // Add keyframes
//        self.rotationAnimation[-100] = 5
//        self.rotationAnimation[100] = -5
//        
//        // Keyframes for complete dismissal
//        self.translationAnimation[-150] = CGPoint(x: -500, y: 0)
//        self.translationAnimation[150] = CGPoint(x: 500, y: 0)
//        
//        self.rotationAnimation[-150] = 25
//        self.rotationAnimation[150] = -25
//        
//        self.animator.addAnimation(self.rotationAnimation)
//        self.animator.addAnimation(self.translationAnimation)
//    }
//    
//    // ---------------------------------------------------------------------------
//    // ---------------------------------------------------------------------------
//}
