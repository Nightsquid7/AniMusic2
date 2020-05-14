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
    var filteredAnimes: Results<RealmAnimeSeries>!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
         self.clearsSelectionOnViewWillAppear = true

        filteredAnimes = realm.objects(RealmAnimeSeries.self)
        tableView.register(ResultTableViewCell.self, forCellReuseIdentifier: "ResultTableViewCell")
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {

        return filteredAnimes.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return filteredAnimes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ResultTableViewCell", for: indexPath) as? ResultTableViewCell {

            cell.configureCell(from: filteredAnimes[indexPath.row])

            return cell
        }

        return UITableViewCell()
    }

}
