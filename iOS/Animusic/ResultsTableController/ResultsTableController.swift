//
//  ResultsTableController.swift
//  iOS
//
//  Created by Steven Berkowitz on 2020/05/13.
//  Copyright © 2020 nightsquid. All rights reserved.
//

import UIKit
import RealmSwift

class ResultsTableController: UITableViewController {

    let realm = try! Realm()
    var searchResults: [SearchResult] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        clearsSelectionOnViewWillAppear = true
        tableView.register(ResultTableViewCell.self, forCellReuseIdentifier: "ResultTableViewCell")
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ResultTableViewCell", for: indexPath) as? ResultTableViewCell {
            cell.configureCell(from: searchResults[indexPath.row])
            return cell
        }

        return UITableViewCell()
    }

}   
