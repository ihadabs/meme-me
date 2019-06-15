//
//  MemeEditorVC.swift
//  MemeMe
//
//  Created by Hadi Albinsaad on 18/10/2018.
//  Copyright © 2018 Hadi. All rights reserved.
//

import UIKit


class MemeEditorVC: UIViewController, UINavigationControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareMemedImage))
        navigationItem.leftBarButtonItem?.isEnabled = false
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        
        //        topTextField.defaultTextAttributes = memeTextAttributes
        //        bottomTextField
        setupTextField(topTextField)
        setupTextField(bottomTextField)
    }
    
    // MARK: Variables
    
    lazy var imagePicker: UIImagePickerController = {
       let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        return imagePicker
    }()
    
    // MARK: Outlets
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    

    
    func setupTextField(_ textField: UITextField) {
        let memeTextAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.strokeColor: UIColor.black,
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSAttributedString.Key.strokeWidth: -4,
            ]
        
        
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = .center
        textField.delegate = self
    }
    
    @IBAction func pickAnImage(_ sender: UIBarButtonItem) {
        
        imagePicker.sourceType = (sender.tag == 0) ? .camera : .photoLibrary
        
        imagePicker.allowsEditing = true
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    /*
        Cancel methed will reset everything back if anything is changed, otherwiese it will dismiss the view.
    
     */
    
    @objc func cancel() {
        if imageView.image == nil && topTextField.text == "TOP" && bottomTextField.text == "BOTTOM" {
            dismiss(animated: true, completion: nil)
        } else {
            topTextField.text = "TOP"
            bottomTextField.text = "BOTTOM"
            updateImageView(image: nil)
        }
    }
    
    @objc func shareMemedImage() {
        
        let memedImage = generateMemedImage()
        let activityViewController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        
        activityViewController.completionWithItemsHandler = { (activity, completed, items, error) in
            if completed {
                self.save()
            }
        }
        present(activityViewController, animated: true, completion: nil)
    }
    
    func updateImageView(image: UIImage?) {
        imageView.image = image
        navigationItem.leftBarButtonItem?.isEnabled = (image != nil)
    }
    
    func generateMemedImage() -> UIImage {
        // Render imageView to an image
        UIGraphicsBeginImageContext(imageView.frame.size)
        view.drawHierarchy(in: imageView.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return memedImage
    }
    
    func save() {
        let topText = (topTextField.text == "TOP") ? "" : topTextField.text ?? ""
        let bottomText = (topTextField.text == "BOTTOM") ? "" : topTextField.text ?? ""
        guard let image = imageView.image else { return }
        let memedImage = generateMemedImage()
        
        let meme = Meme(topText: topText, bottomText: bottomText, originalImage: image, memedImage: memedImage)
        //--- Meme 1
        

        //--- Meme 2
        (UIApplication.shared.delegate as! AppDelegate).memes.append(meme)
        dismiss(animated: true, completion: nil)
        
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}

// MARK: ImagePicker

extension MemeEditorVC: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let image = info[.editedImage] as? UIImage
//        imageView.image = image
        
        
        updateImageView(image: image)
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: false, completion: nil)
    }
}

// MARK: TextFields

extension MemeEditorVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        textField.resignFirstResponder()
        
//        view.endEditing(true)
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let text = textField.text ?? ""
        if (textField == topTextField && text == "TOP") {
            textField.text = ""
        } else if (textField == bottomTextField && text == "BOTTOM") {
            textField.text = ""
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let isEmpty = textField.text?.isEmpty ?? true
        if isEmpty && textField == topTextField {
            topTextField.text = "TOP"
        } else if isEmpty && textField == bottomTextField {
            bottomTextField.text = "BOTTOM"
        }
    }
}

// MARK: Keyboard

extension MemeEditorVC {
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if bottomTextField.isEditing {
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
}
