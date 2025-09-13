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

    private let queue = DispatchQueue(label: "keychain.manager.queue", qos: .userInitiated)

    var accessToken: String? {
        get { read(for: KeychainKey.accessToken) }
        set { newValue != nil ? save(newValue!, for: KeychainKey.accessToken) : delete(for: KeychainKey.accessToken) }
    }
    var refreshToken: String? {
        get { read(for: KeychainKey.refreshToken) }
        set { newValue != nil ? save(newValue!, for: KeychainKey.refreshToken) : delete(for: KeychainKey.refreshToken) }
    }

    func setTokens(access: String, refresh: String) {
        queue.sync {
            save(access, for: KeychainKey.accessToken)
            save(refresh, for: KeychainKey.refreshToken)
        }
    }
    
    func clearTokens() {
        queue.sync {
            delete(for: KeychainKey.accessToken)
            delete(for: KeychainKey.refreshToken)
        }
    }
    
    func isAccessTokenExpired(earlyBy: TimeInterval = 0) -> Bool {
        guard let token = accessToken else { return true }

        let segments = token.split(separator: ".")
        guard segments.count >= 2 else { return true }

        let payloadSegment = segments[1]
        var padded = String(payloadSegment)
        // Base64 padding
        let rem = padded.count % 4
        if rem > 0 {
            padded.append(String(repeating: "=", count: 4 - rem))
        }

        guard let data = Data(base64Encoded: padded),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let exp = json["exp"] as? TimeInterval else {
            return true
        }

        let expireDate = Date(timeIntervalSince1970: exp)
        let now = Date()
        // earlyBy 초 전부터 만료로 간주
        return expireDate.addingTimeInterval(-earlyBy) <= now
    }
    
    func save(_ value: String, for key: String) {
        guard let data = value.data(using: .utf8) else { return }

        // 이미 있으면 삭제 후 새로 저장
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: Config.service,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)

        let newItem: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: Config.service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        SecItemAdd(newItem as CFDictionary, nil)
    }

    func read(for key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: Config.service,
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
            kSecAttrService as String: Config.service,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
    }
}
