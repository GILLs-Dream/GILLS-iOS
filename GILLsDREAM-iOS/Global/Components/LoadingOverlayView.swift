//
//  LoadingOverlayView.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 9/13/25.
//

import UIKit

final class LoadingOverlayView: UIView {
    static let shared = LoadingOverlayView()

    private let lottie = CustomLottieView(text: "길동이가 열심히\n여행을 생성 중이에요")

    private override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.black.withAlphaComponent(0.6)
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

    func show(in host: UIView) {
        frame = host.bounds
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        if superview == nil { host.addSubview(self) }
        lottie.startAnimating()
    }

    func hide() {
        lottie.stopAnimating()
        removeFromSuperview()
    }
}
