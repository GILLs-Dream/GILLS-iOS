//
//  LoadingOverlayView.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 9/13/25.
//

import UIKit

final class LoadingOverlayView: UIView {
    static let shared = LoadingOverlayView()

    private let lottie = CustomLottieView(text: "길동이가 열심히\n여행을 생성 중이에요\n(최대 1분 소요)")
    private var backgroundAlpha: CGFloat = 0.6
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.black.withAlphaComponent(backgroundAlpha)
        addSubview(lottie)
        lottie.translatesAutoresizingMaskIntoConstraints = false
        lottie.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        layer.zPosition = 9999 // 탭바보다 위에 확실히 올라오게
        isUserInteractionEnabled = true // 터치 차단
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    func show(in host: UIView, alpha: CGFloat? = nil) {
        if let alpha = alpha {
            backgroundAlpha = alpha
        }
        backgroundColor = UIColor.black.withAlphaComponent(backgroundAlpha)
        
        frame = host.bounds
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        if superview !== host {
            removeFromSuperview()
            host.addSubview(self)
        }
        lottie.startAnimating()
    }
    

    func hide() {
        lottie.stopAnimating()
        removeFromSuperview()
    }
    
    func updateText(_ text: String) {
        lottie.updateText(text)
    }
}
