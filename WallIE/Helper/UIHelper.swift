//
//  UIHelper.swift
//  WallIE
//
//  Created by Prakash kumar sharma on 03/11/22.
//

import Foundation

func performOnMainQueue(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}
