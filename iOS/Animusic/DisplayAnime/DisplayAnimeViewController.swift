import Foundation
import UIKit
import RxSwift
import RxCocoa
import RealmSwift
import RxDataSources

class DisplayAnimeViewController: UIViewController, SongActionPresenter {

    // MARK: - Properties
    var tableView = UITableView()
    var viewModel = DisplayAnimeViewModel()
    var searchController = UISearchController()
    let progressView = UIActivityIndicatorView()

    let navigator = Navigator.sharedInstance
    let realm = try! Realm()
    let disposeBag = DisposeBag()

    // MARK: - Functions
    static func createWith(storyboard: UIStoryboard) -> DisplayAnimeViewController {
        return storyboard.instantiateViewController(withIdentifier: "DisplayAnimeViewController") as! DisplayAnimeViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavigationController()
        setUpNavigationItem()
        setUptableView()
        setUpConstraints()
        setUpViewModelDataSource()
        if shouldDisplayEmptyBookmarksMessage() {
            displayEmptyBookmarksMessage()
        }

        view.addSubview(progressView)
        progressView.hidesWhenStopped = true
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        progressView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

        viewModel.isLoading
            .bind(to: progressView.rx.isAnimating)
            .disposed(by: disposeBag)

        viewModel.isLoading
            .bind(to: tableView.rx.isHidden)
            .disposed(by: disposeBag)

        viewModel.isReady
            .bind(to: searchController.searchBar.rx.isUserInteractionEnabled)
            .disposed(by: disposeBag)
        
        
    }

    func setUpNavigationController() {
        self.navigationController?.navigationBar.topItem?.title = "AniMusic"
    }

    func setUpNavigationItem() {
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.autocapitalizationType = .none
        searchController.searchBar.placeholder = NSLocalizedString("SearchAnime", comment: "search by anime name/song name")

        _ = searchController.searchBar.rx.text
            .orEmpty
            .debounce(.milliseconds(350), scheduler: MainScheduler.instance)
            .filter { $0.count > 0 }
            .subscribe(onNext: { string in
                self.viewModel.search(for: string)
            })

        _ = searchController.searchBar.rx.text
            .orEmpty
            .filter { $0.count == 0 }
            .subscribe(onNext: { _ in
                self.viewModel.showBookmarkedAnimes()
            })

        _ = searchController.rx.didDismiss
            .subscribe(onNext: {
                self.viewModel.showBookmarkedAnimes()
            })
            .disposed(by: disposeBag)

        self.navigationItem.searchController = searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
    }

    func setUptableView() {
        tableView.delegate = self
        view.addSubview(tableView)
        tableView.register(ResultTableViewCell.self, forCellReuseIdentifier: "ResultTableViewCell")
    }

    func setUpViewModelDataSource() {
        viewModel.sections
            .bind(to: tableView.rx.items(dataSource: viewModel.dataSource))
            .disposed(by: disposeBag)

        tableView.rx.modelSelected(SearchResult.self)
            .subscribe(onNext: { searchResult in
                if let anime = searchResult as? AnimeSeries {
                    self.navigator.show(segue: .animeSeriesViewController(anime: anime), sender: self)
                }
            })
            .disposed(by: disposeBag)

    }

    func setUpConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        let tableViewConstraints = [
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 7),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -7),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 10)
        ]
        NSLayoutConstraint.activate(tableViewConstraints)
    }

    func shouldDisplayEmptyBookmarksMessage() -> Bool {
        return UserDefaults.standard.bool(forKey: "displayEmptyBookmarksMessage") == false
    }

    func displayEmptyBookmarksMessage() {
        let ac = UIAlertController(title: "No bookmarked animes yet", message: "Animes you bookmark will be saved here", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { _ in
            UserDefaults.standard.setValue(true, forKey: "displayEmptyBookmarksMessage")
        }))
        present(ac, animated: true)
    }

}

// MARK: - UITableViewDelegate
extension DisplayAnimeViewController: UITableViewDelegate {

     func  tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 190
    }

}
