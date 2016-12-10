//
//  HDLDismissNewsCardAnimation.swift
//  Headline
//
//  Created by Dale Webster on 31/10/2016.
//  Copyright © 2016 TabApps. All rights reserved.
//

import UIKit

open class TABSwipeStackViewAnimation : NSObject , TABSwipeStackViewDelegateAnimator
{
    // ---------------------------------------------------------------------------
    // MARK: - Class Properties
    // ---------------------------------------------------------------------------
    
    public static let TOTAL_KEYFRAMES : CGFloat = 150
    
    // ---------------------------------------------------------------------------
    // MARK: - Surface Card Properties
    // ---------------------------------------------------------------------------
    
    private let maxRotation : CGFloat = 0.25
    private let maxTranslation : CGFloat = 500
    
    // ---------------------------------------------------------------------------
    // MARK: - Subsequent Card Properties
    // ---------------------------------------------------------------------------
    
    private let minScale : CGFloat = 0.85
    private let minAlpha : CGFloat = 0.4
    private let minTranslation : CGFloat = 100
    
    // ---------------------------------------------------------------------------
    // MARK: - TABSwipeStackDelegateAnimator Methods
    // ---------------------------------------------------------------------------
    
    public func swipeStackView(_ swipeStackView: TABSwipeStackView, transformationsForSurfaceView view: UIView, atKeyframe keyframe: Int)
    {
        view.transform = CGAffineTransform(translationX: CGFloat(keyframe) / TABSwipeStackViewAnimation.TOTAL_KEYFRAMES * maxTranslation, y: 0).rotated(by: CGFloat(keyframe) / TABSwipeStackViewAnimation.TOTAL_KEYFRAMES * maxRotation)
    }
    
    public func swipeStackView(_ swipeStackView: TABSwipeStackView, transformationForSubsequentView view: UIView, atKeyframe keyframe: Int)
    {
        let transitionPercentage : CGFloat = abs(CGFloat(keyframe) / TABSwipeStackViewAnimation.TOTAL_KEYFRAMES * 100)
        
        // At 0%, scale should be minScale, at 100% scale should be 1
        let scaleRange : CGFloat = 1 - self.minScale
        let scaleTravel : CGFloat = scaleRange / 100 * transitionPercentage
        let scaleValue : CGFloat = self.minScale + scaleTravel
    
        // At 0% alpha should be minAlpha, at 100% alpha should be 1
        let alphaRange : CGFloat = 1 - self.minAlpha
        let alphaTravel : CGFloat = alphaRange / 100 * transitionPercentage
        let alphaValue : CGFloat = self.minAlpha + alphaTravel
        
        // At 0% translation should be minTranslation, at 100% translation should be 0. If the keyframe is positive
        // and the view is being moved to the right, the view's translation should be coming from the left
        var currentTranslation : CGFloat = self.minTranslation - (self.minTranslation / 100 * transitionPercentage)
        if (keyframe > 0) { currentTranslation *= -1 }
        
        view.transform = CGAffineTransform(scaleX: scaleValue, y: scaleValue).translatedBy(x: currentTranslation, y: 0)
        view.alpha = alphaValue
    }
    
    // ---------------------------------------------------------------------------
    // ---------------------------------------------------------------------------
}
