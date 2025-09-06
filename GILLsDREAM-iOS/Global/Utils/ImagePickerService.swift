//
//  ImagePickerService.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 7/10/25.
//

import UIKit
import Photos
import RxSwift
import RxRelay

final class ImagePickerService: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private let imageRelay = PublishRelay<UIImage>()
    private weak var viewController: UIViewController?
    
    func present(from viewController: UIViewController) -> Observable<UIImage> {
        self.viewController = viewController
        
        return checkPermission()
            .flatMap { [weak self] granted -> Observable<UIImage> in
                guard let self = self, granted else {
                    return .empty() // 권한 거부 시 종료
                }
                DispatchQueue.main.async {
                    let picker = UIImagePickerController()
                    picker.sourceType = .photoLibrary
                    picker.delegate = self
                    viewController.present(picker, animated: true)
                }

                return self.imageRelay.asObservable()
            }
    }
    
    private func checkPermission() -> Observable<Bool> {
        return Observable.create { observer in
            let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
            switch status {
            case .authorized, .limited:
                observer.onNext(true)
                observer.onCompleted()
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization { newStatus in
                    observer.onNext(newStatus == .authorized || newStatus == .limited)
                    observer.onCompleted()
                }
            default:
                observer.onNext(false)
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        if let image = info[.originalImage] as? UIImage {
            imageRelay.accept(image)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
