//
//  TravelSaveViewModel.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 8/11/25.
//

import UIKit
import RxSwift
import RxCocoa

final class TravelSaveViewModel: ViewModelType {

    struct Input {
        let profileImageButtonTapped: Observable<Void>
        let travelNameInput: Observable<String>
        let saveButtonTapped: Observable<Void>
    }

    struct Output {
        let selectedImage: Driver<UIImage>
        let nicknameCountText: Driver<String>
        let navigateToNext: Driver<Void>
        let showToast: Signal<String>
    }

    var disposeBag = DisposeBag()

    private let selectedImageRelay = PublishRelay<UIImage>()
    private let travelNameRelay = BehaviorRelay<String>(value: "")
    private let navigateToNextRelay = PublishRelay<Void>()
    private let toastRelay = PublishRelay<String>()
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

        // 여행이름 입력
        input.travelNameInput
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .bind(to: travelNameRelay)
            .disposed(by: disposeBag)

        // 유효성 체크 후 네비게이트 or 토스트
        input.saveButtonTapped
            .withLatestFrom(travelNameRelay)
            .subscribe(onNext: { [weak self] name in
                guard let self = self else { return }
                if name.isEmpty {
                    self.toastRelay.accept("여행 이름을 입력해 주세요.")
                } else {
                    self.navigateToNextRelay.accept(())
                }
            })
            .disposed(by: disposeBag)

        return Output(
            selectedImage: selectedImageRelay
                .asDriver(onErrorDriveWith: .empty()),

            nicknameCountText: travelNameRelay
                .map { "\($0.count)/10" }
                .asDriver(onErrorJustReturn: "0/10"),

            navigateToNext: navigateToNextRelay
                .asDriver(onErrorDriveWith: .empty()),

            showToast: toastRelay
                .asSignal()
        )
    }
}
