//
//  RxAsync.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 9/6/25.
//

import RxSwift

public enum RxAsync {
    public static func run<T>(_ work: @escaping () async throws -> T) -> Single<T> {
        Single.create { single in
            let task = Task {
                do   { single(.success(try await work())) } //onSuccess
                catch { single(.failure(error)) } //on
            }
            return Disposables.create { task.cancel() }
        }
    }
}
