//
//  CategoryViewController.swift
//  AppDevAlpha
//
//  Created by Mac User on 9/20/20.
//  Copyright © 2020 Innovation Center. All rights reserved.
//

import UIKit

class CategoryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    var categories: [Category]!
    var schoolName: String!
    @IBOutlet weak var schoolNameLabel: UILabel!
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = (collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as? CategoryCell)!
        cell.backgroundColor = UIColor(rgb: 0x862633)
        cell.label.baselineAdjustment = .none
        //let cellWidth = cell.frame.width // ?? collectionView.frame.width/2.01
        //let cellHeight = 150
       // let labelHeight = 25
        cell.layer.cornerRadius = 8
        cell.layer.masksToBounds = true
        schoolNameLabel.text = schoolName
      //  cell.label.frame = CGRect(x: 0, y: cellHeight-labelHeight, width: Int(cellWidth), height: labelHeight)
        cell.label.text = categories[indexPath.row].name()
        //cell.label.textAlignment = .center
        cell.label.adjustsFontSizeToFitWidth = true
        
        let imgKey = categories[indexPath.row].imgKey
        if !imgKey!.isEmpty && imgKey != "None" {
            cell.image.image = Schools_Controller.getImage(imgKey: imgKey!)
          //  cell.image.frame = CGRect(x: 0, y: 0, width: Double(cellWidth), height: Double(cellHeight-labelHeight))
        
        }
        return cell
    }
    
    
    // Determine whether to display profiles or a list of profiles
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let category_index = indexPath.row
        if categories[category_index].profiles.count == 0 {
            print("\n\n\nDEBUG STATEMENT")
            print(categories[category_index])
            
            performSegue(withIdentifier: "toItem", sender: category_index)
        } else {
            performSegue(withIdentifier: "toList", sender: category_index)
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let index = (sender as? Int)!
        
        if segue.identifier == "toList" {
            if let destination = segue.destination as? ListViewController {
                destination.data = categories[index].profiles
                let t = categories[index]
                let tempProfile = Profile(id: t.id, name_eng: t.name_eng, name_esp: t.name_esp, text_eng: t.text_eng, text_esp: t.text_esp, imgKey: t.imgKey, vimeoLink: "")
                
                destination.cat = tempProfile
            }
            return
        }
        if segue.identifier == "toItem" {
            if let destination = segue.destination as? ItemViewController {
                let t = categories[index]
                let tempProfile = Profile(id: t.id, name_eng: t.name_eng, name_esp: t.name_esp, text_eng: t.text_eng, text_esp: t.text_esp, imgKey: t.imgKey, vimeoLink: "")
                
                destination.data = tempProfile
            }
        }
    }
    
    @IBAction func goBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    

}

extension CategoryViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 176, height: 182)
        
    }
}
