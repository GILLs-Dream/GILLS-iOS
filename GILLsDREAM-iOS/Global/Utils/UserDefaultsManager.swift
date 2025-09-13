//
//  UserDefaultsManager.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 5/22/25.
//

import Foundation

final class UserDefaultsManager {
    static let shared = UserDefaultsManager()

    private let defaults: UserDefaults
    private let queue = DispatchQueue(label: "userdefaults.manager.queue", qos: .userInitiated)

    private enum Key: String {
        case isLogin
        case isOnboarding
    }

    private init(suiteName: String? = nil) {
        if let suiteName, let ud = UserDefaults(suiteName: suiteName) {
            self.defaults = ud
        } else {
            self.defaults = .standard
        }
        registerDefaults()
    }

    private func registerDefaults() {
        defaults.register(defaults: [
            Key.isLogin.rawValue: false,
            Key.isOnboarding.rawValue: false
        ])
    }

    var isLogin: Bool {
        get { queue.sync { defaults.bool(forKey: Key.isLogin.rawValue) } }
        set { queue.async { self.defaults.set(newValue, forKey: Key.isLogin.rawValue) } }
    }

    var isOnboarding: Bool {
        get { queue.sync { defaults.bool(forKey: Key.isOnboarding.rawValue) } }
        set { queue.async { self.defaults.set(newValue, forKey: Key.isOnboarding.rawValue) } }
    }

    func resetAll() {
        queue.async {
            self.defaults.removeObject(forKey: Key.isLogin.rawValue)
            self.defaults.removeObject(forKey: Key.isOnboarding.rawValue)
            self.registerDefaults()
        }
    }
}
