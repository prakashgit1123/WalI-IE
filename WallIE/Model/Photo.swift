//
//  Picture.swift
//  WallIE
//
//  Created by Prakash kumar sharma on 03/11/22.
//

import Foundation

struct Photo: Codable {
    let explanation: String?
    let url: String
    let title: String
    let media_type: String
}
