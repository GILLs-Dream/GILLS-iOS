//
//  PlanRepositoryImpl.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 8/30/25.
//

import Foundation
import Moya
final class PlanRepositoryImpl: PlanRepository {
    private let provider: NetworkProvider<PlanTargetType>

    init(provider: NetworkProvider<PlanTargetType> = .init()) {
        self.provider = provider
    }

    func setMood(_ text: String) async throws -> PlanMood {
        let res: ApiResponse<MoodResultDTO> = try await provider.request(
            api: .mood(inputText: text),
            dto: MoodResultDTO.self
        )

        guard let dto = res.result else {
            let err = DecodingError.valueNotFound(
                MoodResultDTO.self,
                .init(codingPath: [], debugDescription: "ApiResponse.result is nil for MoodResultDTO")
            )
            throw NetworkError.decoding(err)
        }

        return PlanMapper.toPlanMood(from: dto)
    }

    func setVideos(planId: Int, region: String, urls: [String]) async throws -> Bool {
        let res: ApiResponse<VideosResultDTO> = try await provider.request(
            api: .videos(planId: planId,
                         region: region,
                         videoURLs: urls),
            dto: VideosResultDTO.self
        )
        return res.isSuccess
    }

    func setDuration(planId: Int, duration: Int, start: String, finish: String) async throws -> Bool {
        let res: ApiResponse<PlanIdResultDTO> = try await provider.request(
            api: .duration(planId: planId,
                           duration: duration,
                           startDate: start,
                           finishedDate: finish),
            dto: PlanIdResultDTO.self
        )
        return res.isSuccess
    }

    func setStyle(planId: Int, transport: String, categories: [String]) async throws -> Bool {
        let res: ApiResponse<PlanIdResultDTO> = try await provider.request(
            api: .style(planId: planId,
                        transport: transport,
                        categories: categories),
            dto: PlanIdResultDTO.self
        )
        return res.isSuccess
    }

    func setCompanion(planId: Int, party: Int, companion: String) async throws -> Bool {
        let res: ApiResponse<PlanIdResultDTO> = try await provider.request(
            api: .companion(planId: planId,
                            party: party,
                            companion: companion),
            dto: PlanIdResultDTO.self
        )
        return res.isSuccess
    }

    func setDestination(planId: Int,
                        travel: [TravelPlaceRequestDTO],
                        stay: [StayPlaceRequestDTO]) async throws -> Bool {
        let res: ApiResponse<PlanIdResultDTO> = try await provider.request(
            api: .destination(planId: planId,
                              travelPlaces: travel,
                              stayPlaces: stay),
            dto: PlanIdResultDTO.self
        )
        return res.isSuccess
    }
    
    func generate(planId: Int) async throws -> Plan {
        let res: ApiResponse<PlanIdResultDTO> = try await provider.request(
            api: .generate(planId: planId),
            dto: PlanIdResultDTO.self
        )

        guard let dto = res.result else {
            let err = DecodingError.valueNotFound(
                PlanIdResultDTO.self,
                .init(codingPath: [], debugDescription: "ApiResponse.result is nil for PlanIdResultDTO")
            )
            throw NetworkError.decoding(err)
        }

        // 현재 서버가 planId만 내려주는 스펙 → 최소 Plan으로 매핑
        return PlanMapper.toMinimalPlan(from: dto)
    }
}
