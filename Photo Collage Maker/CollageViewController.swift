//
//  CollageViewController.swift
//  Photo Collage Maker
//
//  Created by hasher on 19/07/20.
//  Copyright © 2020 Avinash. All rights reserved.
//

import UIKit

class CollageViewController: UIViewController {
    @IBOutlet weak var canvasView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = "Photo Collage Maker"
        addLeftButton(withTitle: "Add")
        addRightButton(withTitle: "Export")
//        canvasView.addInteraction(UIDropInteraction(delegate: self))
        let dragInteraction = UIDragInteraction(delegate: self)
        dragInteraction.isEnabled = true
        canvasView.addInteraction(dragInteraction)
    }
    
    
}


//MARK: UIDragInteractionDelegate
extension CollageViewController: UIDragInteractionDelegate {
    
    func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
        let touchedPoint = session.location(in: canvasView)
        if let touchedImageView = canvasView.hitTest(touchedPoint, with: nil) as? UIImageView {
            
            let touchedImage = touchedImageView.image
            
            let itemProvider = NSItemProvider(object: touchedImage!)
            let dragItem = UIDragItem(itemProvider: itemProvider)
            dragItem.localObject = touchedImageView
            return [dragItem]
        }
        
        return []
    }
    
    func dragInteraction(_ interaction: UIDragInteraction, willAnimateLiftWith animator: UIDragAnimating, session: UIDragSession) {
        animator.addCompletion { (position) in
            if position == .end {
                session.items.forEach { (dragItem) in
                    if let touchedImageView = dragItem.localObject as? UIView {
                        touchedImageView.removeFromSuperview()
                    }
                }
            }
        }
    }
    
    func dragInteraction(_ interaction: UIDragInteraction, item: UIDragItem, willAnimateCancelWith animator: UIDragAnimating) {
        canvasView.addSubview(item.localObject as! UIView)
    }
    
    func dragInteraction(_ interaction: UIDragInteraction, previewForLifting item: UIDragItem, session: UIDragSession) -> UITargetedDragPreview? {
        return UITargetedDragPreview(view: item.localObject as! UIView)
    }
}

/*
//MARK: UIDropInteractionDelegate
extension CollageViewController: UIDropInteractionDelegate
{
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        for dragItem in session.items {
            dragItem.itemProvider.loadObject(ofClass: UIImage.self, completionHandler: { (obj, err) in
                
                if let err = err {
                    print("Failed to load our dragged item:", err)
                    return
                }
                
                guard let draggedImage = obj as? UIImage else { return }
                
                DispatchQueue.main.async { [weak self] in
                    let imageView = UIImageView(image: draggedImage)
                    imageView.isUserInteractionEnabled = true
                    imageView.layer.borderWidth = 4
                    imageView.layer.borderColor = UIColor.black.cgColor
                    imageView.layer.shadowRadius = 5
                    imageView.layer.shadowOpacity = 0.3
                    self?.canvasView.addSubview(imageView)
                    imageView.frame = CGRect(x: 0, y: 0, width: draggedImage.size.width, height: draggedImage.size.height)
                    
                    let centerPoint = session.location(in: (self?.canvasView)!)
                    imageView.center = centerPoint
                }
                
            })
        }
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: UIImage.self)
    }
    
} */

//MARK: Navigation Bar Button Actions
extension CollageViewController {
    
       @objc override func leftButtonAction() {
        super.leftButtonAction()
        ImagePickerInstance.openImageVideoPicker(self) { [weak self] (images) in
            guard let imagesList = images else { return }
            DispatchQueue.main.async {
                for image in imagesList {
                let imageView = UIImageView(image: image)
                imageView.isUserInteractionEnabled = true
                imageView.layer.borderWidth = 4
                imageView.layer.borderColor = UIColor.black.cgColor
                imageView.layer.shadowRadius = 5
                imageView.layer.shadowOpacity = 0.3
                self?.canvasView.addSubview(imageView)
                    imageView.frame = CGRect(x: 0, y: 0, width: (self?.canvasView.frame.width)! * 0.5 , height: (self?.canvasView.frame.height)! * 0.3)
                 
//                let centerPoint = session.location(in: (self?.canvasView)!)
//                imageView.center = centerPoint
                }
            }
        }
       }
       
       @objc override func rightButtonAction() {
        super.rightButtonAction()
        print("rightButtonAction called")
       }
}
