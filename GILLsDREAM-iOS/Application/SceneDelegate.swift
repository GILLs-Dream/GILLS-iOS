//
//  SceneDelegate.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 5/1/25.
//

import UIKit
import KakaoSDKAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    var appCoordinator: AppCoordinator?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        
        let navigationController: UINavigationController = .init()
        navigationController.interactivePopGestureRecognizer?.isEnabled = false
        self.window?.rootViewController = navigationController
        self.window?.makeKeyAndVisible()
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.appCoordinator = AppCoordinator(navigationController)
                self.appCoordinator?.start()
            }
        }
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url {
            if (AuthApi.isKakaoTalkLoginUrl(url)) {
                _ = AuthController.handleOpenUrl(url: url)
            }
        }
    }
}
