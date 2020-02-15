//
//  FloatingTextField3.swift
//
//  Created by Mahdi mokadem on 1/27/20.
//  Copyright © 2020. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class FloatingTextField: UIView, UITextFieldDelegate {

    var placeHolderTopConstraint: NSLayoutConstraint!
    var placeHolderCenterYConstraint: NSLayoutConstraint!
    var placeHolderLeadingConstraint: NSLayoutConstraint!
    var lineHeightConstraint: NSLayoutConstraint!
    var errorLabelBottomConstraint: NSLayoutConstraint!
    var trailingPlaceholder: NSLayoutConstraint!
    
    var activeColor: UIColor = UIColor(red: 64/255.0, green: 110/255.0, blue: 191/255.0, alpha: 1.0)
    var inActiveColor: UIColor = UIColor(red: 84/255.0, green: 110/255.0, blue: 122/255.0, alpha: 0.8)
    var errorColorFull: UIColor =  UIColor(red: 254/255.0, green: 103/255.0, blue: 103/255.0, alpha: 1.0)

    var animationDuration = 0.35

    var maxFontSize: CGFloat = 14
    var minFontSize: CGFloat = 11

    let errorLabelFont = UIFont(name: "Lato-Regular", size: 12)
    let bag = DisposeBag()
    
    var placeholderText: String = "" {
        didSet {
            placeholderLabel.text = placeholderText
        }
    }
    
    let placeholderLabel: UILabel = {
        let v = UILabel()
        v.text = "Default Placeholder"
        v.setContentHuggingPriority(.required, for: .vertical)
        return v
    }()

    let line: UIView = {
        let v = UIView()
        v.backgroundColor = .lightGray
        return v
    }()

    let errorLabel: UILabel = {
        let v = UILabel()
        v.numberOfLines = 0
        v.text = ""
        v.setContentCompressionResistancePriority(.required, for: .vertical)
        v.isAccessibilityElement = true
        v.accessibilityIdentifier = "textinput_error"
        return v
    }()

    let textField: UITextField = {
        let v = UITextField()
        return v
    }()

    var isTextEntrySecured: Bool = false {
        didSet {
            textField.isSecureTextEntry = isTextEntrySecured
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    func commonInit() -> Void {

        clipsToBounds = true
        backgroundColor = .white

        [textField, line, placeholderLabel, errorLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }

        // place holder label gets 2 vertical constraints
        //      top of view
        //      centerY to text field
        placeHolderTopConstraint = placeholderLabel.topAnchor.constraint(equalTo: topAnchor, constant: 0.0)
        placeHolderCenterYConstraint = placeholderLabel.centerYAnchor.constraint(equalTo: textField.centerYAnchor, constant: 0.0)
        
        // place holder leading constraint is 0-pts (when centered on text field)
        //  when animated above text field, we'll change the constant to 0
        placeHolderLeadingConstraint = placeholderLabel.leadingAnchor.constraint(equalTo: textField.leadingAnchor, constant: 0.0)
        trailingPlaceholder = placeholderLabel.trailingAnchor.constraint(equalTo: textField.trailingAnchor, constant: 0.0)
        
        // error label bottom constrained to bottom of view
        //  will be activated when shown, deactivated when hidden
        errorLabelBottomConstraint = errorLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0)
        
        // line height constraint constant changes between 1 and 2 (inactive / active)
        lineHeightConstraint = line.heightAnchor.constraint(equalToConstant: 1.0)

        NSLayoutConstraint.activate([

            // text field top 16-pts from top of view
            // leading and trailing = 0
            textField.topAnchor.constraint(equalTo: topAnchor, constant: 16.0),
            textField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0.0),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0.0),

            // text field height = 24
            textField.heightAnchor.constraint(equalToConstant: 24.0),

            // text field bottom is AT LEAST 4 pts
            textField.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -16.0),

            // line view top is 2-pts below text field bottom
            // leading and trailing = 0
            line.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 8.0),
            line.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0.0),
            line.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0.0),

            // error label top is 16-pts from text field bottom
            // leading and trailing = 0
            errorLabel.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 16),
            errorLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            errorLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0.0),

            placeHolderCenterYConstraint,
            placeHolderLeadingConstraint,
            lineHeightConstraint,
            trailingPlaceholder,

        ])
        errorLabelBottomConstraint.isActive = true
        
        setUpTextFieldSubscribeEvents()

        textField.font = UIFont(name: "Lato-Regular", size: maxFontSize)
        textField.textColor = .black

        placeholderLabel.font = UIFont(name: "Lato-Regular", size: maxFontSize)
        placeholderLabel.textColor = inActiveColor

        line.backgroundColor = inActiveColor

        errorLabel.textColor = errorColorFull
        errorLabel.font = errorLabelFont

    }

    func setUpTextFieldSubscribeEvents(){
        textField.rx.controlEvent(.editingDidBegin).subscribe(onNext: { (next) in
            if self.textField.text?.isEmpty ?? false {
                self.animatePlaceholderUp()
            }
            self.errorLabel.text = ""
            self.line.backgroundColor = self.activeColor
            self.placeholderLabel.textColor = self.activeColor
            self.errorLabel.isHidden = true
        }).disposed(by: bag)
        
        textField.rx.controlEvent(.editingDidEnd).subscribe(onNext: { (next) in
            if self.textField.text?.isEmpty ?? false {
                self.animatePlaceholderCenter()
            }
        }).disposed(by: bag)
    }

    func animatePlaceholderUp() -> Void {
        
        UIView.animate(withDuration: animationDuration, animations: {
            // increase line height
            self.lineHeightConstraint.constant = 2.0
            // set line to activeColor
            self.line.backgroundColor = self.activeColor
            // set placeholder label font and color
            self.placeholderLabel.font = self.placeholderLabel.font.withSize(self.minFontSize)
            self.placeholderLabel.textColor = self.activeColor

            // deactivate placeholder label CenterY constraint
            self.placeHolderCenterYConstraint.isActive = false
            // activate placeholder label Top constraint
            self.placeHolderTopConstraint.isActive = true
            // move placeholder label leading to 0
            //self.placeHolderLeadingConstraint.constant = 0

            self.layoutIfNeeded()
        }) { (done) in

        }

    }

    func animatePlaceholderCenter() -> Void {

        UIView.animate(withDuration: animationDuration, animations: {
            // decrease line height
            self.lineHeightConstraint.constant = 1.0
            // set line to inactiveColor
            self.line.backgroundColor = self.inActiveColor

            // set placeholder label font and color
            self.placeholderLabel.font = self.placeholderLabel.font.withSize(self.maxFontSize)
            self.placeholderLabel.textColor = self.inActiveColor

            // deactivate placeholder label Top constraint
            self.placeHolderTopConstraint.isActive = false
            // activate placeholder label CenterY constraint
            self.placeHolderCenterYConstraint.isActive = true
            // move placeholder label leading to 16
            //self.placeHolderLeadingConstraint.constant = 16

            self.layoutIfNeeded()
        }) { (done) in

        }

    }

    func setErrorText(_ error: String?, errorAccessibilityValue: String?, endEditing: Bool? = true) {
        if let errorText = error {
            UIView.animate(withDuration: 0.05, animations: {

                self.errorLabel.text = errorText
                self.line.backgroundColor = self.errorColorFull
                self.errorLabel.isHidden = false
                self.placeholderLabel.textColor = self.errorColorFull
                // activate error label Bottom constraint
                //self.errorLabelBottomConstraint.isActive = true

            }) { (done) in
                if endEditing ?? true {
                    self.textField.resignFirstResponder()
                }
            }
        }else{
            UIView.animate(withDuration: 0.05, animations: {

                self.errorLabel.text = ""
                self.line.backgroundColor = self.inActiveColor
                self.errorLabel.isHidden = true
                self.placeholderLabel.textColor = self.activeColor
                // deactivate error label Bottom constraint
               // self.errorLabelBottomConstraint.isActive = false

            }) { (done) in
                if endEditing ?? true {
                    self.textField.resignFirstResponder()
                }
            }
        }

        errorLabel.accessibilityIdentifier = errorAccessibilityValue ?? "textinput_error"
    }

    // func to set / clear element background colors
    // to make it easy to see the frames
    func showHideFrames(show b: Bool) -> Void {
        if b {
            self.backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 1.0, alpha: 1.0)
            placeholderLabel.backgroundColor = .cyan
            errorLabel.backgroundColor = .green
            textField.backgroundColor = .yellow
        } else {
            self.backgroundColor = .white
            [placeholderLabel, errorLabel, textField].forEach {
                $0.backgroundColor = .clear
            }
        }
    }

}
