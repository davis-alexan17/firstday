//
//  OpenViewController.swift
//  AppDevAlpha
//
//  Created by Mac User on 9/20/20.
//  Copyright © 2020 Innovation Center. All rights reserved.
//

import UIKit
import HCVimeoVideoExtractor
import AVKit
import AVFoundation
class OpenViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate  {
    var schools: [String] = []

    @IBOutlet weak var AvPlayerViewController: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {

        Schools_Controller.findSchools(school: nil) {
            for (key, _) in Schools_Controller.schools {
                self.schools.append(key)
            }
            DispatchQueue.main.async { // Correct
               self.collectionView.reloadData()
            }
        }
        
        super.viewDidLoad()
        
        let url = URL(string: "https://vimeo.com/663068298")!
        vimeo(url: url)
    }
    
    func vimeo (url: URL) {
        HCVimeoVideoExtractor.fetchVideoURLFrom(url: url, completion: { ( video:HCVimeoVideo?, error:Error?) -> Void in
            if let err = error {
                print("Error = \(err.localizedDescription)")
                return
            }
            
            guard let vid = video else {
                print("Invalid video object")
                return
            }
            
            print("Title = \(vid.title), url = \(vid.videoURL), thumbnail = \(vid.thumbnailURL)")
            if let videoURL = vid.videoURL[.Quality1080p] {

               let player = AVPlayer(url: videoURL)

               DispatchQueue.main.async {
                   let playerController = AVPlayerViewController()
                   playerController.player = player
                   self.present(playerController, animated: true) {
                       player.play()
                   }
               }
           } else {
               print("Error: videoURL not found")
           }
        })
        
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(schools, schools.count)
        return schools.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = (collectionView.dequeueReusableCell(withReuseIdentifier: "OpenVCCell", for: indexPath) as? OpenCell)!
        cell.label.text = schools[indexPath.row]
        cell.backgroundColor = UIColor(rgb: 0x862e3d)
        cell.label.adjustsFontSizeToFitWidth = true
        let imgKey = Schools_Controller.schools[schools[indexPath.row]]!.imgKey
        if imgKey != nil && imgKey != "None" {
         cell.image.image = Schools_Controller.getImage(imgKey: imgKey!)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let school_name = (collectionView.cellForItem(at: indexPath) as? OpenCell)!.label.text!
        self.performSegue(withIdentifier: "toCategories", sender: school_name)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? CategoryViewController {
            let schoolName = (sender as? String)!
            destination.categories = Schools_Controller.schools[schoolName]?.categories
        }
    }
}

extension OpenViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 373, height: 187)
    }
}

//
//extension ClubsViewController: UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        
//        
//        let width : CGFloat = self.view.frame.width //setting how wide each cell should be (this is optimal for iPhone 8)
//        let height : CGFloat = 150 //heigh is constant. Automatically sets up the scrolling aspect of the view
//        return CGSize(width: width, height: height) //returning the final dimentions of the cell
//    }
//}
