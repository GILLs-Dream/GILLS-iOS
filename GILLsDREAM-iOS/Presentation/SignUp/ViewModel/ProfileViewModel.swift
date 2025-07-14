//
//  ProfileViewModel.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 7/10/25.
//

import UIKit
import RxSwift
import RxCocoa

final class ProfileViewModel: ViewModelType {

    struct Input {
        let profileImageButtonTapped: Observable<Void>
        let nicknameInput: Observable<String>
        let duplicateCheckTapped: Observable<Void>
        let nextButtonTapped: Observable<Void>
    }

    struct Output {
        let selectedImage: Driver<UIImage>
        let nicknameCountText: Driver<String>
        let duplicateResult: Driver<Bool>
        let navigateToNext: Driver<Void>
    }

    var disposeBag = DisposeBag()
    private let selectedImageRelay = PublishRelay<UIImage>()
    private let nicknameRelay = BehaviorRelay<String>(value: "")
    private let isNicknameAvailableRelay = PublishRelay<Bool?>()
    private let navigateToNextRelay = PublishRelay<Void>()
    private let imagePickerService = ImagePickerService()

    func transform(input: Input) -> Output {
        // 이미지 피커
        input.profileImageButtonTapped
                .flatMapLatest { [weak self] _ -> Observable<UIImage> in
                    guard let self = self,
                          let topVC = UIApplication.shared.topMostViewController() else {
                        return .empty()
                    }
                    return self.imagePickerService.present(from: topVC)
                }
                .bind(to: selectedImageRelay)
                .disposed(by: disposeBag)

        // 입력 제한
        input.nicknameInput
            .bind(to: nicknameRelay)
            .disposed(by: disposeBag)

        // 중복확인 버튼 탭 처리
        input.duplicateCheckTapped
            .withLatestFrom(nicknameRelay)
            .flatMapLatest { nickname in
                return Observable<Bool>.just(true) // 임시
                    .delay(.milliseconds(300), scheduler: MainScheduler.instance)
            }
            .bind(to: isNicknameAvailableRelay)
            .disposed(by: disposeBag)
        
        // 다음 버튼 탭 처리
        input.nextButtonTapped
            .bind(to: navigateToNextRelay)
            .disposed(by: disposeBag)

        return Output(
            selectedImage: selectedImageRelay
                .asDriver(onErrorDriveWith: .empty()),

            nicknameCountText: nicknameRelay
                .map { "\($0.count)/10" }
                .asDriver(onErrorJustReturn: "0/10"),
            
            duplicateResult: isNicknameAvailableRelay
                .compactMap { $0 }
                .asDriver(onErrorJustReturn: false),
            
            navigateToNext: navigateToNextRelay
                .asDriver(onErrorDriveWith: .empty())
        )
    }
}
