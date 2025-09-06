//
//  Config.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 8/26/25.
//

import Foundation

enum Config {
    enum Keys {
        enum Plist {
            static let baseURL = "BASE_URL"
        }
    }
    
    private static let infoDictionary: [String: Any] = {
        guard let dict = Bundle.main.infoDictionary else {
            fatalError("plist cannot found.")
        }
        return dict
    }()
    
    static let service: String = {
        let base = Bundle.main.bundleIdentifier ?? "com.gillsdream.ios"
        return base + ".keychain"
    }()
}

extension Config {
    static let baseURL: URL = {
        guard let key = Config.infoDictionary[Keys.Plist.baseURL] as? String,
              let url = URL(string: key) else {
            fatalError("Base URL is not set in plist for this configuration.")
        }
        return url
    }()
}
