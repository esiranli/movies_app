//
//  MovieCardViewCell.swift
//  NeuGelb
//
//  Created by EMRE on 30.11.2021.
//

import UIKit
import SDWebImage

class VerticalMovieCardCell: UICollectionViewCell {
    
    static let identifier = "VerticalMovieCardCell"
    
    var viewModel: MovieCardViewModel! {
        didSet {
            nameLabel.text = viewModel.name
            imageView.sd_setImage(with: URL(string: "https://image.tmdb.org/t/p/w500\(viewModel.imageUrl)"))
        }
    }
    
    private lazy var imageView: AvatarImageView! = {
        let avatar = AvatarImageView()
        avatar.backgroundColor = NeugelbColor.gray
        avatar.translatesAutoresizingMaskIntoConstraints = false
        return avatar
    }()
    
    private lazy var nameLabel: UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Movie Name"
        label.numberOfLines = 2
        label.textAlignment = .center
        label.sizeToFit()
        return label
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        addSubviews()
    }
    
    init() {
        super.init(frame: .zero)
        configureView()
        addSubviews()
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        configureView()
        addSubviews()
    }
    
    func configureView() {
        self.backgroundColor = UIColor(named: "primaryColor")
        self.clipsToBounds = true
        self.layer.cornerRadius = 10.0
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 5)
        self.layer.shadowOpacity = 0.2
    }
    
    func addSubviews() {
        addSubview(imageView)
        addSubview(nameLabel)

        NSLayoutConstraint.activate(
            [
                imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
                imageView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 3/4),
                imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
                imageView.topAnchor.constraint(equalTo: topAnchor, constant: 8)
            ]
        )
        
        NSLayoutConstraint.activate(
            [
                nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8.0),
                nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8.0),
                nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
                nameLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
            ]
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isSelected: Bool {
        didSet {
            self.layer.borderColor = isSelected ? UIColor(named: "accentColor")?.cgColor : nil
            self.layer.borderWidth = isSelected ? 4.0 : 0.0
        }
    }
    
}

class HorizontalMovieCardCell: UICollectionViewCell {
    
    static let identifier = "HorizontalMovieCardCell"
    
    override var isSelected: Bool {
        didSet {
            self.layer.borderColor = isSelected ? UIColor(named: "accentColor")?.cgColor : nil
            self.layer.borderWidth = isSelected ? 4.0 : 0.0
        }
    }
    
    var viewModel: MovieCardViewModel! {
        didSet {
            nameLabel.text = viewModel.name
            imageView.sd_setImage(with: URL(string: "https://image.tmdb.org/t/p/w500\(viewModel.imageUrl)"))
        }
    }
    
    private lazy var imageView: AvatarImageView! = {
        let avatar = AvatarImageView()
//        avatar.backgroundColor = .red
        avatar.backgroundColor = UIColor(white: 0.8, alpha: 0.7)
//        avatar.contentMode = .center
        avatar.translatesAutoresizingMaskIntoConstraints = false
        return avatar
    }()
    
    private lazy var nameLabel: UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Movie Name"
        label.numberOfLines = 2
        label.textAlignment = .left
        return label
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = UIColor(named: "primaryColor")
        self.clipsToBounds = true
        self.layer.cornerRadius = 10.0
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 5)
        self.layer.shadowOpacity = 0.2
        
        addSubview(imageView)
        
        let centerYConstraint = self.imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        let widthConstraint = self.imageView.widthAnchor.constraint(equalTo: self.imageView.heightAnchor, multiplier: 1)
        let heightConstraint = self.imageView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 3/4)
        let leadingConstraint = self.imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16)
        NSLayoutConstraint.activate([centerYConstraint, widthConstraint, heightConstraint, leadingConstraint])

        self.contentView.addSubview(nameLabel)
        
        let labelLeadingConstraint = self.nameLabel.leadingAnchor.constraint(equalTo: self.imageView.trailingAnchor, constant: 16.0)
        let labelTrailingConstraint = self.nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8.0)
        let labelTopConstraint = self.nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8.0)
        let labelBottomConstraint = self.nameLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8.0)
        NSLayoutConstraint.activate([labelLeadingConstraint, labelTrailingConstraint, labelTopConstraint, labelBottomConstraint])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
