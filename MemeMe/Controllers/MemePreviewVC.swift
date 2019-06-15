//
//  MemePreviewVC.swift
//  MemeMe
//
//  Created by Hadi Albinsaad on 15/06/2019.
//  Copyright © 2019 Hadi. All rights reserved.
//

import UIKit


class MemePreviewVC: UIViewController {

    @IBOutlet weak var imageView: UIImageView!

    var meme: Meme?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let meme = meme else {
            alert(title: "Error", message: "Meme is nil :(")
            return
        }
        
        imageView.image = meme.memedImage
    }
    
}
