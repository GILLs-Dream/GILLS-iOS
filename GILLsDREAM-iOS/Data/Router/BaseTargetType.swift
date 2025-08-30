//
//  BaseTargetType.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 8/27/25.
//

import Foundation
import Moya

public protocol BaseTargetType: TargetType {}

public extension BaseTargetType {
    var baseURL: URL { Config.baseURL }
    
    var headers: [String : String]? {
        return ["Content-type": "application/json"]
    }
    
    var validationType: ValidationType {
        return .successCodes
    }
}
