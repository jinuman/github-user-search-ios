//
//  UIKitExtensions.swift
//  MyGithubUserSearch
//
//  Created by Jinwoo Kim on 06/05/2019.
//  Copyright © 2019 jinuman. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
}

extension UIView {
    func addToSuperview(_ superview: UIView?) {
        superview?.addSubview(self)
    }
    
    func addSubviews(_ subviews: [UIView?]) {
        subviews.forEach {
            $0?.addToSuperview(self)
        }
    }
    
    func addSubviews(_ subviews: [UIView]) {
        subviews.forEach {
            $0.addToSuperview(self)
        }
    }
}
