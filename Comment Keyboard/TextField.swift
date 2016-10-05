//
//  TextField.swift
//  Comment Keyboard
//
//  Created by Evan Bacon on 10/4/16.
//  Copyright © 2016 Brix. All rights reserved.
//

import Foundation
import UIKit

open class KeyboardTextView : UITextView {
    private var hasDragging : Bool = false
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        if isDragging == false {
            if hasDragging {
                let delayTime = DispatchTime.now() + Double(Int64(1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: delayTime) {
                    self.hasDragging = false
                }
            }else {
                if selectedRange.location == text.characters.count {
                    contentOffset = CGPoint(x: contentOffset.x, y: (contentSize.height + 2) - bounds.size.height)
                }
            }
        }else {
            hasDragging = true
        }
    }
    
}

//MARK: UITextView extension
extension UITextView {
    
    func numberOfLines() -> Int {
        let line = contentSize.height / font!.lineHeight
        if line < 1.0 { return 1 }
        return abs(Int(line))
    }
}
