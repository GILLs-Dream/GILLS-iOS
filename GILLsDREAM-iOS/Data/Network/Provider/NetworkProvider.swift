//
//  NetworkProvider.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 8/27/25.
//

import Foundation
import Moya

final class NetworkProvider<APIType: BaseTargetType> {
    private let moya: MoyaProvider<APIType>

    // 공용 디코더
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        // TODO: 서버 포맷 필요 시 설정
        return decoder
    }()

    init(moyaProvider: MoyaProvider<APIType>) {
        self.moya = moyaProvider
    }

    convenience init() {
        var plugins: [PluginType] = []
        #if DEBUG
        plugins.append(NetworkLoggerPlugin(configuration: .init(logOptions: .verbose)))
        #endif
        let provider = MoyaProvider<APIType>(plugins: plugins)
        self.init(moyaProvider: provider)
    }

    func request<E: Decodable>(api: APIType, dto: E.Type) async throws -> ApiResponse<E> {
        try await withCheckedThrowingContinuation { cont in
            moya.request(api) { result in
                switch result {
                case .success(let res):
                    do {
                        switch res.statusCode {
                        case 200..<300:
                            if res.data.isEmpty {
                                let emptyJSON = Data(#"{"isSuccess":true,"code":"","message":"","result":null}"#.utf8)
                                let parsed = try self.decoder.decode(ApiResponse<E>.self, from: emptyJSON)
                                cont.resume(returning: parsed)
                            } else {
                                let parsed = try self.decoder.decode(ApiResponse<E>.self, from: res.data)
                                cont.resume(returning: parsed)
                            }

                        default:
                            if let apiErr = try? self.decoder.decode(ErrorResponse.self, from: res.data) {
                                let err = ErrorResponse(code: apiErr.code ?? "",
                                                        message: apiErr.message ?? "Unknown error")
                                cont.resume(throwing: NetworkError.server(err, status: res.statusCode))
                            } else {
                                let fallback = ErrorResponse(code: "\(res.statusCode)",
                                                             message: "HTTP \(res.statusCode)")
                                cont.resume(throwing: NetworkError.server(fallback, status: res.statusCode))
                            }
                        }
                    } catch let e as DecodingError {
                        cont.resume(throwing: NetworkError.decoding(e))
                    } catch {
                        cont.resume(throwing: NetworkError.unknown(error))
                    }

                case .failure(let error):
                    cont.resume(throwing: error)
                }
            }
        }
    }
}
