//
//  CustomPopOverView.swift
//  Photo Collage Maker
//
//  Created by hasher on 20/07/20.
//  Copyright © 2020 Avinash. All rights reserved.
//

import UIKit
import KUIPopOver
import CoreImage

public protocol CustomPopOverViewDelegate: class{
    func sliderValueDidChange(sender: UISlider!, handlingView: UIView)
}


class CustomPopOverView: UIView, KUIPopOverUsable {
    
    weak var delegate: CustomPopOverViewDelegate?
    var currentFilter: CIFilter!
    var handlingView: UIView?
    
    public var popOverBackgroundColor: UIColor? {
        return .white
    }
    
    public var arrowDirection: UIPopoverArrowDirection {
        return .up
    }
    
    
    public init(frame: CGRect, selectedFilter: CIFilter, handlingView: UIView?) {
        super.init(frame: frame)
        if let _ = handlingView {
            currentFilter = selectedFilter
            self.handlingView = handlingView
            setupViews(selectedFilterText: selectedFilter.name)
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews(selectedFilterText: String) {
        let selectedFilterLabel = UILabel()
        selectedFilterLabel.text = selectedFilterText
        selectedFilterLabel.backgroundColor = UIColor.clear
        selectedFilterLabel.textAlignment = .center
        
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 10
        slider.isContinuous = true
        slider.tintColor = UIColor.blue
        slider.value = 0
        slider.addTarget(self, action: #selector(sliderValueDidChange(sender:)),for: .valueChanged)
        slider.widthAnchor.constraint(equalToConstant: 120).isActive = true
        
        
        //Stack View
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.spacing = 8
        stackView.addArrangedSubview(selectedFilterLabel)
        stackView.addArrangedSubview(slider)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        
        
        //Layout for Stack View
        stackView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    @objc func sliderValueDidChange(sender: UISlider!)
    {
        if let handlingViewx = handlingView {
            delegate?.sliderValueDidChange(sender: sender, handlingView: handlingViewx)
        }
    }
}
