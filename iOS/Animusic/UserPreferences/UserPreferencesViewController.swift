import UIKit

class UserPreferencesViewController: UIViewController {

    let viewModel = UserPreferencesViewModel()
    let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        view.addSubview(tableView)
        tableView.register(ResultTableViewCell.self, forCellReuseIdentifier: "ResultTableViewCell")
    }

    override func viewWillAppear(_ animated: Bool) {
        print("user preferences view controller")
    }

}

extension UserPreferencesViewController: UITableViewDelegate {

}
