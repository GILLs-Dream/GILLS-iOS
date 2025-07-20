//
//  TravelWhenViewController.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 7/16/25.
//

import UIKit
import RxSwift

final class TravelWhenViewController: TravelViewController {
    // MARK: Properties
        private let disposeBag = DisposeBag()
        private let rootView = TravelWhenView()
        //private let viewModel = ProfileViewModel()
        
        
        // MARK: Life Cycle
        override func loadView() {
            self.view = rootView
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            configureCustomNavigationBar()
            bindViewModel()
        }
        
        //MARK: View Model
        private func bindViewModel() {
            rootView.headerView.currentStep = 0
        }
}

#Preview {
    TravelWhenViewController()
}
