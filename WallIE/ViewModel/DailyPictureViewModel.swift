//
//  DailyPictureViewModel.swift
//  WallIE
//
//  Created by Prakash kumar sharma on 03/11/22.
//

import Foundation

class DailyPictureViewModel {
    let apiClient: APIClientProtocol!
    var picture: Picture?
    
    var pictureViewModel: PictureViewModel? {
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
        
        apiClient.fetchDailyPicture { [weak self] completed, picture, error in
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
    
    func canonicalFrom(picture: Picture) -> PictureViewModel {
        let explanation = picture.explanation ?? ""
        let mediaType = MediaType(rawValue: picture.media_type) ?? MediaType.image
        return PictureViewModel(url: picture.url, title: picture.title, explanation: explanation, mediaType: mediaType)
    }
}
