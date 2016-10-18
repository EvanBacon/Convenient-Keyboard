//
//  MaterialKeyboard.swift
//  Comment Keyboard
//
//  Created by Evan Bacon on 10/4/16.
//  Copyright © 2016 Brix. All rights reserved.
//

import Foundation
import UIKit
class MaterialKeyboardView : KeyboardView {
    
    override init(frame : CGRect) {
        super.init(frame : frame)
        
      
        setupConfiguration()
        setupLeftButton()
        setupRightButton()
     
        setupTextViewBackground()
        
        keyboardView.backgroundColor = UIColor.white
        
        placeholderLabel.textAlignment = .left
        placeholderLabel.text = "Add a comment."
        placeholderLabel.textColor = UIColor(rgb: (153,153,153))
    
        
        commentView.layer.shadowOffset = CGSize(width:0, height: -1)
        commentView.layer.shadowOpacity = 0.2
        
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        commentView.toFullyBottom()
    }
    
    private func setupConfiguration() {
        isLeftButtonHidden = false
        isRightButtonHidden = false
        leftRightDistance = 15.0
        middleDistance = 5.0
        buttonMinWidth = 60
    }
    
    private func setupTextViewBackground() {
        //TextView
        textViewBackground.layer.borderColor = UIColor.white.cgColor
        textViewBackground.backgroundColor = UIColor.white
        textViewBackground.layer.masksToBounds = true
        
    }
    
    private func setupRightButton() {
        //Right Button
        rightButton.showsTouchWhenHighlighted = true
        rightButton.backgroundColor = UIColor(rgb: (51,156,256))
        rightButton.clipsToBounds = true
        rightButton.layer.cornerRadius = 18
        rightButton.setTitle("", for: .normal)
        rightButton.setImage(#imageLiteral(resourceName: "ic_send"), for: .normal)
        rightButton.tintColor = UIColor.white

        rightButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        
    }
    private func setupLeftButton() {
        //Left Button
        leftButton.showsTouchWhenHighlighted = false
        leftButton.clipsToBounds = true
        leftButton.layer.cornerRadius = 18
        leftButton.setTitle("", for: .normal)
        leftButton.setBackgroundImage(#imageLiteral(resourceName: "desiigner"), for: .normal)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}

