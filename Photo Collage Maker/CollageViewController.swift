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
        self.title = "Photo Collage Maker"
        addLeftButton(withTitle: "Add")
        addRightButton(withTitle: "Export")
        canvasView.addInteraction(UIDropInteraction(delegate: self))
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
    
    func dragInteraction(_ interaction: UIDragInteraction, previewForLifting item: UIDragItem, session: UIDragSession) -> UITargetedDragPreview? {
        return UITargetedDragPreview(view: item.localObject as! UIView)
    }
}


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
                    guard let imageView = self?.createImageViewAndAddItOnCanvas(image: draggedImage) else {return}
                    
                    //------------We can apply the scaling, rotation to individual image by selecting them, but for now, i am doing it just for reference like this, later on we can give the feature to select the image from list & then apply scaling, rotation. ------//
                    var transform = CGAffineTransform.identity
                    transform = transform.rotated(by: CGFloat.pi/3)
                    transform = transform.scaledBy(x: 0.8, y: 0.8)
                    imageView.transform = transform
                    //-------------------------------------------------//
                    
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
    
}

//MARK: Navigation Bar Button Actions
extension CollageViewController {
    
    @objc override func leftButtonAction() {
        super.leftButtonAction()
        ImagePickerInstance.openImageVideoPicker(self) { [weak self] (images) in
            guard let imagesList = images else { return }
            DispatchQueue.main.async {
                for image in imagesList {
                    self?.createImageViewAndAddItOnCanvas(image: image)
                }
            }
        }
    }
    
    @objc override func rightButtonAction() {
        super.rightButtonAction()
        UIGraphicsBeginImageContext(canvasView.frame.size)
        canvasView.layer.render(in: UIGraphicsGetCurrentContext()!)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return }
        UIGraphicsEndImageContext()
        ImageBackupSharedInstance.exportToUsersPhotoAlbum(image: image)
    }

    @discardableResult
    func createImageViewAndAddItOnCanvas(image: UIImage) -> UIImageView {
        let imageView = UIImageView(image: image)
        imageView.isUserInteractionEnabled = true
        imageView.layer.borderWidth = 4
        imageView.layer.borderColor = UIColor.black.cgColor
        imageView.layer.shadowRadius = 5
        imageView.layer.shadowOpacity = 0.3
        canvasView.addSubview(imageView)
        imageView.frame = CGRect(x: CGFloat.random(in: 0 ... (canvasView.frame.width) * 0.5), y: CGFloat.random(in: 0 ... (canvasView.frame.height) * 0.7), width: (canvasView.frame.width) * 0.5 , height: (canvasView.frame.height) * 0.3)
        
        addTapGestureOnView(view: imageView)
        
        return imageView
    }
    
    func addTapGestureOnView(view: UIView){
        //-----------Add tap gesture-------------------//
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(CollageViewController.imageViewTapped(_:)))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        view.addGestureRecognizer(tapGesture)
        //--------------------------------------------//
    }
    
    @objc func imageViewTapped(_ sender: UITapGestureRecognizer) {

    if canvasView.backgroundColor == UIColor.yellow {
        canvasView.backgroundColor = UIColor.green
    }else{
        canvasView.backgroundColor = UIColor.yellow
    }
}
}
