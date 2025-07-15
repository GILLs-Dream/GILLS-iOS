//
//  UIFont+.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 5/14/25.
//

import UIKit

extension UIFont {
    enum Pretendard {
        case thin
        case extraLight
        case light
        case regular
        case medium
        case semibold
        case bold
        case extrabold
        case black
        
        var name: String {
            switch self {
            case .thin: return "Pretendard-Thin"
            case .extraLight: return "Pretendard-ExtraLight"
            case .light: return "Pretendard-Light"
            case .regular: return "Pretendard-Regular"
            case .medium: return "Pretendard-Medium"
            case .semibold: return "Pretendard-SemiBold"
            case .bold: return "Pretendard-Bold"
            case .extrabold: return "Pretendard-ExtraBold"
            case .black: return "Pretendard-Black"
            }
        }
    }
    
    static func pretendard(_ weight: Pretendard, size: CGFloat) -> UIFont {
        return UIFont(name: weight.name, size: size) ?? UIFont.systemFont(ofSize: size)
    }
}

extension UIFont {
    enum PretendardStyle {
        case extratitle1
        case extratitle2
        case title1
        case title2
        case title3
        case title4
        case subtitle1
        case subtitle2
        case subtitle3
        case subtitle4
        case subtitle5
        case body0
        case body1
        case body2
        case body3
        case smalltext
        
        var font: UIFont {
            switch self {
            case .extratitle1: return UIFont.pretendard(.semibold, size: 36)
            case .extratitle2: return UIFont.pretendard(.light, size: 36)
            case .title1: return UIFont.pretendard(.semibold, size: 30)
            case .title2: return UIFont.pretendard(.medium, size: 30)
            case .title3: return UIFont.pretendard(.regular, size: 30)
            case .title4: return UIFont.pretendard(.extraLight, size: 30)
            case .subtitle1: return UIFont.pretendard(.semibold, size: 24)
            case .subtitle2: return UIFont.pretendard(.medium, size: 24)
            case .subtitle3: return UIFont.pretendard(.regular, size: 24)
            case .subtitle4: return UIFont.pretendard(.light, size: 24)
            case .subtitle5: return UIFont.pretendard(.semibold, size: 18)
            case .body0: return UIFont.pretendard(.semibold, size: 16)
            case .body1: return UIFont.pretendard(.medium, size: 14)
            case .body2: return UIFont.pretendard(.medium, size: 12)
            case .body3: return UIFont.pretendard(.medium, size: 12)
            case .smalltext: return UIFont.pretendard(.medium, size: 8)
            }
        }
        
        var lineHeight: CGFloat {
            switch self {
            case .title4:
                return 120
            default:
                return 140
            }
        }
        
        var kern: CGFloat {
            0
        }
    }
}
