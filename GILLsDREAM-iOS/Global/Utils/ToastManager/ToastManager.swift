//
//  ToastManager.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 8/5/25.
//

import UIKit

final class ToastManager {
    static let shared = ToastManager()
    private init() {}
    
    func show(message: String, duration: TimeInterval = 2.0) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }
        
        let toastView = ToastView(message: message)
        window.addSubview(toastView)
        
        toastView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(window.safeAreaLayoutGuide.snp.bottom).inset(120)
            $0.leading.greaterThanOrEqualTo(window).offset(24)
            $0.trailing.lessThanOrEqualTo(window).inset(24)
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            toastView.alpha = 1.0
        }, completion: { _ in
            UIView.animate(withDuration: 0.3, delay: duration, options: [], animations: {
                toastView.alpha = 0.0
            }, completion: { _ in
                toastView.removeFromSuperview()
            })
        })
    }
}
