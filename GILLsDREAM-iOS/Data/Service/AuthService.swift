//
//  AuthService.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 9/13/25.
//

import Foundation

final class AuthService {
    static let shared = AuthService()
    private init() {}

    private let publicProvider = Providers.memberPublic
    private let tokenStore = KeychainManager.shared

    
    func reissue(completion: @escaping (Bool) -> Void) {
        guard let refresh = tokenStore.refreshToken, !refresh.isEmpty else {
            completion(false); return
        }

        publicProvider.request(.reissue(refreshToken: refresh)) { result in
            switch result {
            case .success(let res):
                guard (200..<300).contains(res.statusCode) else {
                    if res.statusCode == 401 || res.statusCode == 403 {
                        self.forceLogout()
                    }
                    completion(false); return
                }
                do {
                    let dec = JSONDecoder()
                    let dto = try dec.decode(ReissueResponseDTO.self, from: res.data)
                    self.tokenStore.setTokens(access: dto.access_token, refresh: dto.refresh_token)
                    completion(true)
                } catch {
                    completion(false)
                }
            case .failure:
                completion(false)
            }
        }
    }
    
    func reissueLegacy(_ completion: @escaping (Bool) -> Void) {
        guard let refresh = KeychainManager.shared.refreshToken, !refresh.isEmpty else {
            completion(false); return
        }
        publicProvider.request(.reissue(refreshToken: refresh)) { result in
            switch result {
            case .success(let res) where (200..<300).contains(res.statusCode):
                do {
                    let dec = JSONDecoder()
                    let dto = try dec.decode(ReissueResponseDTO.self, from: res.data)
                    KeychainManager.shared.setTokens(access: dto.access_token, refresh: dto.refresh_token)
                    completion(true)
                } catch { completion(false) }
            default:
                completion(false)
            }
        }
    }
    
    func forceLogout() {
        tokenStore.clearTokens()
        KeychainManager.shared.accessToken = nil
        KeychainManager.shared.refreshToken = nil
        UserDefaultsManager.shared.isLogin = false
        NotificationCenter.default.post(name: .needReLogin, object: nil)
    }
}
