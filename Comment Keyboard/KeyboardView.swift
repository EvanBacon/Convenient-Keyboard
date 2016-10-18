//
//  KeyboardView.swift
//  Comment Keyboard
//
//  Created by Evan Bacon on 10/4/16.
//  Copyright © 2016 Brix. All rights reserved.
//

import Foundation
import UIKit

fileprivate var keyboardViewDefaultHeight : CGFloat = 48.0
fileprivate let textViewDefaultHeight : CGFloat = 36.0


fileprivate var KeyboardViewDebugMode : Bool = true

open class KeyboardView: UIView {
    
    //Delegate
    open weak var delegate : KeyboardViewDelegate?
    
    var commentView:UIView!
    var underlayView:UIView!

    var underlayAlpha:CGFloat = 0.5
    //Init
    public convenience init() {
        self.init(frame: CGRect(origin: CGPoint(), size: CGSize(width: UIScreen.main.bounds.width, height: keyboardViewDefaultHeight)))
    }
    
    public convenience init(point : CGPoint,width : CGFloat) {
        self.init(frame: CGRect(x: point.x, y: point.y, width: width, height: keyboardViewDefaultHeight))
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override init(frame : CGRect) {
        super.init(frame : frame)
        self.frame = UIScreen.main.bounds
        
        commentView = UIView()
        commentView.frame = frame
        self.addSubview(commentView)
        
        
        setupComponents()
    }
    
    func setupComponents() {
        keyboardViewDefaultHeight = commentView.frame.height
        
        keyboardView.frame = commentView.bounds
        commentView.addSubview(keyboardView)
        
        underlayView = UIView(frame:UIScreen.main.bounds)
        underlayView.backgroundColor = UIColor.clear
        
        
        underlayView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(underlayTapped(gesture:)) ))
        self.insertSubview(underlayView, belowSubview: commentView)
        
        
        keyboardView.addSubview(textViewBackground)
        
        keyboardView.addSubview(textView)

        placeholderLabel.font = textView.font
        textView.addSubview(placeholderLabel)
        
        keyboardView.addSubview(leftButton)
        keyboardView.addSubview(rightButton)
        
