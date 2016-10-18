//
//  Keyboard+Extension.swift
//  Comment Keyboard
//
//  Created by Evan Bacon on 10/17/16.
//  Copyright © 2016 Brix. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func toFullyBottom() {
        self.top = superview!.bounds.size.height
        self.autoresizingMask = [UIViewAutoresizing.flexibleTopMargin, UIViewAutoresizing.flexibleWidth]
    }
    
    public var top: CGFloat{
        get {
            return self.frame.origin.y
        }
        set {
            var frame = self.frame
            frame.origin.y = newValue
            self.frame = frame
        }
    }
    
    
    public var bottom: CGFloat{
        get {
            return self.frame.origin.y + self.frame.size.height
        }
        set {
            var frame = self.frame;
            frame.origin.y = newValue - frame.size.height;
            self.frame = frame;
        }
    }
}


extension UIView {
    func toBottom(offset : CGFloat = 0.0) {
        if let superView = superview {
            frame.origin.y = superView.bounds.size.height - offset - frame.size.height;
        }else {
            print("UIView+SYAutoLayout toBottom 没有 superview");
        }
    }
}


extension UIColor {
    
    convenience init(rgb: (r: CGFloat, g: CGFloat, b: CGFloat)) {
        self.init(red: rgb.r/255, green: rgb.g/255, blue: rgb.b/255, alpha: 1)
    }
    convenience init(rgba: (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat)) {
        self.init(red: rgba.r/255, green: rgba.g/255, blue: rgba.b/255, alpha: rgba.a)
    }
}
