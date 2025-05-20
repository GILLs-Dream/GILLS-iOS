//
//  BaseViewController.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 5/21/25.
//

import UIKit

class BaseViewController: UIViewController {
    private let backgroundView = BackgroundView()

    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundView.frame = view.bounds
        backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(backgroundView)
        view.sendSubviewToBack(backgroundView)
    }
}