        registeringKeyboardNotification()
        
    }
    
    func underlayTapped(gesture:UITapGestureRecognizer) {
        if isEditing {
            hide()
        } else {
            show()
        }
    }

    
    open func show() {
        textView.becomeFirstResponder()
    }
    
    open func hide() {
        textView.resignFirstResponder()
        endEditing(true)
    }
    
    //Status
    public var isSending = false
    
    public var isEnabled: Bool = true {
        didSet {
            textView.isEditable = isEnabled
            leftButton.isEnabled = isEnabled
            rightButton.isEnabled = isEnabled
        }
    }
    
    public var isEditing : Bool {
        return textView.isFirstResponder
    }
    
    public var isLeftButtonHidden : Bool = true {
        didSet {
            leftButton.isHidden = isLeftButtonHidden
            setNeedsLayout()
        }
    }
    
    public var isRightButtonHidden : Bool = true {
        didSet {
            rightButton.isHidden = isRightButtonHidden
            setNeedsLayout()
        }
    }
    
    //text
    public var text : String! {
        get {
            return textView.text
        }
        set {
            textView.text = newValue
            textViewDidChange(textView)
            layoutIfNeeded()
        }
    }
    
    open var maxNumberOfWords : Int = 140
    open var minNumberOfWords : Int = 0
    open var maxNumberOfLines : Int = 4
    
    
    //UI
    open lazy var keyboardView:UIView = {
       
        let view = UIView()
        view.backgroundColor = UIColor.clear
        view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]

        return view
    }()
    open lazy var textView: KeyboardTextView = {
       
        let textView = KeyboardTextView()
        textView.font = UIFont.systemFont(ofSize: 15.0);
        //        textView.autocapitalizationType = UITextAutocapitalizationType.Sentences
        textView.scrollIndicatorInsets = UIEdgeInsetsMake(0, -1, 0, 1);//滚动指示器 皮条
        textView.textContainerInset = UIEdgeInsetsMake(9.0, 3.0, 7.0, 0.0);
        textView.autocorrectionType = .no
        textView.keyboardType = UIKeyboardType.default;
        textView.returnKeyType = UIReturnKeyType.done;
        textView.enablesReturnKeyAutomatically = true;
        
        textView.delegate = self
        textView.textColor = UIColor(white: 0.200, alpha: 1.000)
        textView.backgroundColor = UIColor.clear
        textView.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.new, context: nil)
        textView.scrollsToTop = false

        
        return textView
    }()
    
    open lazy var placeholderLabel:UILabel = {
       
        let label = UILabel()
        label.textAlignment = NSTextAlignment.left
        label.numberOfLines = 1
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.lightGray
        label.isHidden = false
        label.text = "placeholder"
        return label
    }()
    open lazy var textViewBackground = UIImageView()
    open lazy var leftButton:UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.clear
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14.0)
        button.setTitle("Left", for: UIControlState())
        button.addTarget(self, action: #selector(KeyboardView.leftButtonAction(_:)), for: UIControlEvents.touchUpInside)
        return button
    }()
    open lazy var rightButton:UIButton = {
        
        let button = UIButton()
        button.backgroundColor = UIColor.clear
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14.0)
        button.setTitle("Right", for: UIControlState())
        button.addTarget(self, action: #selector(KeyboardView.rightButtonAction(_:)), for: UIControlEvents.touchUpInside)
        return button
    }()
    
    //Layout
    fileprivate var lastKeyboardFrame : CGRect = CGRect.zero
    
    open var leftRightDistance : CGFloat = 8.0
    open var middleDistance : CGFloat = 8.0
    
    open var buttonMaxWidth : CGFloat = 65.0
    open var buttonMinWidth : CGFloat = 45.0
    
    func layoutLeftButton() {
        guard !isLeftButtonHidden else {
            return
        }
        
        var leftButtonWidth : CGFloat = 0.0
            leftButton.sizeToFit()
            if (buttonMinWidth <= leftButton.bounds.size.width) {
                leftButtonWidth = leftButton.bounds.size.width + 10
            }else {
                leftButtonWidth = buttonMinWidth
            }
            if (leftButton.bounds.size.width > buttonMaxWidth)
            {
                leftButtonWidth = buttonMaxWidth
            }
            leftButton.frame = CGRect(x: leftRightDistance, y: 0, width: leftButtonWidth, height: textViewDefaultHeight);
            leftButton.toBottom(offset: (keyboardViewDefaultHeight - textViewDefaultHeight) / 2.0)
        
    }
    
    func layoutRightButton() {
        guard !isRightButtonHidden else {
            return
        }
        
            var rightButtonWidth : CGFloat = 0.0
            rightButton.sizeToFit()
            if (buttonMinWidth <= rightButton.bounds.size.width) {
                rightButtonWidth = rightButton.bounds.size.width + 10;
            }else {
                rightButtonWidth = buttonMinWidth
            }
            if (rightButton.bounds.size.width > buttonMaxWidth)
            {
                rightButtonWidth = buttonMaxWidth;
            }
            rightButton.frame = CGRect(x: keyboardView.bounds.size.width - leftRightDistance - rightButtonWidth, y: 0, width: rightButtonWidth, height: textViewDefaultHeight);
            rightButton.toBottom(offset: (keyboardViewDefaultHeight - textViewDefaultHeight) / 2.0)
        
        
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        layoutLeftButton()
        layoutRightButton()
        
      
        textView.frame =
            CGRect(
                x: (isLeftButtonHidden == false ? leftButton.frame.origin.x + leftButton.bounds.size.width + middleDistance : leftRightDistance),
                y: (keyboardViewDefaultHeight - textViewDefaultHeight) / 2.0 + 0.5,
                width: keyboardView.bounds.size.width
                    - (isLeftButtonHidden == false ? leftButton.bounds.size.width + middleDistance:0)
                    - (isRightButtonHidden == false ? rightButton.bounds.size.width + middleDistance:0)
                    - leftRightDistance * 2,
                height: textViewCurrentHeightForLines(textView.numberOfLines())
        )
        textViewBackground.frame = textView.frame;
        
        if placeholderLabel.textAlignment == .left {
            placeholderLabel.sizeToFit()
            placeholderLabel.frame.origin = CGPoint(x: 8.0, y: (textViewDefaultHeight - placeholderLabel.bounds.size.height) / 2);
            
        } else if placeholderLabel.textAlignment == .center {
            placeholderLabel.frame = placeholderLabel.superview!.bounds
        }
        
    }
    
    deinit {
        if KeyboardViewDebugMode {
            print("\(NSStringFromClass(classForCoder)) has release!")
        }
        
        NotificationCenter.default.removeObserver(self)
    }
    
    fileprivate var isHiding = false
}


