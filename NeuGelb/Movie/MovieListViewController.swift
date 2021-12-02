//
//  ViewController.swift
//  NeuGelb
//
//  Created by EMRE on 29.11.2021.
//

import UIKit
import Combine

enum MovieSection: Int, CustomStringConvertible {
    case favorites, watched, unwatched, count
    
    var description: String {
        switch self {
        case .favorites:
            return "Favorites"
        case .watched:
            return "Watched"
        case .unwatched:
            return "To Watch"
        default:
            return ""
        }
    }
}

class MovieListViewController: UIViewController {
    
    private let viewModel: MovieListViewModel
    private var subscriptions = Set<AnyCancellable>()
    
    init(viewModel: MovieListViewModel = MovieListViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate var watchedMovies = [Movie]() {
        didSet {
            self.reloadSection(for: MovieSection.watched)
        }
    }
    fileprivate var unwatchedMovies = [Movie]() {
        didSet {
            self.reloadSection(for: MovieSection.unwatched)
        }
    }
    fileprivate var favoriteMovies = [Movie](){
        didSet {
            self.reloadSection(for: MovieSection.favorites)
        }
    }
    
    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: self.view.bounds, collectionViewLayout: createLayout())
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.dataSource = self
        cv.delegate = self
        return cv
    } ()
    
    private lazy var nextButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(nextButtonPressed), for: .touchUpInside)
        let normalAttrString = NSAttributedString(string: "Next", attributes: [
                                                            .foregroundColor: NeugelbColor.gray,
                                                            .font : UIFont.boldSystemFont(ofSize: 24)])
        let selectedAttrString = NSAttributedString(string: "Next", attributes: [.foregroundColor : UIColor.white,
                                                                                .font : UIFont.boldSystemFont(ofSize: 24)])
        button.setAttributedTitle(normalAttrString, for: .normal)
        button.setAttributedTitle(selectedAttrString, for: .selected)
        button.isUserInteractionEnabled = false
        button.backgroundColor = UIColor(named: "primaryColor")
        button.layer.cornerRadius = 10.0
        button.layer.borderWidth = 3.0
        button.layer.borderColor = UIColor(named: "primaryDarkColor")?.cgColor
        return button
    }()
    
    private lazy var loadingView: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.isHidden = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Movies App"
        view.backgroundColor = .white

        configureCollectionView()
        addSubviews()
        setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.getMovies()
    }
    
    private func configureCollectionView() {
        collectionView.backgroundColor = .none
        
        collectionView.register(VerticalMovieCardCell.self, forCellWithReuseIdentifier: VerticalMovieCardCell.identifier)
        collectionView.register(HorizontalMovieCardCell.self, forCellWithReuseIdentifier: HorizontalMovieCardCell.identifier)
        collectionView.register(HeaderView.self, forSupplementaryViewOfKind: HeaderView.supplementaryElementOfKind, withReuseIdentifier: HeaderView.identifier)
    }
    
    private func addSubviews() {
        self.view.addSubview(nextButton)
        NSLayoutConstraint.activate([
            nextButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nextButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 3/4),
            nextButton.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -8),
            nextButton.heightAnchor.constraint(equalToConstant: 50.0)
        ])
        
        self.view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -8)
        ])
        
        self.view.addSubview(loadingView)
        NSLayoutConstraint.activate([
            loadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loadingView.heightAnchor.constraint(equalToConstant: 50),
            loadingView.widthAnchor.constraint(equalToConstant: 50)
        ])
        
    }
    
    private func setupBindings() {
        viewModel.$favoriteMovies
            .receive(on: DispatchQueue.main)
            .sink (receiveValue: { [weak self] items in
                self?.favoriteMovies = items
            })
            .store(in: &subscriptions)
        
        viewModel.$watchedMovies
            .receive(on: DispatchQueue.main)
            .sink (receiveValue: { [weak self] items in
                self?.watchedMovies = items
            })
            .store(in: &subscriptions)
        
        viewModel.$unwatchedMovies
            .receive(on: DispatchQueue.main)
            .sink (receiveValue: { [weak self] items in
                self?.unwatchedMovies = items
            })
            .store(in: &subscriptions)
        
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: handleState)
            .store(in: &subscriptions)
    }
    
    private func handleState(state: MovieListViewModelState) {
        switch state {
        case .loading:
            loadingView.isHidden = false
            loadingView.startAnimating()
            break
        case .error(let error):
            loadingView.stopAnimating()
            showError(error)
            break
        case .success:
            loadingView.stopAnimating()
            break
        }
    }
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout{ (sectionNumber, _) ->
            NSCollectionLayoutSection? in
            if sectionNumber == 0 {
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1/4), heightDimension: .fractionalHeight(1)))
                item.contentInsets.trailing = 16
                item.contentInsets.bottom = 16
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(160)), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets.leading = 16
                section.orthogonalScrollingBehavior = .continuous
                section.boundarySupplementaryItems = [
                    .init(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(50)), elementKind: HeaderView.supplementaryElementOfKind, alignment: .topLeading)
                ]
                
                return section
            }
            else if sectionNumber == 1 {
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(100)))
                item.contentInsets.bottom = 16
                item.contentInsets.trailing = 16
                let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(200)), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets.leading = 16
                section.boundarySupplementaryItems = [
                    .init(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(50)), elementKind: HeaderView.supplementaryElementOfKind, alignment: .topLeading)
                ]
                
                return section
            } else {
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(100)))
                item.contentInsets.bottom = 16
                item.contentInsets.trailing = 16
                let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(200)), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets.leading = 16
                section.boundarySupplementaryItems = [
                    .init(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(50)), elementKind: HeaderView.supplementaryElementOfKind, alignment: .topLeading)
                ]
                
                return section
            }
        }
    }
    
    @objc
    func nextButtonPressed() {
        guard let indexPath = selectedIndexPath,
              let cell = collectionView.cellForItem(at: indexPath) else { return }
            
        if let favoriteCell = cell as? VerticalMovieCardCell {
            navigateToDetailPage(viewModel: favoriteCell.viewModel)
        } else {
            let horizontalCell = cell as! HorizontalMovieCardCell
            navigateToDetailPage(viewModel: horizontalCell.viewModel)
        }
    }
    
    func navigateToDetailPage(viewModel: MovieCardViewModel) {
        self.navigationController?.pushViewController(MovieDetailViewController(viewModel: viewModel), animated: true)
    }
    
    private func showError(_ error: Error) {
        let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default) { [unowned self] _ in
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
    }
    
    private var selectedIndexPath: IndexPath?
    private var matchedIndexPath: IndexPath?
    private var selectedMovie: String?
}

