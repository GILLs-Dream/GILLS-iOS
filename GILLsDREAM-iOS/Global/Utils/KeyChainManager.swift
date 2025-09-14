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
    static let appleUserId = "appleUserId"
}

final class KeychainManager {
    static let shared = KeychainManager()
    private init() {}
    
    private let queue = DispatchQueue(label: "keychain.manager.queue", qos: .userInitiated)
    
    var accessToken: String? {
        get { read(for: KeychainKey.accessToken) }
        set { if let newValue = newValue {
            _ = save(newValue, for: KeychainKey.accessToken)
        } else {
            _ = delete(for: KeychainKey.accessToken)
        }
        }
    }
    
    var refreshToken: String? {
        get { read(for: KeychainKey.refreshToken) }
        set { if let newValue = newValue {
            _ = save(newValue, for: KeychainKey.refreshToken)
        } else {
            _ = delete(for: KeychainKey.refreshToken)
        }
        }
    }
    
    var appleUserId: String? {
        get { read(for: KeychainKey.appleUserId) }
        set { if let newValue = newValue {
            _ = save(newValue, for: KeychainKey.appleUserId)
        } else {
            _ = delete(for: KeychainKey.appleUserId)
        }
        }
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
    
    // MARK: - JWT Expiry
    // access token 만료 여부
    func isAccessTokenExpired(earlyBy: TimeInterval = 0) -> Bool {
        guard let token = accessToken else { return true }
        return Self.isJWTExpired(token, earlyBy: earlyBy)
    }
    
    // 공용 JWT 만료 판별
    static func isJWTExpired(_ jwt: String, earlyBy: TimeInterval = 0) -> Bool {
        let segments = jwt.split(separator: ".")
        guard segments.count >= 2 else { return true }
        
        // Base64URL → Base64 변환
        var payload = String(segments[1])
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        let rem = payload.count % 4
        if rem > 0 { payload.append(String(repeating: "=", count: 4 - rem)) }
        
        guard let data = Data(base64Encoded: payload),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let exp = json["exp"] as? TimeInterval else {
            return true
        }
        
        let expireDate = Date(timeIntervalSince1970: exp)
        return expireDate.addingTimeInterval(-earlyBy) <= Date()
    }
    
    // MARK: - Primitive ops
    // 저장(있으면 업데이트). 접근성은 기기 잠금 해제 후 사용 가능하게 설정.
    @discardableResult
    func save(_ value: String, for key: String) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }
        
        let baseQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: Config.service,
            kSecAttrAccount as String: key
        ]
        
        // 먼저 업데이트 시도
        let updateAttrs: [String: Any] = [kSecValueData as String: data]
        let updateStatus = SecItemUpdate(baseQuery as CFDictionary, updateAttrs as CFDictionary)
        if updateStatus == errSecSuccess { return true }
        
        // 없으면 새로 추가
        var addAttrs = baseQuery
        addAttrs[kSecValueData as String] = data
        addAttrs[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock // 백그라운드 작업 고려 시 선호
        let addStatus = SecItemAdd(addAttrs as CFDictionary, nil)
        return addStatus == errSecSuccess
    }
    
    @discardableResult
    func read(for key: String) -> String? {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: Config.service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        // 성능/정확성 위해 읽기엔 접근성 옵션 굳이 필요 X
        var out: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &out)
        guard status == errSecSuccess,
              let data = out as? Data,
              let value = String(data: data, encoding: .utf8) else { return nil }
        return value
    }
    
    @discardableResult
    func delete(for key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: Config.service,
            kSecAttrAccount as String: key
        ]
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
}
