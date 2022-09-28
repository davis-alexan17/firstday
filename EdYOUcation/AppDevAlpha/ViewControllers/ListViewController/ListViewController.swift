//
//  ListViewController.swift
//  AppDevAlpha
//
//  Created by Mac User on 9/20/20.
//  Copyright © 2020 Innovation Center. All rights reserved.
//

import UIKit

class ListViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    var data: [Profile]!
    var cat: Profile?
    var noImage: [Int] = []
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = (collectionView.dequeueReusableCell(withReuseIdentifier: "ListCell", for: indexPath) as? ListCell)!
        cell.label.text = data[indexPath.row].name()
        cell.label.adjustsFontSizeToFitWidth = true
        cell.backgroundColor = UIColor(rgb: 0x862633)
        cell.layer.cornerRadius = 8
        cell.layer.masksToBounds = true
        guard let imgKey = data[indexPath.row].imgKey else {
            cell.label.frame.origin = CGPoint(x:10, y:23)
            cell.label.numberOfLines = 3
            return cell
        }
        if !imgKey.isEmpty && imgKey != "None" && imgKey != ""{
            cell.image.image = Schools_Controller.getImage(imgKey: imgKey)
            cell.layer.backgroundColor = UIColor.clear.cgColor
            cell.layer.borderWidth = 2
            cell.layer.borderColor = UIColor(rgb: 0x862633).cgColor
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "toItem", sender: indexPath.row)
    }
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var textArea: UITextView!
    @IBOutlet weak var headTitle: UILabel!
    override func viewDidLoad() {
        let d = cat!
        let imgKey = d.imgKey!
        if !imgKey.isEmpty && imgKey != "None" {
        self.image.image = Schools_Controller.getImage(imgKey: imgKey)
        }
        
        self.textArea.text = d.text()
        self.headTitle.text = d.name()
        self.headTitle.adjustsFontSizeToFitWidth = true
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let index = (sender as? Int)!
        
        if let destination = segue.destination as? ItemViewController {
            destination.data = self.data[index]
        }
    }
    
    @IBAction func goBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

}

extension ListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let _ = data[indexPath.row].imgKey else {
            return CGSize(width: 176, height: 80)

        }

            return CGSize(width: 176, height: 182)
            }
}
