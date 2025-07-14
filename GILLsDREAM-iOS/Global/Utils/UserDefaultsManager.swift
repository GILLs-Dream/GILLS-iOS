//
//  UserDefaultsManager.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 5/22/25.
//

import Foundation

final class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    private let defaults = UserDefaults.standard

    private enum Key {
        static let isLogin = "isLogin"
        static let isOnboarding = "isOnboarding"
    }

    var isLogin: Bool {
        get { defaults.bool(forKey: Key.isLogin) }
        set { defaults.set(newValue, forKey: Key.isLogin) }
    }

    var isOnboarding: Bool {
        get { defaults.bool(forKey: Key.isOnboarding) }
        set { defaults.set(newValue, forKey: Key.isOnboarding) }
    }

    private init() {}
}