@objc public protocol KeyboardViewDelegate : class {
    
    @objc optional func keyboardTextFieldPressLeftButton(_ keyboardTextField :KeyboardView)
    
    @objc optional func keyboardTextFieldPressRightButton(_ keyboardTextField :KeyboardView)
    
    @objc optional func keyboardTextFieldPressReturnButton(_ keyboardTextField :KeyboardView)
    
    @objc optional func keyboardTextFieldWillHide(_ keyboardTextField :KeyboardView)
    
    @objc optional func keyboardTextFieldDidHide(_ keyboardTextField :KeyboardView)
    
    @objc optional func keyboardTextFieldWillShow(_ keyboardTextField :KeyboardView)
    
    @objc optional func keyboardTextFieldDidShow(_ keyboardTextField :KeyboardView)
    
    @objc optional func keyboardTextField(_ keyboardTextField :KeyboardView , didChangeText text:String)
    
}


//MARK: TextViewHeight
extension KeyboardView {
    
    fileprivate func textViewCurrentHeightForLines(_ numberOfLines : Int) -> CGFloat {
        var height = textViewDefaultHeight - textView.font!.lineHeight
        let lineTotalHeight = textView.font!.lineHeight * CGFloat(numberOfLines)
        height += CGFloat(roundf(Float(lineTotalHeight)))
        return CGFloat(Int(height));
    }
    
    fileprivate func appropriateInputbarHeight() -> CGFloat {
        var height : CGFloat = 0.0;
        
        if textView.numberOfLines() == 1 {
            height = textViewDefaultHeight;
        }else if textView.numberOfLines() < maxNumberOfLines {
            height = textViewCurrentHeightForLines(textView.numberOfLines())
        }
        else {
            height = textViewCurrentHeightForLines(maxNumberOfLines)
        }
        
        height += keyboardViewDefaultHeight - textViewDefaultHeight;
        
        if (height < keyboardViewDefaultHeight) {
            height = keyboardViewDefaultHeight;
        }
        return CGFloat(roundf(Float(height)));
    }
    
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        guard let object = object,let change = change else { return }
        
        if (object as AnyObject).isEqual(textView) && keyPath == "contentSize" {
            if KeyboardViewDebugMode {
                let newValue = (change[NSKeyValueChangeKey.newKey] as AnyObject).cgSizeValue
                print("\(newValue)---\(appropriateInputbarHeight())")
            }
            
            let newKeyboardHeight = appropriateInputbarHeight()
            if newKeyboardHeight != keyboardView.bounds.size.height && superview != nil {
                UIView.animate(withDuration: 0.2, delay: 0.0, options: UIViewAnimationOptions(), animations: { () -> Void in
                    let lastKeyboardFrameHeight = (self.lastKeyboardFrame.origin.y == 0.0 ? self.superview!.bounds.size.height : self.lastKeyboardFrame.origin.y)
                    self.commentView.frame = CGRect(x: self.commentView.frame.origin.x,  y: lastKeyboardFrameHeight - newKeyboardHeight, width: self.commentView.frame.size.width, height: newKeyboardHeight)
                    
                    }, completion:nil
                )
            }
        }
    }
}

//MARK: Keyboard Notification
extension KeyboardView {
    
    var keyboardAnimationOptions : UIViewAnimationOptions {
        return  UIViewAnimationOptions(rawValue: (7 as UInt) << 16)
    }
    var keyboardAnimationDuration : TimeInterval {
        return  TimeInterval(0.25)
    }
    
