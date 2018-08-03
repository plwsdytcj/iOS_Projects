//
//  RatingControl.swift
//  helloios
//
//  Created by Chengjie Lin on 12/14/17.
//  Copyright © 2017 Chengjie Lin. All rights reserved.
//

import UIKit

@IBDesignable class RatingControl: UIStackView {
    @IBInspectable var starSize: CGSize = CGSize(width: 44.0, height: 44.0)
    @IBInspectable var starCount: Int = 5

    override init(frame: CGRect) {
        super.init(frame: frame)
         setupButtons()
    }
    required init(coder: NSCoder) {
        super.init(coder: coder)
         setupButtons()
    }
    //MARK: Button Action
    @objc func ratingButtonTapped(button: UIButton) {
        print("Button pressed ")
    }
    //MARK: Private Methods
    private func setupButtons() {
        let button = UIButton()
        button.backgroundColor = UIColor.red
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
        button.widthAnchor.constraint(equalToConstant: 44.0).isActive = true
     button.addTarget(self, action: #selector(RatingControl.ratingButtonTapped(button:)), for: .touchUpInside)
         addArrangedSubview(button)
        
    }

 

}
