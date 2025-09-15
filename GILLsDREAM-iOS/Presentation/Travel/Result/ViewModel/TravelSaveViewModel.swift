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
    private let planId: Int
    private let usecase: PlanUsecase

    init(planId: Int, usecase: PlanUsecase = PlanUsecaseImpl(repository: PlanRepositoryImpl())) {
        self.planId = planId
        self.usecase = usecase
    }
    
    struct Input {
        let profileImageButtonTapped: Observable<Void>
        let travelNameInput: Observable<String>
        let saveButtonTapped: Observable<Void>
    }

    struct Output {
        let selectedImage: Driver<UIImage>
        let travelNameCountText: Driver<String>
        let isNextEnabled: Driver<Bool>
        let navigateToNext: Driver<Void>
        let isLoading: Driver<Bool>
        let errorMessage: Signal<String>
    }

    var disposeBag = DisposeBag()

    private let selectedImageRelay = PublishRelay<UIImage>()
    private let travelNameRelay = BehaviorRelay<String>(value: "")
    private let isNextEnabledRelay = BehaviorRelay<Bool>(value: false)
    private let navigateToNextRelay = PublishRelay<Void>()
    private let errorRelay = PublishRelay<String>()
    private let isLoadingRelay = BehaviorRelay<Bool>(value: false)
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

        // 다음 버튼 탭 처리
        travelNameRelay
            .map { !$0.isEmpty }
            .distinctUntilChanged()
            .bind(to: isNextEnabledRelay)
            .disposed(by: disposeBag)

        let combinedInput = Observable.combineLatest(
            travelNameRelay.asObservable(),
            selectedImageRelay
                .asObservable()
                .map { Optional($0) }
                .startWith(nil),
            isNextEnabledRelay.asObservable()
        )

        input.saveButtonTapped
            .withLatestFrom(combinedInput)
            .flatMapLatest { [weak self] name, image, enabled -> Observable<Void> in
                guard let self else { return .empty() }

                guard enabled else {
                    self.errorRelay.accept("여행이름을 입력해 주세요.")
                    return .empty()
                }
                
                return RxAsync.run { [weak self] in
                    guard let self else { return }
                    await MainActor.run { self.isLoadingRelay.accept(true) }
                    defer { Task { @MainActor in self.isLoadingRelay.accept(false) } }

                    try await self.usecase.updatePlanProfile(
                        planId: self.planId,
                        title: name,
                        imageData: image?.jpegData(compressionQuality: 0.8)
                    )
                }
                .asObservable()
                .catch { [weak self] error in
                    self?.errorRelay.accept(error.displayMessage)
                    return .empty()
                }
            }
            .bind(to: navigateToNextRelay)
            .disposed(by: disposeBag)

        return Output(
            selectedImage: selectedImageRelay
                .asDriver(onErrorDriveWith: .empty()),

            travelNameCountText: travelNameRelay
                .map { "\($0.count)/10" }
                .asDriver(onErrorJustReturn: "0/10"),
            
            isNextEnabled: isNextEnabledRelay.asDriver(onErrorJustReturn: false),
            
            navigateToNext: navigateToNextRelay
                .asDriver(onErrorDriveWith: .empty()),
            
            isLoading: isLoadingRelay.asDriver(),
            
            errorMessage: errorRelay.asSignal()
        )
    }
}
