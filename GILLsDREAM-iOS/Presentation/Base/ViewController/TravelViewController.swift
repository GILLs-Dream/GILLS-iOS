//
//  TravelViewController.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 7/16/25.
//

import UIKit

class TravelViewController: UIViewController, UIGestureRecognizerDelegate {
    private let backgroundView = UIImageView(image: .background)

    override func viewDidLoad() {
        super.viewDidLoad()
        configureCustomNavigationBar()
        backgroundView.frame = view.bounds
        backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(backgroundView)
        view.sendSubviewToBack(backgroundView)
    }
    
    @objc func dismissKeyboardAndPickers() {
        view.endEditing(true)
    }

    func setupTapToDismissAllInputs() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboardAndPickers))
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        true
    }
}
