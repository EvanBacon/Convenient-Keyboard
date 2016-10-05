//
//  ViewController.swift
//  Comment Keyboard
//
//  Created by Evan Bacon on 10/4/16.
//  Copyright © 2016 Brix. All rights reserved.
//

import UIKit
import Foundation

struct Platform {
    
    static var isSimulator: Bool {
        return TARGET_OS_SIMULATOR != 0
    }
    
}
class ViewController: UIViewController {

    @IBOutlet weak var label:UILabel!
    private lazy var keyboardTextField : KeyboardView! = {
        let keyboardTextField = MaterialKeyboardView()
        keyboardTextField.delegate = self
        keyboardTextField.autoresizingMask = [UIViewAutoresizing.flexibleWidth , UIViewAutoresizing.flexibleTopMargin]
        return keyboardTextField
    }()
    
    override func loadView() {
        super.loadView()
        self.view.addSubview(keyboardTextField)
        keyboardTextField.toFullyBottom()
        
        
        if Platform.isSimulator {
            label.text! += "\n ⇧⌘K to show keyboard on simulator"
        }
    }
    
    @IBAction func tapped(gesture:UIGestureRecognizer) {
        keyboardTextField.show()
    }
}

//MARK: KeyboardViewDelegate
extension ViewController : KeyboardViewDelegate {
    func keyboardTextFieldPressReturnButton(_ keyboardTextField: KeyboardView) {
        UIAlertView(title: "Timmy, Timmy", message: "Timmy Turner", delegate: nil, cancelButtonTitle: "OK").show()
    }
    
    func keyboardTextFieldPressRightButton(_ keyboardTextField: KeyboardView) {
        let comment = keyboardTextField.text
        keyboardTextField.text = ""
        notify(message: comment!)
        
        keyboardTextField.hide()
    }
    
    func notify(message:String) {
        print("You Said: \(message)")
    }
}


