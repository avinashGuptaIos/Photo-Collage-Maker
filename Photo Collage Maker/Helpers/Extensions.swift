//
//  Extensions.swift
//  Photo Collage Maker
//
//  Created by hasher on 19/07/20.
//  Copyright © 2020 Avinash. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func addLeftButton(withTitle leftButtonTitle: String) {
        let leftButton = UIBarButtonItem(title: leftButtonTitle, style: .plain, target: self, action: #selector(leftButtonAction))
        navigationItem.leftBarButtonItem = leftButton
    }
      
   
    func addRightButton(withTitle rightButtonTitle: String) {
        let rightButton = UIBarButtonItem(title: rightButtonTitle, style: .plain, target: self, action: #selector(rightButtonAction))
        navigationItem.rightBarButtonItem = rightButton
    }
      
    @objc func leftButtonAction() {
        
    }
    
    @objc func rightButtonAction() {
           
    }
}
