//
//  RTAnimationUtility.swift
//  RadiantTune
//
//  Created by Aaribna Gurung on 6/7/24.
//


import UIKit

class RTAnimationUtility {
    static func favroiteButton(view: UIView) {
        view.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        
        UIView.animateKeyframes(withDuration: 0.5, delay: 0, options: [], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.25) {
                view.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            }
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.15) {
                view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }
            UIView.addKeyframe(withRelativeStartTime: 0.75, relativeDuration: 0.15) {
                view.transform = CGAffineTransform.identity
            }
        })
    }
}
