//
//  DailyPictureViewModel.swift
//  WallIE
//
//  Created by Prakash kumar sharma on 03/11/22.
//

import Foundation

class NASAAPODViewModel {
    let apiClient: APIClientProtocol!
    var picture: Photo?
    
    var pictureViewModel: PhotoViewModel? {
        didSet {
            self.updatePicture?()
        }
    }
    
    var loading: Bool = false {
        didSet {
            self.updateLoading?()
        }
    }
    
    var updatePicture: (() -> ())?
    var updateLoading: (() -> ())?
    var displayError: ((_ stringError: String) -> ())?
    
    init() {
        self.apiClient = APIClient()
    }
    
    func fetchPicture() {
        self.loading = true
        
        apiClient.fetchNASAAPODPic { [weak self] completed, picture, error in
            self?.loading = false
            
            if completed {
                if let image = picture {
                    self?.pictureViewModel = self?.canonicalFrom(picture: image)
                }
            } else {
                if let errorDescription = error?.localizedDescription {
                    self?.displayError?(errorDescription)
                }
            }
        }
    }
    
    func canonicalFrom(picture: Photo) -> PhotoViewModel {
        let explanation = picture.explanation ?? ""
        let mediaType = MediaType(rawValue: picture.media_type) ?? MediaType.image
        return PhotoViewModel(url: picture.url, title: picture.title, explanation: explanation, mediaType: mediaType)
    }
}
