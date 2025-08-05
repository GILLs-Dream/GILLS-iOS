//
//  UIViewController.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 7/10/25.
//

import UIKit

extension UIViewController {
    /// 네비게이션 바 커스텀 설정: 백버튼 숨김, 틴트 컬러 흰색
    func configureCustomNavigationBar(
        title: String? = nil,
        titleColor: UIColor = .white,
        backgroundColor: UIColor = .clear,
        tintColor: UIColor = .white
    ) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = backgroundColor
        appearance.titleTextAttributes = [.foregroundColor: titleColor]
        appearance.shadowColor = .clear

        let hidesBackTitle = title == nil

        if hidesBackTitle {
            let backAppearance = UIBarButtonItemAppearance()
            backAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
            appearance.backButtonAppearance = backAppearance
        }

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.tintColor = tintColor

        if let title = title {
            self.title = title
        }
    }
}
