//
//  BaseViewController.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 5/21/25.
//

import UIKit

class BaseViewController: UIViewController {
    private let backgroundView = BackgroundView()
    private let dimView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureCustomNavigationBar()
        
        backgroundView.frame = view.bounds
        backgroundView.contentMode = .scaleAspectFill
        backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        dimView.frame = view.bounds
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        dimView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        [ backgroundView, dimView ].forEach { view.addSubview($0) }
        [ dimView, backgroundView ].forEach { view.sendSubviewToBack($0) }
    }
    
    func shouldDismissWhenTapped(on view: UIView?) -> Bool {
        return true
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return shouldDismissWhenTapped(on: touch.view)
    }
}
