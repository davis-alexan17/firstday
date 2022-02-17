//
//  CategoryViewController.swift
//  AppDevAlpha
//
//  Created by Mac User on 9/20/20.
//  Copyright © 2020 Innovation Center. All rights reserved.
//

import UIKit

class ItemViewController: UIViewController {
    var data: Profile?
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var textArea: UITextView!
    @IBOutlet weak var headTitle: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let d = data!
        let imgKey = d.imgKey!
        if imgKey != nil && imgKey != "None"{
        self.image.image = Schools_Controller.getImage(imgKey: imgKey)
        }
        self.textArea.text = d.text()
        self.headTitle.text = d.name()
        self.headTitle.adjustsFontSizeToFitWidth = true
        
    }
    
    @IBAction func goBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}


