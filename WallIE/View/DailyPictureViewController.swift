//
//  DailyPictureViewController.swift
//  WallIE
//
//  Created by Prakash kumar sharma on 03/11/22.
//

import UIKit
import SDWebImage
import Network

class DailyPictureViewController: UIViewController {

    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var fullScreenView: UIView!
    @IBOutlet var fullScreenImageView: UIImageView!
    @IBOutlet var fullScreenDetails: UIView!
    @IBOutlet var explanationTextView: UITextView!
    @IBOutlet var errorLabel: UILabel!
    var originalImage: UIImage!
    let monitor = NWPathMonitor()
    let queue = DispatchQueue(label: "InternetConnectionMonitor")
    
    
    lazy var dailyPictureViewModel: DailyPictureViewModel = {
        return DailyPictureViewModel()
    }()
    
    //MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        monitor.pathUpdateHandler = { pathUpdateHandler in
            performOnMainQueue {
                if pathUpdateHandler.status == .satisfied {
                    print("Internet connection is on.")
                    self.errorLabel.isHidden = true
                    self.explanationTextView.isHidden = false
                } else {
                    self.explanationTextView.isHidden = true
                    self.errorLabel.isHidden = false
                    print("There's no internet connection.")
                }
            }
        }
        monitor.start(queue: queue)
        configureViewModel()
        configureFullScreen()
    }
    
    //MARK: ViewModel Configuration
    func configureViewModel() {
        self.dailyPictureViewModel.updateLoading = { [weak self] () in
            performOnMainQueue {
                if (self?.dailyPictureViewModel.loading)! {
                    self?.activityIndicator.startAnimating()
                } else {
                    self?.activityIndicator.stopAnimating()
                }
            }
        }
        
        self.dailyPictureViewModel.updatePicture = { [weak self] () in
            self?.loadImage()
            self?.loadTitle()
        }
        
        self.dailyPictureViewModel.displayError = { [weak self] (errrorMessage) in
            self?.showAlert(message: errrorMessage)
        }
        
        dailyPictureViewModel.fetchPicture()
    }
    
    //MARK: UI Configuration Methods
    func loadImage() {
        if let urlStr = self.dailyPictureViewModel.pictureViewModel?.url {
            self.imageView.sd_setImage(with: URL(string: urlStr),
                                       completed: { (image, error, cacheType, url) in
                                        if error == nil && image != nil {
                                            self.originalImage = image
                                            self.imageView.image = self.fixedImageAspectRatio(image: image!,
                                                                                              imageView: self.imageView)
                                            performOnMainQueue {
                                                UIView.animate(withDuration: 0.35,
                                                               animations: {
                                                                self.imageView.alpha = 1.0
                                                }, completion: { (completion) in
                                                    self.imageView.isUserInteractionEnabled = true
                                                    self.activityIndicator.stopAnimating()
                                                })
                                            }
                                        }
            })
        }
    }
    
    func loadTitle() {
        if let title = self.dailyPictureViewModel.pictureViewModel?.title {
            performOnMainQueue {
                self.titleLabel.text = title
                UIView.animate(withDuration: 0.35, animations: {
                    self.titleLabel.alpha = 1.0
                })
            }
        }
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        performOnMainQueue {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func fixedImageAspectRatio(image: UIImage, imageView: UIView) -> UIImage {
        let aspectRatio = image.size.width/image.size.height
        let newImage = image.resizeImage(imageView.frame
            .size.height, aspectRatio: aspectRatio, opaque: true)
        
        return newImage
    }
    
    func configureFullScreen() {
        let tapImage = UITapGestureRecognizer(target: self, action: #selector(DailyPictureViewController.imageTapped))
        self.imageView.addGestureRecognizer(tapImage)
        
        if self.originalImage != nil {
            self.fullScreenImageView.image = fixedImageAspectRatio(image: self.originalImage,
                                                                   imageView: self.fullScreenImageView)
        }
        
        let tapFullScreenImage = UITapGestureRecognizer(target: self,
                                                        action: #selector(DailyPictureViewController.fullScreenImageTapped))
        let tapFullDetails = UITapGestureRecognizer(target: self,
                                                    action: #selector(DailyPictureViewController.fullScreenImageTapped))
        
        self.fullScreenImageView.addGestureRecognizer(tapFullScreenImage)
        self.fullScreenDetails.addGestureRecognizer(tapFullDetails)
    }
}

//MARK: Gesture actions
extension DailyPictureViewController {
    @objc func imageTapped(sender: UITapGestureRecognizer) {
        self.showFullScreenView()
    }
    
    @objc func fullScreenImageTapped(sender: UITapGestureRecognizer) {
        self.showFullScreenImageDetails()
    }
}

//MARK: Full Screen
extension DailyPictureViewController {
    func showFullScreenView() {
        if self.fullScreenImageView.image == nil {
            performOnMainQueue {
                self.fullScreenImageView.image = self.fixedImageAspectRatio(image: self.originalImage,
                                                                            imageView: self.fullScreenView)
                guard let pictureViewModel = self.dailyPictureViewModel.pictureViewModel else {
                    return
                }
                
                let explanation = pictureViewModel.explanation ?? ""
                self.explanationTextView.text = "\(pictureViewModel.title)\n\n" +
                "\(explanation)"
            }
        }
        
        performOnMainQueue {
            UIView.animate(withDuration: 0.35, animations: {
                self.fullScreenView.alpha = 1.0
            })
        }
    }
    
    func showFullScreenImageDetails() {
        let alpha: CGFloat = self.fullScreenDetails.alpha == 1.0 ? 0.0 : 1.0
        performOnMainQueue {
            UIView.animate(withDuration: 0.35, animations: {
                self.fullScreenDetails.alpha = alpha
            })
        }
    }
}
