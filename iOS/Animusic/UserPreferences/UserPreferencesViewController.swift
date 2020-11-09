import UIKit
import RxSwift
import RxCocoa

class UserPreferencesViewController: UIViewController {

    let viewModel = UserPreferencesViewModel()
    let tableView = UITableView()
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        view.addSubview(tableView)
        tableView.register(SourceTypeTableViewCell.self, forCellReuseIdentifier: "SourceTypeTableViewCell")

        viewModel.sections
            .bind(to: tableView.rx.items(dataSource: viewModel.dataSource))
            .disposed(by: disposeBag)

        tableView.rx.modelSelected(SourceType.self)
            .subscribe(onNext: { sourceType in
                self.viewModel.toggleSource(sourceType)
            })
            .disposed(by: disposeBag)

        tableView.rx.itemSelected
            .subscribe(onNext: { indexPath in
                let cell = self.tableView.cellForRow(at: indexPath) as! SourceTypeTableViewCell
                cell.accessoryType = self.viewModel.accessoryTypeFor(cell.sourceType)
            })
            .disposed(by: disposeBag)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        let tableViewConstraints = [
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ]

        NSLayoutConstraint.activate(tableViewConstraints)
    }

    override func viewWillAppear(_ animated: Bool) {
        print("user preferences view controller")
    }

}

extension UserPreferencesViewController: UITableViewDelegate {

}
