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
    private let flowViewModel: SignupFlowViewModel
    
    init(flowViewModel: SignupFlowViewModel) {
        self.flowViewModel = flowViewModel
    }

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
        let isNextEnabled: Driver<Bool>
        let navigateToNext: Driver<Void>
        let errorMessage: Signal<String>
    }

    var disposeBag = DisposeBag()
    private let selectedImageRelay = PublishRelay<UIImage>()
    private let nicknameRelay = BehaviorRelay<String>(value: "")
    private let isNicknameAvailableRelay = PublishRelay<Bool?>()
    private let isNextEnabledRelay = BehaviorRelay<Bool>(value: false)
    private let navigateToNextRelay = PublishRelay<Void>()
    private let errorRelay = PublishRelay<String>()
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
            .do(onNext: { [weak self] in self?.isNextEnabledRelay.accept(!$0.trimmingCharacters(in: .whitespaces).isEmpty) })
            .bind(to: nicknameRelay)
            .disposed(by: disposeBag)

        // 중복확인 버튼 탭 처리
//        input.duplicateCheckTapped
//            .withLatestFrom(nicknameRelay)
//            .flatMapLatest { nickname in
//                return Observable<Bool>.just(true) // 임시
//                    .delay(.milliseconds(300), scheduler: MainScheduler.instance)
//            }
//            .bind(to: isNicknameAvailableRelay)
//            .disposed(by: disposeBag)
        
        // 다음 버튼 탭 처리
        let isNextEnabledObs = nicknameRelay
            .map { !$0.isEmpty }
            .distinctUntilChanged()

        input.nextButtonTapped
            .withLatestFrom(Observable.combineLatest(nicknameRelay.asObservable(),
                                                     selectedImageRelay.asObservable().map { Optional($0) }.startWith(nil),
                                                     isNextEnabledRelay.asObservable()))
            .subscribe(onNext: { [weak self] nickname, image, enabled in
                guard let self else { return }
                guard enabled else {
                    self.errorRelay.accept("닉네임을 입력해 주세요.")
                    return
                }
                    self.navigateToNextRelay.accept(())
                    self.flowViewModel.nickname = nickname.trimmingCharacters(in: .whitespaces)
                    self.flowViewModel.profileImage = image
                })
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
            
            isNextEnabled: isNextEnabledObs.asDriver(onErrorJustReturn: false),
            
            navigateToNext: navigateToNextRelay
                .asDriver(onErrorDriveWith: .empty()),
            
            errorMessage: errorRelay.asSignal()
        )
    }
}
