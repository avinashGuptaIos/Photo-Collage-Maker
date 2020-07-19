//
//  ImageBackup.swift
//  Photo Collage Maker
//
//  Created by hasher on 19/07/20.
//  Copyright © 2020 Avinash. All rights reserved.
//

import Foundation
import UIKit

let ImageBackupSharedInstance = ImageBackup.shared

class ImageBackup {
    private init() {}
    static let shared = ImageBackup()
    
    func exportToUsersPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        let ac = UIAlertController(title: "Saved!", message: "Your exported image has been saved to your photos.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        APP_DELEGATE.currentViewController?.present(ac, animated: true)
    }
    
}
