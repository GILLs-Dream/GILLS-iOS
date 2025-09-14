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
            static let appKey = "APP_KEY"
            static let appName = "APP_NAME"
        }
    }
    
    private static let infoDictionary: [String: Any] = {
        guard let dict = Bundle.main.infoDictionary else {
            fatalError("plist cannot found.")
        }
        return dict
    }()
    
    static let service: String = {
        let base = Bundle.main.bundleIdentifier ?? "com.sammy.GILLsDREAM-iOS"
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

    static let appKey: String = {
        guard let key = Config.infoDictionary[Keys.Plist.appKey] as? String else {
            fatalError("APP_KEY is not set in plist for this configuration.")
        }
        return key
    }()
    
    static let appName: String = {
        guard let key = Config.infoDictionary[Keys.Plist.appName] as? String else {
            fatalError("APP_NAME is not set in plist for this configuration.")
        }
        return key
    }()
}
