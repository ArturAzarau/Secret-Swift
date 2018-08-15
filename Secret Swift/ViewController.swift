//
//  ViewController.swift
//  Secret Swift
//
//  Created by Артур Азаров on 15.08.2018.
//  Copyright © 2018 Артур Азаров. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // MARK: - Properties
    
    @IBOutlet var secret: UITextView!
    
    // MARK: - Actions
    
    @IBAction func authenticateTapped(_ sender: Any) {
        unlockSecretMessage()
    }
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        registerForKeyboardNotifications()
        registerForAppWillResignActive()
    }
    
    // MARK: - Methods
    
    private func registerForKeyboardNotifications() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard(notification:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard(notification:)), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    // MARK: -
    
    @objc private func adjustForKeyboard(notification: Notification) {
        let userInfo = notification.userInfo!
        
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, to: view.window)
        if notification.name == Notification.Name.UIKeyboardWillHide {
            secret.contentInset = .zero
        } else {
            secret.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
        }
        secret.scrollIndicatorInsets = secret.contentInset
        let selectedRange = secret.selectedRange
        secret.scrollRangeToVisible(selectedRange)
    }
    
    // MARK: -
    
    private func unlockSecretMessage() {
        secret.isHidden = false
        title = "Secret stuff!"
        
        if let text = KeychainWrapper.standard.string(forKey: "Secret message") {
            secret.text = text
        }
    }
    
    // MARK: -
    
    @objc private func saveSecretMessage() {
        if !secret.isHidden {
            _ = KeychainWrapper.standard.set(secret.text, forKey: "Secret message")
            secret.resignFirstResponder()
            secret.isHidden = true
            title = "Nothing to see here"
        }
    }
    
    // MARK: -
    
    private func registerForAppWillResignActive() {
        NotificationCenter.default.addObserver(self, selector: #selector(saveSecretMessage), name: Notification.Name.UIApplicationWillResignActive, object: nil)
    }
}

