//
//  MovieHeaderView.swift
//  NeuGelb
//
//  Created by EMRE on 30.11.2021.
//

import UIKit


class HeaderView: UICollectionReusableView {
    
    static let supplementaryElementOfKind = "HeaderViewKind"
    static let identifier = "HeaderView"
    
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Watched"
        label.font = UIFont.systemFont(ofSize: 32)
        label.textColor = UIColor(named: "primaryDarkColor")
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(titleLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.frame = bounds
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
