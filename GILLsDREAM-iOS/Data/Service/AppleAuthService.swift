//
//  AppleAuthService.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 9/14/25.
//

import AuthenticationServices

final class AppleAuthService: NSObject {
    static let shared = AppleAuthService()
    private var continuation: CheckedContinuation<String, Error>?
    
    // 🍎 애플 로그인 시도 후 Identity Token 반환
    func fetchIdentityToken() async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            
            // 로그인 요청 객체
            let provider = ASAuthorizationAppleIDProvider()
            let request = provider.createRequest()
            request.requestedScopes = [.fullName, .email]
            
            // 로그인 요청 컨트롤러
            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            controller.presentationContextProvider = self
            controller.performRequests()
        }
    }
}

extension AppleAuthService: ASAuthorizationControllerDelegate {
    // 🍎 로그인 성공 시 호출
    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {

        case let appleIdCredential as ASAuthorizationAppleIDCredential:
            // 항상 오는 고유 식별자
            let userIdentifier = appleIdCredential.user
            KeychainManager.shared.appleUserId = userIdentifier

            // 첫 로그인(동의)일 때만 제공
            let fullName  = appleIdCredential.fullName
            let email     = appleIdCredential.email
            let authCode  = appleIdCredential.authorizationCode // 서버에서 검증용으로 쓰기도 함

            // identityToken(Data) -> String
            if let tokenData = appleIdCredential.identityToken,
               let tokenString = String(data: tokenData, encoding: .utf8) {
                // print("🍎 Apple identityToken: \(tokenString.prefix(30))...")
                continuation?.resume(returning: tokenString)
                continuation = nil
            } else { // 토큰이 없으면 에러 리턴
                continuation?.resume(
                    throwing: NSError(domain: "AppleAuth",
                                      code: -1,
                                      userInfo: [NSLocalizedDescriptionKey: "identityToken이 없습니다."])
                )
                continuation = nil
            }
//            if let email { print("email: \(email)") }
//            if let fullName { print("fullName: \(PersonNameComponentsFormatter().string(from: fullName))") }
//            if let authCode, let codeStr = String(data: authCode, encoding: .utf8) {
//                print("authorizationCode: \(codeStr.prefix(20))...")
//            }

        case let passwordCredential as ASPasswordCredential:
            // iCloud 키체인
            let userIdentifier = passwordCredential.user
            let password = passwordCredential.password
            // print("🔑 iCloud Keychain credential – user: \(userIdentifier), pw: \(password)")
            continuation?.resume(
                throwing: NSError(domain: "AppleAuth",
                                  code: -2,
                                  userInfo: [NSLocalizedDescriptionKey: "iCloud 자격 증명은 미지원"])
            )
            continuation = nil

        default:
            continuation?.resume(
                throwing: NSError(domain: "AppleAuth",
                                  code: -3,
                                  userInfo: [NSLocalizedDescriptionKey: "지원하지 않는 credential 타입"])
            )
            continuation = nil
        }
    }
    
    // 🍎  로그인 실패 시 호출
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        continuation?.resume(throwing: error)
        continuation = nil
    }
}

extension AppleAuthService: ASAuthorizationControllerPresentationContextProviding {
    // 로그인 UI를 띄울 window
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = scene.windows.first(where: { $0.isKeyWindow }) {
            return window
        }
        return ASPresentationAnchor()
    }
}
