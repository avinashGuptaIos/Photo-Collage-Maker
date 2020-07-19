//
//  NavigationController.swift
//  Photo Collage Maker
//
//  Created by hasher on 19/07/20.
//  Copyright © 2020 Avinash. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController, UINavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }

    
      //MARK:- For UINavigationControllerDelegate
      
      func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
          APP_DELEGATE.currentViewController = viewController
      }
}
