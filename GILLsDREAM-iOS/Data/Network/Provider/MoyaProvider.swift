//
//  MoyaProvider.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 8/28/25.
//

import Moya

extension MoyaProvider {
  func asyncRequest(_ target: Target) async throws -> Response {
    try await withCheckedThrowingContinuation { cont in
      self.request(target) { result in
        switch result {
        case .success(let res): cont.resume(returning: res)
        case .failure(let err): cont.resume(throwing: err)
        }
      }
    }
  }
}
