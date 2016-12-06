//
//  HDLNewsCardScaleAnimation.swift
//  Headline
//
//  Created by Dale Webster on 31/10/2016.
//  Copyright © 2016 TabApps. All rights reserved.
//

import UIKit
import RazzleDazzle

public class TABScaleViewAnimation: NSObject
{
    // ---------------------------------------------------------------------------
    // MARK: - Properties
    // ---------------------------------------------------------------------------
    
    public let animator : Animator = Animator()
    
    // ---------------------------------------------------------------------------
    // MARK: - UI Components
    // ---------------------------------------------------------------------------
    
    // ---------------------------------------------------------------------------
    // MARK: - Init
    // ---------------------------------------------------------------------------
    
    convenience public init (withView view : UIView)
    {
        self.init()
        
        let scale : ScaleAnimation = ScaleAnimation(view: view)
        scale[0] = CGFloat(0.85)
        scale[-100] = CGFloat(0.95)
        scale[100] = CGFloat(0.95)
        scale[150] = CGFloat(1)
        scale[-150] = CGFloat(1)
        
        let alpha : AlphaAnimation = AlphaAnimation(view: view)
        alpha[0] = CGFloat(0.2)
        alpha[-100] = CGFloat(0.7)
        alpha[100] = CGFloat(0.7)
        alpha[150] = CGFloat(1)
        alpha[-150] = CGFloat(1)
        
        let translate : TranslationAnimation = TranslationAnimation(view: view)
        translate[0] = CGPoint(x: 0, y: 0)
        translate[-1] = CGPoint(x: 99, y: 0)
        translate[1] = CGPoint(x: -99, y: 0)
        translate[100] = CGPoint(x: -20, y: 0)
        translate[-100] = CGPoint(x: 20, y: 0)
        translate[150] = CGPoint(x: 0, y: 0)
        translate[-150] = CGPoint(x: 0, y: 0)
        
        let rotate : RotationAnimation = RotationAnimation(view: view)
        rotate[0] = 0
        rotate[-1] = -3
        rotate[1] = 3
        rotate[100] = 1
        rotate[-100] = -1
        rotate[-150] = 0
        rotate[150] = 0
        
        self.animator.addAnimation(scale)
        self.animator.addAnimation(alpha)
        self.animator.addAnimation(translate)
    }
    
    // ---------------------------------------------------------------------------
    // ---------------------------------------------------------------------------
}
