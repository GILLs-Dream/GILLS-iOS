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

    struct Input {
        let textInput: Observable<String>
        let sendButtonTapped: Observable<Void>
    }

    struct Output {
        let isSendEnabled: Driver<Bool>
        let navigateToNext: Driver<Void>
    }

    let disposeBag = DisposeBag()
    let currentStep = BehaviorRelay<TravelRequestStep>(value: .region)
    var region: String = ""
    var mood: String = ""
    var video: String = ""
    private let travelTextRelay = BehaviorRelay<String>(value: "")
    private let navigateToNextRelay = PublishRelay<Void>()

    func transform(input: Input) -> Output {
        input.textInput
            .bind(to: travelTextRelay)
            .disposed(by: disposeBag)
        
        input.sendButtonTapped
            .withLatestFrom(travelTextRelay)
            .do(onNext: { [weak self] text in
                guard let self = self else { return }

                switch self.currentStep.value {
                case .region:
                    self.region = text
                    self.travelTextRelay.accept("")
                    self.currentStep.accept(.mood)

                case .mood:
                    self.mood = text
                    self.travelTextRelay.accept("")
                    self.currentStep.accept(.video)
                    //TODO: 여행무드 api 연결
                case .video:
                    self.video = text
                    self.navigateToNextRelay.accept(())
                    //TODO: 지역, 유튜브링크 전송 api 연결
                }
            })
            .subscribe()
            .disposed(by: disposeBag)

        return Output(
            isSendEnabled: travelTextRelay
                .map { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
                .distinctUntilChanged()
                .asDriver(onErrorJustReturn: false),

            navigateToNext: navigateToNextRelay
                .asDriver(onErrorDriveWith: .empty())
        )
    }
}
