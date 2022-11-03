//
//  APIClient.swift
//  WallIE
//
//  Created by Prakash kumar sharma on 03/11/22.
//

import Foundation
import Alamofire


enum ClientConstants: String {
    case dailyPictureURL = "https://api.nasa.gov/planetary/apod"
    case apiKey = "lQ3CFIdAuqFcm4bvHRFNDoN5iC09nXdCmb9de2gL"
}

struct CustomError {
    var localizedDescription: String?
}

protocol APIClientProtocol {
    func fetchNASAAPODPic(onCompletion: @escaping (_ completed: Bool, _ picture: Photo?, _ error: CustomError?) -> Void)
}


class APIClient: APIClientProtocol {
    func fetchNASAAPODPic(onCompletion: @escaping (_ completed: Bool, _ picture: Photo?, _ error: CustomError?) -> Void) {
        if let url = URL(string: "\(ClientConstants.dailyPictureURL.rawValue)?api_key=\(ClientConstants.apiKey.rawValue)") {
            AF.request(url)
                .validate(statusCode: [200,202])
                .validate(contentType: ["application/json"])
                .responseData { response in
                    switch response.result {
                    case .success:
                        if let data = response.value {
                            do {
                                let picture = try JSONDecoder().decode(Photo.self, from: data)
                                onCompletion(true, picture, nil)
                            } catch (let e) {
                                let e = self.handleError(error: e)
                                onCompletion(false, nil, e)
                            }
                        }
                    case .failure(let error):
                        let e = self.handleError(error: error)
                        onCompletion(false, nil, e)
                    }
            }
        }
    }
    
    private func handleError(error: Error) -> CustomError {
        return CustomError(localizedDescription: error.localizedDescription)
    }
}
