//
//  MainHomeViewController.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 5/17/25.
//

import UIKit
import RxSwift

class MainHomeViewController: BaseViewController {

    // MARK: Properties
    private let disposeBag = DisposeBag()
    private let rootView = MainHomeView()
    private let viewModel = MainHomeViewModel()

    // MARK: Life Cycle
    override func loadView() {
        self.view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
