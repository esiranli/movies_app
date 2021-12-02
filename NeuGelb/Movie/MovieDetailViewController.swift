//
//  MovieDetailViewController.swift
//  NeuGelb
//
//  Created by EMRE on 1.12.2021.
//

import UIKit

class MovieDetailViewController: UIViewController {
    
    private var viewModel: MovieCardViewModel!
    
    init(viewModel: MovieCardViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "Movie Details"
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.layer.cornerRadius = 10.0
        containerView.clipsToBounds = true
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 5, height: 5)
        containerView.layer.shadowOpacity = 0.2
        view.addSubview(containerView)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 8),
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1/4),
            containerView.heightAnchor.constraint(equalToConstant: 150)
        ])
        
        let cardView = VerticalMovieCardCell(frame: .zero)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.viewModel = viewModel
        containerView.addSubview(cardView)
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: containerView.topAnchor),
            cardView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            cardView.widthAnchor.constraint(equalTo: containerView.widthAnchor),
            cardView.heightAnchor.constraint(equalTo: containerView.heightAnchor)
        ])
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = viewModel.description
        descriptionLabel.numberOfLines = 0
        
        let ratingLabel = UILabel()
        ratingLabel.text = "\(viewModel.rating)"
        
        let dateLabel = UILabel()
        dateLabel.text = viewModel.date
        
        let languageLabel = UILabel()
        languageLabel.text = viewModel.language
        
        
        let arrangedSubviews = [descriptionLabel, ratingLabel, dateLabel, languageLabel]
        arrangedSubviews.forEach{
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.font = UIFont.boldSystemFont(ofSize: 24)
        }
        let stackView = UIStackView(arrangedSubviews: arrangedSubviews)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.spacing = 8.0
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 32),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
        
    }
    
}
