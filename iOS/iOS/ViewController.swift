//
//  ViewController.swift
//  iOS
//
//  Created by Steven Berkowitz on R 2/03/20.
//  Copyright © Reiwa 2 nightsquid. All rights reserved.
//

import UIKit
import FirebaseFirestore
import RxSwift
import RxCocoa
import RealmSwift
import RxRealm

class ViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!

    @IBOutlet weak var tableView: UITableView!


    let firebaseStore = FirebaseStore.sharedInstance
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        let realm  = try! Realm()
        let animes = realm.objects(RealmAnimeSeries.self).sorted(byKeyPath: "name")


        searchBar.scopeButtonTitles = ["Anime Name","Song Name"]

        searchBar.rx.textDidBeginEditing
            .subscribe(onNext: {
                self.searchBar.showsCancelButton = true
                self.searchBar.showsScopeBar = true
            })
            .disposed(by: disposeBag)

        searchBar.rx.searchButtonClicked
            .subscribe(onNext: {

                print("search button was tapped")
            })
            .disposed(by: disposeBag)

        searchBar.rx.cancelButtonClicked
            .subscribe(onNext:  {
                self.searchBar.showsCancelButton = false
                self.searchBar.showsScopeBar = true
                self.searchBar.resignFirstResponder()
            })
            .disposed(by: disposeBag)


        Observable.collection(from: animes)
            .bind(to: tableView.rx.items(cellIdentifier: "AnimeCell", cellType: UITableViewCell.self)) { _, element, cell in
                    cell.textLabel?.text = element.name!
            }
            .disposed(by: disposeBag)


//        _ = firebaseStore.getAnime()
//            .subscribe(onSuccess: {
//                print("success: \($0)")
//            }, onError: {
//                print("air: \($0)")
//            })
//            .disposed(by: disposeBag)
    }


}