extension MovieListViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        MovieSection.count.rawValue
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch (MovieSection(rawValue: section)) {
        case .favorites:
            return favoriteMovies.count
        case .watched:
            return watchedMovies.count
        case .unwatched:
            return unwatchedMovies.count
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch MovieSection(rawValue: indexPath.section) {
        case .favorites:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VerticalMovieCardCell.identifier, for: indexPath) as! VerticalMovieCardCell
            if favoriteMovies.count > 0 {
                cell.viewModel = MovieCardViewModel(movie: favoriteMovies[indexPath.row])
            }
            return cell
        case .watched:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HorizontalMovieCardCell.identifier, for: indexPath) as! HorizontalMovieCardCell
            if watchedMovies.count > 0 {
                cell.viewModel = MovieCardViewModel(movie: watchedMovies[indexPath.row])
            }
            return cell
        case .unwatched:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HorizontalMovieCardCell.identifier, for: indexPath) as! HorizontalMovieCardCell
            if unwatchedMovies.count > 0 {
                cell.viewModel = MovieCardViewModel(movie: unwatchedMovies[indexPath.row])
            }
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HorizontalMovieCardCell.identifier, for: indexPath) as! HorizontalMovieCardCell
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HeaderView.identifier, for: indexPath) as! HeaderView
        header.title = MovieSection(rawValue: indexPath.section)?.description
        return header
    }
    
    // MARK: UICollectionViewDelegate functions
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (indexPath.section == 0) {
            if let cell = collectionView.cellForItem(at: indexPath) as? VerticalMovieCardCell {
                cell.isSelected = true
                selectItem(indexPath: indexPath)
//                findMatchInUnfavorites(selected: true, viewModel: cell.viewModel)
            }
        } else if let cell = collectionView.cellForItem(at: indexPath) as? HorizontalMovieCardCell {
            cell.isSelected = true
            selectItem(indexPath: indexPath)
//            findMatchInFavorites(selected: true, viewModel: cell.viewModel)
        }
        
    }
    
    func selectItem(indexPath: IndexPath) {
        selectedIndexPath = indexPath
        nextButton.isSelected = true
        nextButton.isUserInteractionEnabled = true
        nextButton.backgroundColor = UIColor(named: "accentColor")
    }
    
    func deselectItem() {
        selectedIndexPath = nil
        nextButton.isSelected = false
        nextButton.isUserInteractionEnabled = false
        nextButton.backgroundColor = UIColor(named: "primaryColor")
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if indexPath.section == 0, let cell = collectionView.cellForItem(at: indexPath) as? VerticalMovieCardCell {
            cell.isSelected = false
            deselectItem()
//            findMatchInUnfavorites(selected: false, viewModel: cell.viewModel)
            
        } else if let cell = collectionView.cellForItem(at: indexPath) as? HorizontalMovieCardCell {
            cell.isSelected = false
            deselectItem()
//            findMatchInFavorites(selected: false, viewModel: cell.viewModel)
        }
    }
    
    private func reloadSection(for type: MovieSection) {
        self.collectionView.reloadSections(IndexSet(integer: type.rawValue))
    }
    
    func findMatchInFavorites(selected: Bool, viewModel: MovieCardViewModel) {
        matchedIndexPath = searchMatchInFavorites(viewModel: viewModel)
        if let matched = matchedIndexPath, let matchedCell = collectionView.cellForItem(at: matched) as? VerticalMovieCardCell {
            matchedCell.isSelected = selected
        }
    }
    
    func findMatchInUnfavorites(selected: Bool, viewModel: MovieCardViewModel) {
        matchedIndexPath = searchMatchInUnfavorites(viewModel: viewModel)
        if let matched = matchedIndexPath, let matchedCell = collectionView.cellForItem(at: matched) as? HorizontalMovieCardCell {
            matchedCell.isSelected = selected
        }
    }
    
    func searchMatchInFavorites(viewModel: MovieCardViewModel) -> IndexPath? {
        if let index = favoriteMovies.firstIndex(where: {$0.id == viewModel.id}) {
            return IndexPath(item: index, section: 0)
        }
        return nil
    }
    
    func searchMatchInUnfavorites(viewModel: MovieCardViewModel) -> IndexPath? {
        if let index = watchedMovies.firstIndex(where: {$0.id == viewModel.id}) {
            return IndexPath(item: index, section: 1)
        } else if let index = unwatchedMovies.firstIndex(where: {$0.id == viewModel.id}){
            return IndexPath(item: index, section: 2)
        }
        return nil
    }
}








