//
//  KeyChainManager.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 9/6/25.
//

import Security
import Foundation

enum KeychainKey {
    static let accessToken = "accessToken"
    static let refreshToken = "refreshToken"
}

final class KeychainManager {
    static let shared = KeychainManager()
    private init() {}

    func save(_ value: String, for key: String) {
        guard let data = value.data(using: .utf8) else { return }

        // 이미 있으면 삭제 후 새로 저장
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)

        let newItem: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        SecItemAdd(newItem as CFDictionary, nil)
    }

    func read(for key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

        if status == errSecSuccess,
           let data = dataTypeRef as? Data,
           let value = String(data: data, encoding: .utf8) {
            return value
        }
        return nil
    }

    func delete(for key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
    }
}

extension KeychainManager {
    var accessToken: String? {
        get { read(for: KeychainKey.accessToken) }
        set {
            if let newValue = newValue {
                save(newValue, for: KeychainKey.accessToken)
            } else {
                delete(for: KeychainKey.accessToken)
            }
        }
    }
    
    var refreshToken: String? {
        get { read(for: KeychainKey.refreshToken) }
        set {
            if let newValue = newValue {
                save(newValue, for: KeychainKey.refreshToken)
            } else {
                delete(for: KeychainKey.refreshToken)
            }
        }
    }
}
