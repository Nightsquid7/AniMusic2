//
//  FilterAnimeViewController.swift
//  iOS
//
//  Created by Steven Berkowitz on R 2/03/26.
//  Copyright © Reiwa 2 nightsquid. All rights reserved.
//

import UIKit

protocol FilterAnimeViewControllerDelegate: AnyObject {

}
class FilterAnimeViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBOutlet weak var tableView: UITableView!
    // MARK: - Properties
    weak var delegate: FilterAnimeViewControllerDelegate?


    override func viewDidLoad() {
        super.viewDidLoad()
        print("FilterAnimeViewController")

    }
    

    

}
