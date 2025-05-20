//
//  ViewModelType.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 5/21/25.
//

import RxSwift

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    
    var disposeBag: DisposeBag { get set }
    
    func transform(input: Input) -> Output
}
