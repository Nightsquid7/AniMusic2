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
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem

        print("viewDidLoad -> ResultsTableController")
        filteredAnimes = realm.objects(RealmAnimeSeries.self)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ResultTableViewCell")
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResultTableViewCell", for: indexPath)

        cell.textLabel?.text = filteredAnimes[indexPath.row].name

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("filteredAnimes[indexPath.row].name -> \(filteredAnimes[indexPath.row].name!)")
    }

}