    func registeringKeyboardNotification() {
        //  Registering for keyboard notification.
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardView.keyboardWillShow(_:)),name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardView.keyboardDidShow(_:)),name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardView.keyboardWillHide(_:)),name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardView.keyboardDidHide(_:)),name: NSNotification.Name.UIKeyboardDidHide, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardView.keyboardWillChangeFrame(_:)),name:NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardView.keyboardDidChangeFrame(_:)),name:NSNotification.Name.UIKeyboardDidChangeFrame, object: nil)
        
        //  Registering for orientation changes notification
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardView.willChangeStatusBarOrientation(_:)),name: NSNotification.Name.UIApplicationWillChangeStatusBarOrientation, object: nil)
        
    }
    
    func keyboardWillShow(_ notification : Notification) {
        if textView.isFirstResponder {
            delegate?.keyboardTextFieldWillShow?(self)
        }
    }
    func keyboardDidShow(_ notification : Notification) {
        if textView.isFirstResponder {
            delegate?.keyboardTextFieldDidShow?(self)
        }
    }
    func keyboardWillHide(_ notification : Notification) {
        if textView.isFirstResponder {
            isHiding = true
            delegate?.keyboardTextFieldWillHide?(self)
        }
    }
    func keyboardDidHide(_ notification : Notification) {
        if isHiding {
            isHiding = false
            delegate?.keyboardTextFieldDidHide?(self)
        }
    }
    func keyboardWillChangeFrame(_ notification : Notification) {
        guard let window = window, window.isKeyWindow else { return }
        
        if textView.isFirstResponder {
            var userInfo = (notification as NSNotification).userInfo as! [String : AnyObject]
            let keyboardFrameValue = userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue
            let keyboardFrame = keyboardFrameValue.cgRectValue
            lastKeyboardFrame = superview!.convert(keyboardFrame, from: UIApplication.shared.keyWindow)
            if KeyboardViewDebugMode {
                print("keyboardFrame : \(keyboardFrame)")
            }
            
            animateKeyboardView()
        }
    }
    
    func animateKeyboardView() {
        let keyboardClosed = (self.lastKeyboardFrame.origin.y >= (window?.frame.size.height)!)
        
        let offset = keyboardClosed
            ? 0
            : -self.keyboardView.bounds.size.height
        
        UIView.animate(withDuration: keyboardAnimationDuration, animations: {
            self.underlayView.backgroundColor = UIColor.black.withAlphaComponent(keyboardClosed ? 0 : self.underlayAlpha)
            self.commentView.frame.origin.y = self.lastKeyboardFrame.origin.y + offset
        }) {
            _ in
            self.isUserInteractionEnabled = !keyboardClosed
        }
    }
    
    
    func keyboardDidChangeFrame(_ notification : Notification) {}
    func willChangeStatusBarOrientation(_ notification : Notification) {}
    
}


//MARK: TapButtonAction
extension KeyboardView {
    
    func leftButtonAction(_ button : UIButton) {
        delegate?.keyboardTextFieldPressLeftButton?(self)
    }
    
    func rightButtonAction(_ button : UIButton) {
        delegate?.keyboardTextFieldPressRightButton?(self)
    }
    
    fileprivate var tapButtonTag : Int { return 12345 }
    fileprivate var tapButton : UIButton { return superview!.viewWithTag(tapButtonTag) as! UIButton }
    
    func tapAction(_ button : UIButton) {
        hide()
    }
    
    fileprivate func setTapButtonHidden(_ hidden : Bool) {
        tapButton.isHidden = hidden
        
        guard !hidden, let tapButtonSuperView = tapButton.superview  else {
            return
        }

        tapButtonSuperView.insertSubview(tapButton, belowSubview: self)
    }
    
    override open func didMoveToSuperview() {
        guard let superview = superview else {
            return
        }
        
        let tapButton:UIButton = {
         
            let button = UIButton(frame: superview.bounds)
            button.addTarget(self, action: #selector(KeyboardView.tapAction(_:)), for: UIControlEvents.touchUpInside)
            button.tag = tapButtonTag
            button.isHidden = true
            button.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
            button.backgroundColor = UIColor.clear

            return button
        }()
        superview.insertSubview(tapButton, at: 0);
    }
    
    override open func willMove(toSuperview newSuperview: UIView?) {
        guard let superview = superview, newSuperview == nil else {
            return
        }
        
        superview.viewWithTag(tapButtonTag)?.removeFromSuperview()
        textView.removeObserver(self, forKeyPath: "contentSize", context: nil)
    }
}


//MARK: UITextViewDelegate
extension KeyboardView : UITextViewDelegate {
    
    public func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.alpha = textView.text.characters.isEmpty ? 1 : 0
        delegate?.keyboardTextField?(self, didChangeText: textView.text)
    }
    
    public func textViewDidBeginEditing(_ textView: UITextView) {
        setTapButtonHidden(false)
    }
    
    public func textViewDidEndEditing(_ textView: UITextView) {
        setTapButtonHidden(true)
    }
    
    public func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return true
    }
    
    public func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        return true
    }
    
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard !isSending else {
            return false
        }

        if text == "\n" {
            if isSending == false {
                delegate?.keyboardTextFieldPressReturnButton?(self)
            }
            return false
        }
        return true
    }
}

