//
//  UIImage+.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 9/11/25.
//

import UIKit

extension UIImage {
    // 긴 변을 maxDimension 이하로 리사이즈 후, JPEG 압축하여 maxKB 이하로 맞춰 Data 반환
    func jpegDataSmart(maxDimension: CGFloat = 2048,
                       maxKB: Int = 800,
                       initialQuality: CGFloat = 0.9) -> Data? {

        let target = resizedSizeKeepingAspect(maxLongSide: maxDimension)
        let resized = (size == target) ? self : drawResized(to: target)

        var quality = initialQuality
        let minQuality: CGFloat = 0.4
        let step: CGFloat = 0.1
        let limit = maxKB * 1024

        var data = resized.jpegData(compressionQuality: quality)
        while let d = data, d.count > limit, quality > minQuality {
            quality -= step
            data = resized.jpegData(compressionQuality: quality)
        }
        return data
    }

    private func resizedSizeKeepingAspect(maxLongSide: CGFloat) -> CGSize {
        let w = size.width, h = size.height
        let long = max(w, h)
        guard long > maxLongSide, long > 0 else { return size }
        let scale = maxLongSide / long
        return .init(width: floor(w * scale), height: floor(h * scale))
    }

    private func drawResized(to newSize: CGSize) -> UIImage {
        let fmt = UIGraphicsImageRendererFormat.default()
        fmt.scale = 1
        return UIGraphicsImageRenderer(size: newSize, format: fmt).image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
