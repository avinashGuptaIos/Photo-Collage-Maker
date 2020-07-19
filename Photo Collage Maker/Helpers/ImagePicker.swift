//
//  ImagePicker.swift
//  Photo Collage Maker
//
//  Created by hasher on 19/07/20.
//  Copyright © 2020 Avinash. All rights reserved.
//

import Foundation
import YPImagePicker
import AVFoundation
import AVKit

let ImagePickerInstance = ImagePicker.sharedInstance

class ImagePicker {
    private init() {}
    
    static let sharedInstance = ImagePicker()
    
    func openImageVideoPicker(_ vcInstance: UIViewController, callback: @escaping (_ listOfItems: [UIImage]?) -> () )
    {
        var config = YPImagePickerConfiguration()
        config.library.mediaType = .photo  //.photoAndVideo
        config.shouldSaveNewPicturesToAlbum = false
        /* Choose the videoCompression. Defaults to AVAssetExportPresetHighestQuality */
        config.video.compression = AVAssetExportPresetMediumQuality
        config.startOnScreen = .library
        config.screens =  [.library]// [.library, .photo, .video]
        config.video.libraryTimeLimit = 500.0
        /* Adds a Crop step in the photo taking process, after filters. Defaults to .none */
        config.showsCrop = .rectangle(ratio: (16/9))
        /* Customize wordings */
        config.wordings.libraryTitle = "Gallery"
        config.hidesStatusBar = false
        config.hidesBottomBar = false
        config.library.maxNumberOfItems = 100
        config.library.skipSelectionsGallery = true
        config.showsPhotoFilters = false
        config.showsCrop = .none
        
        let picker = YPImagePicker(configuration: config)
        
        /* Multiple media implementation */
        picker.didFinishPicking { [unowned picker] items, cancelled in
            
            if cancelled {
                print("Picker was canceled")
                picker.dismiss(animated: true, completion: nil)
                return
            }
            
            var itemsList = [UIImage]()
            for item in items {
                switch item {
                case .photo(let photo):
                    print(photo)
                    itemsList.append(photo.image)
                case .video(let video):
                    print(video)
                }
            }
            
            callback(itemsList)
            
            picker.dismiss(animated: true, completion: nil)
        }
        
        vcInstance.present(picker, animated: true, completion: nil)
    }
    
}
