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
        bindViewModel()
    }
    
    //MARK: View Model
    private func bindViewModel() {
        let input = MainHomeViewModel.Input(
            buttonTapped: rootView.travelButton.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output.navigateToRequest
            .drive(onNext: { [weak self] in
                guard let self = self else { return }
                let vc = TravelRequestViewController()
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)
    }
}
