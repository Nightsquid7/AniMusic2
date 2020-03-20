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

class ViewController: UIViewController {

    let firebaseStore = FirebaseStore.sharedInstance
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        _ = firebaseStore.getAnime()
            .subscribe(onSuccess: {
                print("success: \($0)")
            }, onError: {
                print("air: \($0)")
            })
            .disposed(by: disposeBag)
    }


}

