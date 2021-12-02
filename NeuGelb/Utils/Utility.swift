//
//  NeugelbColor.swift
//  NeuGelb
//
//  Created by EMRE on 1.12.2021.
//

import UIKit

struct NeugelbColor {
    static let gray = UIColor(white: 0.8, alpha: 0.7)
    static let lightGray = UIColor(white: 0.8, alpha: 0.1)
}

class AvatarImageView: UIImageView {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.cornerRadius = self.bounds.width / 2
        self.clipsToBounds = true
        self.contentMode = .scaleAspectFill
//        self.layer.addShadow(color: .black, alpha: 0.21, x: 0, y: 0, blur: 9, spread: 0)
    }
}
