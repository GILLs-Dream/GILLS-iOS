//
//  TosDetailViewController.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 7/14/25.
//

import UIKit
import RxSwift

final class TosDetailViewController: UIViewController {

    
    private let rootView = TosDetailView()
    private let viewModel: TosDetailViewModel
    private let disposeBag = DisposeBag()

    init(viewModel: TosDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        self.view = rootView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
    }

    private func bindViewModel() {
        let input = TosDetailViewModel.Input(
            closeButtonTapped: rootView.closeButton.rx.tap.asObservable()
        )

        let output = viewModel.transform(input: input)

        output.title
            .drive(rootView.titleLabel.rx.text)
            .disposed(by: disposeBag)

        output.content
            .drive(rootView.contentLabel.rx.text)
            .disposed(by: disposeBag)

        output.dismiss
            .drive(onNext: { [weak self] in
                self?.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    }
}
