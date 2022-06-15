////
////  SamplePersonViewController.swift
////  AppDevAlpha
////
////  Created by Paul Hollingshead on 1/23/20.
////  Copyright © 2020 Innovation Center. All rights reserved.
////
//
//import UIKit
//
//class SamplePersonViewController: UIViewController {
//
//    var data =  HomoSapiens(eltitKey: "Mr", eman: "James Robinson", picName: "jrobinson.jpg", bioKey: "jrobinson", address: "robinson_james@svvsd.org")
//    
//    @IBOutlet var personNameTitle: UILabel!
//    
//    @IBOutlet var personPicture: UIImage!
//        
//    @IBOutlet var personBio: UILabel!
//    
//    @IBOutlet var personEmail: UILabel!
//    
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        let titleKey = data.titleKey
//        
//        let title = NSLocalizedString(titleKey, comment:   "Mr. or Senor")
//        
//        let name = data.personName
//
//        personNameTitle.text! = title + " " + name
//        
//        personPicture = UIImage(contentsOfFile: data.personPictureName)
//        
//        personBio!.text = NSLocalizedString(data.personBioKey, comment: "Bio in your choice of language")
//        
//        personEmail.text! = data.personEmail
//    }
//    
//}
