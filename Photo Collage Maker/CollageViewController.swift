//
//  CollageViewController.swift
//  Photo Collage Maker
//
//  Created by hasher on 19/07/20.
//  Copyright © 2020 Avinash. All rights reserved.
//

import UIKit
import CoreImage

class CollageViewController: UIViewController {
    @IBOutlet weak var canvasView: UIView!
    @IBOutlet weak var filterButtonOutlet: UIButton!
    var currentFilter: CIFilter!
    let context = CIContext()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Photo Collage Maker"
        addLeftButton(withTitle: "Add")
        addRightButton(withTitle: "Export")
        canvasView.addInteraction(UIDropInteraction(delegate: self))
        let dragInteraction = UIDragInteraction(delegate: self)
        dragInteraction.isEnabled = true
        canvasView.addInteraction(dragInteraction)
        currentFilter = CIFilter(name: "CIBumpDistortion")
        filterButtonOutlet.setTitle(currentFilter.name, for: .normal)
    }
    
    //MARK: Setup types of Image Filter
    @IBAction func filterButtonAction(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Choose filter", message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "CIBumpDistortion", style: .default, handler: setFilter))
        alertController.addAction(UIAlertAction(title: "CIGaussianBlur", style: .default, handler: setFilter))
        alertController.addAction(UIAlertAction(title: "CIPixellate", style: .default, handler: setFilter))
        alertController.addAction(UIAlertAction(title: "CISepiaTone", style: .default, handler: setFilter))
        alertController.addAction(UIAlertAction(title: "CITwirlDistortion", style: .default, handler: setFilter))
        alertController.addAction(UIAlertAction(title: "CIUnsharpMask", style: .default, handler: setFilter))
        alertController.addAction(UIAlertAction(title: "CIVignette", style: .default, handler: setFilter))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true)
    }
    
    
    func setFilter(action: UIAlertAction) {
        filterButtonOutlet.setTitle(action.title, for: .normal)
        currentFilter = CIFilter(name: action.title!)
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
}

//MARK: Some Common Methods
extension CollageViewController {
    
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
        
        addGesturesOnView(view: imageView)
        
        return imageView
    }
    
    func addGesturesOnView(view: UIView){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageViewTappedForImageProcessing(_:)))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        view.addGestureRecognizer(tapGesture)
        
        let rotateGesture = UIRotationGestureRecognizer(target: self, action: #selector(imageViewRotationForRotationEffect(_:)))
        view.addGestureRecognizer(rotateGesture)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(imageViewPinchForScalingEffect(_:)))
          view.addGestureRecognizer(pinchGesture)
        
        let swipeRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(imageViewSwipeForAddingText(_:)))
        let swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(imageViewSwipeForAddingText(_:)))
        swipeRightGesture.direction = .right
        swipeLeftGesture.direction = .left
        view.addGestureRecognizer(swipeRightGesture)
        view.addGestureRecognizer(swipeLeftGesture)
    }
    
    //MARK: Gestures Action

    @objc func imageViewTappedForImageProcessing(_ sender: UITapGestureRecognizer) {
        if let gestureAttachedView = sender.view,
            let imageView = gestureAttachedView as? UIImageView
        {
            let customView = CustomPopOverView(frame: CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: CGSize(width: 150.0, height: 100.0)), selectedFilter: currentFilter, handlingView: gestureAttachedView)
            customView.delegate = self
            customView.showPopover(sourceView: gestureAttachedView)

            let beginImage = CIImage(image: imageView.image!)
            currentFilter.setValue(beginImage, forKey: kCIInputImageKey)

            applyProcessing(imageView: imageView)
        }
    }
    
    @objc func imageViewRotationForRotationEffect(_ sender: UIRotationGestureRecognizer) {
        if let gestureAttachedView = sender.view,
            sender.state == .changed
        {
            let transform = CGAffineTransform(rotationAngle: sender.rotation)
            gestureAttachedView.transform = transform
        }
    }
    
    @objc func imageViewPinchForScalingEffect(_ sender: UIPinchGestureRecognizer) {
        if let gestureAttachedView = sender.view,
            sender.state == .changed
        {
            let transform = CGAffineTransform(scaleX: sender.scale, y: sender.scale)
            gestureAttachedView.transform = transform
        }
    }
    
    @objc func imageViewSwipeForAddingText(_ sender: UISwipeGestureRecognizer) {
        if let gestureAttachedView = sender.view,
        sender.direction == .right || sender.direction == .left  {
            let alertController = UIAlertController(title: "Enter your text", message: nil, preferredStyle: .alert)
            alertController.addTextField()

            let okAction = UIAlertAction(title: "Ok", style: .default) { _ in
                if let text = alertController.textFields![0].text,
                text.count > 0 {
                  _ = gestureAttachedView.subviews.map{$0.removeFromSuperview()}
                let label = UILabel()
                label.textColor = .white
                label.textAlignment = .center
                label.font = .boldSystemFont(ofSize: 12)
                label.text = text
                gestureAttachedView.addSubview(label)
                gestureAttachedView.addConstraints("H:|-[v0]-|", constraintViews: [label])
                gestureAttachedView.addConstraints("V:|-[v0]-|", constraintViews: [label])
                }
            }

            alertController.addAction(okAction)
            if let label = gestureAttachedView.subviews.first as? UILabel, label.text!.count > 0 {
                alertController.addAction(UIAlertAction(title: "Remove text", style: .cancel){ _ in
                    _ = gestureAttachedView.subviews.map{$0.removeFromSuperview()}
                })
            }
            
            present(alertController, animated: true)
        }
    }
    
    func applyProcessing(value: Float = 0, imageView: UIImageView) {
        guard let currentImage = imageView.image else { return }
        DispatchQueue.global().async { [weak self] in
            let inputKeys = self?.currentFilter.inputKeys
            
            if inputKeys?.contains(kCIInputIntensityKey) ?? false { self?.currentFilter.setValue(value, forKey: kCIInputIntensityKey) }
            if inputKeys?.contains(kCIInputRadiusKey) ?? false { self?.currentFilter.setValue(value * 200, forKey: kCIInputRadiusKey) }
            if inputKeys?.contains(kCIInputScaleKey) ?? false { self?.currentFilter.setValue(value * 10, forKey: kCIInputScaleKey) }
            if inputKeys?.contains(kCIInputCenterKey) ?? false { self?.currentFilter.setValue(CIVector(x: currentImage.size.width / 2, y: currentImage.size.height / 2), forKey: kCIInputCenterKey) }
            
            if let outputImage = self?.currentFilter.outputImage ,
                let cgimg = self?.context.createCGImage(outputImage, from: outputImage.extent) {
                let processedImage = UIImage(cgImage: cgimg)
                DispatchQueue.main.async {
                    imageView.image = processedImage
                }
            }
        }
    }
}

//MARK: CustomPopOverViewDelegate
extension CollageViewController: CustomPopOverViewDelegate{
    func sliderValueDidChange(sender: UISlider!, handlingView: UIView) {
        if let imageView = handlingView as? UIImageView {
            applyProcessing(value: sender.value, imageView: imageView)
        }
    }
}
