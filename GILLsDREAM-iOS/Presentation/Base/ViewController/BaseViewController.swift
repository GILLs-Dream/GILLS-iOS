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
        configureCustomNavigationBar()
        backgroundView.frame = view.bounds
        backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(backgroundView)
        view.sendSubviewToBack(backgroundView)
    }
    
    func shouldDismissWhenTapped(on view: UIView?) -> Bool {
        return true
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return shouldDismissWhenTapped(on: touch.view)
    }
}
