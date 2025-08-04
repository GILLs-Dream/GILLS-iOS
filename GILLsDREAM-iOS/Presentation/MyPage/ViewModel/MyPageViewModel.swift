//
//  MyPageViewModel.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 8/4/25.
//

import RxSwift
import RxCocoa

final class MyPageViewModel: ViewModelType {
    
    struct Input {
        let serviceTapped: Observable<Void>
        let withdrawTapped: Observable<Void>
        let logoutTapped: Observable<Void>
    }
    
    struct Output {
        let showServiceTerms: Observable<Void>
        let showWithdrawModal: Observable<Void>
        let showLogoutModal: Observable<Void>
    }
    
    var disposeBag = DisposeBag()
        
    func transform(input: Input) -> Output {
        
        return Output(
            showServiceTerms: input.serviceTapped,
            showWithdrawModal: input.withdrawTapped,
            showLogoutModal: input.logoutTapped
        )
    }
}
