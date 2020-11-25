//
//  AnimeSeriesViewController.swift
//  iOS
//
//  Created by Steven Berkowitz on R 2/03/24.
//  Copyright © Reiwa 2 nightsquid. All rights reserved.
//

import Foundation
import UIKit
import Then
import RxSwift
import RxCocoa
import RxDataSources
import Kingfisher

class AnimeSeriesViewController: UIViewController, SongActionPresenter {
    // MARK: - Properties
    lazy var imageView: UIImageView = {
        var imageView = UIImageView()
        return imageView
    }()

    lazy var seasonLabel: UILabel = {
        var label = UILabel()
        return label
    }()
    lazy var formatLabel: UILabel = {
        var label = UILabel()
        return label
    }()

    lazy var tableView: UITableView = {
        let tableView = UITableView()
        return tableView
    }()
    var bookmarkButton: UIBarButtonItem!

    var viewModel: AnimeSeriesViewModel!
    let navigator = Navigator.sharedInstance
    let disposeBag = DisposeBag()

    // MARK: - Functions
    static func createWith(storyboard: UIStoryboard, viewModel: AnimeSeriesViewModel) -> AnimeSeriesViewController {
        return (storyboard.instantiateViewController(withIdentifier: "AnimeSeriesViewController") as! AnimeSeriesViewController).then { vc in
            vc.viewModel = viewModel
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = viewModel.anime.name
        setUpBookmarkButton()
        imageView.setImage(for: viewModel.anime)
        seasonLabel.text = viewModel.anime.seasonLabel()
        formatLabel.text = NSLocalizedString(viewModel.anime.format, comment: "")
        setUpTableView()
        setUpViewModelDataSource()
        setUpTableViewCellSelectedActions()
        setUpConstraints()
    }

    func setUpBookmarkButton() {
        bookmarkButton = UIBarButtonItem(image: bookmarkButtonImage(), style: .plain, target: self, action: #selector(bookmarkButtonTapped))
        navigationItem.rightBarButtonItems = [bookmarkButton]
    }

    @objc func bookmarkButtonTapped() {
        viewModel.setBookmarked()
        bookmarkButton.image = bookmarkButtonImage()
    }

    func bookmarkButtonImage() -> UIImage {
        if viewModel.anime.bookmarked {
            return UIImage(systemName: "bookmark.fill")!
        }
        return UIImage(systemName: "bookmark")!
    }

    func setUpTableView() {
        tableView.delegate = self
        tableView.register(AnimeSongTableViewCell.self, forCellReuseIdentifier: "AnimeSongTableViewCell")
    }

    func setUpViewModelDataSource() {
        viewModel.sections
            .bind(to: tableView.rx.items(dataSource: viewModel.dataSource))
            .disposed(by: disposeBag)
    }

    func setUpTableViewCellSelectedActions() {
        // navigate to song player view
        tableView.rx.modelSelected(AnimeSongViewSection.SectionItem.self)
            .subscribe(onNext: { item in
                switch item {
                case .DefaultSongItem(let song):
                    self.presentAlertController(vc: self, song: song)
                }
            })
            .disposed(by: disposeBag)
    }

    func setUpConstraints() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        seasonLabel.translatesAutoresizingMaskIntoConstraints = false
        formatLabel.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(imageView)
        view.addSubview(seasonLabel)
        view.addSubview(formatLabel)
        view.addSubview(tableView)

        let imageViewConstraints = [
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 14),
            imageView.heightAnchor.constraint(equalToConstant: 200),
            imageView.widthAnchor.constraint(equalToConstant: 140)
        ]

        let seasonLabelConstraints = [
            seasonLabel.bottomAnchor.constraint(equalTo: formatLabel.topAnchor, constant: -20),
            seasonLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 10),
            seasonLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -5)
        ]

        let formatLabelConstraints = [
            formatLabel.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),
            formatLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 10)
        ]

        let tableViewConstraints = [
            tableView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ]

        NSLayoutConstraint.activate(imageViewConstraints)
        NSLayoutConstraint.activate(seasonLabelConstraints)
        NSLayoutConstraint.activate(formatLabelConstraints)
        NSLayoutConstraint.activate(tableViewConstraints)
    }

}

extension AnimeSeriesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

}
