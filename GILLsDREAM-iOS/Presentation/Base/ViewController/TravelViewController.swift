//
//  TravelViewController.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 7/16/25.
//

import UIKit

class TravelViewController: UIViewController {
    private let backgroundView = UIImageView(image: UIImage(named: "img_background"))

    override func viewDidLoad() {
        super.viewDidLoad()
        configureCustomNavigationBar()
        backgroundView.frame = view.bounds
        backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(backgroundView)
        view.sendSubviewToBack(backgroundView)
    }
}
