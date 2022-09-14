//
//  CategoryViewController.swift
//  AppDevAlpha
//
//  Created by Mac User on 9/20/20.
//  Copyright © 2020 Innovation Center. All rights reserved.
//

import UIKit
import HCVimeoVideoExtractor
import AVFoundation
import AVKit
class Slide: UIView {
}


class ItemViewController: UIViewController, UIScrollViewDelegate{
    var data: Profile?
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var viewArea: UIScrollView!
    @IBOutlet weak var textArea: UITextView!
    @IBOutlet weak var headTitle: UILabel!
    //@IBOutlet weak var AvPlayerViewController: UIView!
    //var pageControl : UIPageControl = UIPageControl(frame: CGRect(x: 175, y: 330, width: 200, height: 20))
    var slides:[Slide] = [];
    var player : AVPlayer = AVPlayer();
    var avpController = AVPlayerViewController()
    var vimURL : URL!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewArea.delegate = self
        let d = data!
        let imgKey = d.imgKey
        
        
        self.textArea.text = d.text()
        self.headTitle.text = d.name()
        self.headTitle.adjustsFontSizeToFitWidth = true
        slides = createSlides()
        setupSlideScrollView(slides: slides)
        viewArea.showsHorizontalScrollIndicator = false
        viewArea.bounces = false
        pageControl.numberOfPages = slides.count
        pageControl.currentPage = 0
        pageControl.isUserInteractionEnabled = false
        view.bringSubviewToFront(pageControl)
        player.play()
        
       // let url = URL(string: "https://vimeo.com/663068298")!
        //vimeo(url: url)

        
    }
    func createSlides() -> [Slide] {
        let d = data!
        let imgKey = d.imgKey
        
        let imgSlide:Slide = Bundle.main.loadNibNamed("Slide", owner:self, options:nil)?.first as! Slide
        if imgKey != nil && imgKey != "None"{
            let image = Schools_Controller.getImage(imgKey: imgKey!)
            let imageView = UIImageView(image: image!)
            imageView.frame = CGRect(x:0, y:0, width:viewArea.frame.size.width, height:viewArea.frame.size.height)
            imgSlide.addSubview(imageView)
            
        }
        let vidSlide:Slide = Bundle.main.loadNibNamed("Slide", owner:self, options:nil)?.first as! Slide
        if !d.vimeoLink!.isEmpty{
           
            HCVimeoVideoExtractor.fetchVideoURLFrom(url: URL(string: d.vimeoLink!)!, completion: { [self] ( video:HCVimeoVideo?, error:Error?) -> Void in
                if let err = error {
                    print("Error = \(err.localizedDescription)")
                    return
                }
                
                guard let vid = video else {
                    print("Invalid video object")
                    return
                }
                
                print("Title = \(vid.title), url = \(vid.videoURL), thumbnail = \(vid.thumbnailURL)")
                //set up to detect resolutions
                if let videoURL = vid.videoURL[.Quality360p] {
                    player = AVPlayer(url: videoURL)
                    DispatchQueue.main.async { [self] in
                    avpController.player = player
                        avpController.view.frame.size.height = viewArea.frame.size.height
                        avpController.view.frame.size.width = viewArea.frame.size.width
                    //avpController.view.frame = viewArea.frame
                    self.addChild(avpController)
                    vidSlide.addSubview(avpController.view)
                    }
                   
               } else {
                   print("Error: videoURL not found")
               }
            })
            //might cause issues with incorrect video url
            return [imgSlide, vidSlide]
            
        }
        else{
            return [imgSlide]
        }
        
        
    }
    func setupSlideScrollView(slides: [Slide]){
        viewArea.contentSize = CGSize(width: viewArea.frame.size.width * CGFloat(slides.count), height: viewArea.frame.size.height)
        viewArea.isPagingEnabled = true
        
        for i in 0 ..< slides.count{
            slides[i].frame = CGRect(x:viewArea.frame.size.width * CGFloat(i), y:0, width:viewArea.frame.size.width, height:viewArea.frame.size.height)
            viewArea.addSubview(slides[i])
        }
    }
    //makes page index change based on current page
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(viewArea.contentOffset.x/viewArea.frame.size.width)
        pageControl.currentPage = Int(pageIndex)
    }

    @IBAction func goBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}


