//
//  TravelRequestViewModel.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 7/15/25.
//

import UIKit
import RxSwift
import RxCocoa

final class TravelRequestViewModel {
    
    private let usecase: PlanUsecase
    
    init(usecase: PlanUsecase = PlanUsecaseImpl(repository: PlanRepositoryImpl())) {
        self.usecase = usecase
    }

    struct Input {
        let textInput: Observable<String>
        let sendButtonTapped: Observable<Void>
    }

    struct Output {
        let isSendEnabled: Driver<Bool>
        let navigateToNext: Driver<Void>
        let isLoading: Driver<Bool>
        let errorMessage: Signal<String>
        let currentStep: Driver<TravelRequestStep>
        let latestRegionText: Driver<String>
        let moodResult: Signal<PlanMood>
        let showInvalidRegionModal: Signal<Void>
    }

    private let disposeBag = DisposeBag()
    private let currentStepRelay = BehaviorRelay<TravelRequestStep>(value: .region)
    private let travelTextRelay  = BehaviorRelay<String>(value: "")
    private let isLoadingRelay   = BehaviorRelay<Bool>(value: false)
    private let errorRelay = PublishRelay<String>()
    private let navigateToNextRelay = PublishRelay<Void>()
    private let moodResultRelay = PublishRelay<PlanMood>()
    private let latestRegionRelay = BehaviorRelay<String>(value: "")
    private let showInvalidRegionModalRelay = PublishRelay<Void>()

    private var region: String = ""
    private var moodText: String = ""
    private var videoURL: String = ""
    private var planId: Int?

    func transform(input: Input) -> Output {
        input.textInput
            .bind(to: travelTextRelay)
            .disposed(by: disposeBag)
        
        input.sendButtonTapped
            .withLatestFrom(travelTextRelay)
            .flatMapLatest { [weak self] text -> Observable<Void> in
                guard let self else { return .empty() }

                switch self.currentStepRelay.value {
                case .region:
                    let region = text.trimmingCharacters(in: .whitespacesAndNewlines)

                    return RxAsync.run { [weak self] () async throws -> Void in
                        guard let self else { return }
                        await MainActor.run { self.isLoadingRelay.accept(true) }
                        defer { Task { @MainActor in self.isLoadingRelay.accept(false) } }

                        do {
                            let plan = try await self.usecase.createPlanFromRegion(region: region)
                            self.region = plan.region
                            self.planId = plan.planId
                            await MainActor.run {
                                self.latestRegionRelay.accept(region)
                                self.travelTextRelay.accept("")
                                self.currentStepRelay.accept(.mood)
                            }
                        } catch RegionError.invalidRegion {
                            await MainActor.run { self.showInvalidRegionModalRelay.accept(()) }

                        } catch let NetworkError.server(err, status) {
                            if status == 400, err.code == "INVALID REGION" {
                                throw RegionError.invalidRegion
                            }
                            throw NetworkError.server(err, status: status)
                        } catch {
                            await MainActor.run { self.errorRelay.accept(error.displayMessage) }
                        }
                    }
                    .asObservable()

                case .mood:
                    self.moodText = text.trimmingCharacters(in: .whitespacesAndNewlines)

                    return RxAsync.run { [weak self] () async throws -> Void in
                        guard let self else { return }
                        await MainActor.run { self.isLoadingRelay.accept(true) }
                        defer { Task { @MainActor in self.isLoadingRelay.accept(false) } }

                        let mood = try await self.usecase.setMood(planId: self.planId ?? 0, text: self.moodText)
                        self.moodResultRelay.accept(mood)
                        self.planId = mood.id.value
                        await MainActor.run {
                            self.travelTextRelay.accept("")
                            self.currentStepRelay.accept(.video)
                        }
                    }
                    .asObservable()
                    .catch { [weak self] error -> Observable<Void> in
                        self?.errorRelay.accept(error.displayMessage)
                        return .empty()
                    }
                
                case .video:
                    self.videoURL = text.trimmingCharacters(in: .whitespacesAndNewlines)

                    return RxAsync.run { [weak self] () async throws -> Void in
                        guard let self else { return }
                        await MainActor.run { self.isLoadingRelay.accept(true) }
                        defer { Task { @MainActor in self.isLoadingRelay.accept(false) } }

                        let urls = self.videoURL.isEmpty ? [] : [self.videoURL]

                        let ok = try await self.usecase.setVideos(
                            planId: self.planId ?? 0,
                            region: self.region,
                            urls: urls
                        )
                        if ok == false {
                            throw NSError(domain: "plan", code: -2,
                                          userInfo: [NSLocalizedDescriptionKey: "영상 등록에 실패했어요."])
                        }
                        await MainActor.run {
                            self.navigateToNextRelay.accept(())
                        }
                    }
                    .asObservable()
                    .catch { error in
                        DispatchQueue.main.async {
                            ToastManager.shared.show(message: "올바른 url주소가 아닙니다.다시 시도해주세요.")
                        }
                        return .empty()
                    }
                }
            }
            .subscribe()
            .disposed(by: disposeBag)

        return Output(
            isSendEnabled: Observable
                        .combineLatest(travelTextRelay, currentStepRelay)
                        .map { text, step in
                            if step == .video { return true }
                            return !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                        }
                        .distinctUntilChanged()
                        .asDriver(onErrorJustReturn: false),
            navigateToNext: navigateToNextRelay.asDriver(onErrorDriveWith: .empty()),
            isLoading: isLoadingRelay.asDriver(),
            errorMessage: errorRelay.asSignal(),
            currentStep: currentStepRelay.asDriver(),
            latestRegionText: latestRegionRelay.asDriver(),
            moodResult: moodResultRelay.asSignal(),
            showInvalidRegionModal: showInvalidRegionModalRelay.asSignal()
        )
    }
}
