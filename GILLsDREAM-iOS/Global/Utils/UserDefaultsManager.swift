//
//  UserDefaultsManager.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 5/22/25.
//

import Foundation

final class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    private let ud = UserDefaults.standard
    
    private enum Key {
        static let isLogin = "isLogin"
        static let isOnboarding = "isOnboarding"
        static let loginType = "loginType"
    }
    
    var isLogin: Bool {
        get { ud.bool(forKey: Key.isLogin) }
        set { ud.set(newValue, forKey: Key.isLogin) }
    }
    
    var isOnboarding: Bool {
        get { ud.bool(forKey: Key.isOnboarding) }
        set { ud.set(newValue, forKey: Key.isOnboarding) }
    }
    
    var loginType: String? {
        get { ud.string(forKey: Key.loginType) }
        set { ud.setValue(newValue, forKey: Key.loginType) }
    }
}
