//
//  PictureViewModel.swift
//  WallIE
//
//  Created by Prakash kumar sharma on 03/11/22.
//

import Foundation

enum MediaType: String { case image = "image", video = "video" }

struct PictureViewModel {
    var url: String
    var title: String
    var explanation: String?
    var mediaType: MediaType
}
