//
//  PlanRepositoryImpl.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 8/30/25.
//

import Foundation
import Moya

final class PlanRepositoryImpl: PlanRepository {
    private let provider = Providers.plan
    
    func setMood(_ text: String) async throws -> PlanMood {
        let api: ApiResponse<MoodResultDTO> = try await provider.requestDecodableAutoRefresh(.mood(inputText: text), as: ApiResponse<MoodResultDTO>.self)
        guard api.isSuccess, let dto = api.result else {
            throw NetworkError.server(.init(code: api.code, message: api.message), status: 200)
        }
        return PlanMapper.toPlanMood(from: dto)
    }
    
    func setVideos(planId: Int, region: String, urls: [String]) async throws -> Bool {
        let api: ApiResponse<VideosResultDTO> = try await provider.requestDecodableAutoRefresh(.videos(planId: planId, region: region, videoURLs: urls), as: ApiResponse<VideosResultDTO>.self)
        return api.isSuccess
    }
    
    func setDuration(planId: Int, duration: Int, start: String, finish: String) async throws -> Bool {
        let api: ApiResponse<PlanIdResultDTO> = try await provider.requestDecodableAutoRefresh(.duration(planId: planId, duration: duration, startDate: start, finishedDate: finish), as: ApiResponse<PlanIdResultDTO>.self)
        return api.isSuccess
    }
    
    func setStyle(planId: Int, transport: String, categories: [String]) async throws -> Bool {
        let api: ApiResponse<PlanIdResultDTO> = try await provider.requestDecodableAutoRefresh(.style(planId: planId, transport: transport, categories: categories), as: ApiResponse<PlanIdResultDTO>.self)
        return api.isSuccess
    }

    func setCompanion(planId: Int, party: Int, companion: String) async throws -> Bool {
        let api: ApiResponse<PlanIdResultDTO> = try await provider.requestDecodableAutoRefresh(.companion(planId: planId, party: party, companion: companion), as: ApiResponse<PlanIdResultDTO>.self)
        return api.isSuccess
    }

    func setDestination(planId: Int, travel: [TravelPlaceRequestDTO], stay: [StayPlaceRequestDTO]) async throws -> Bool {
        let api: ApiResponse<PlanIdResultDTO> = try await provider.requestDecodableAutoRefresh(.destination(planId: planId, travelPlaces: travel, stayPlaces: stay), as: ApiResponse<PlanIdResultDTO>.self)
        return api.isSuccess
    }
    
    func fetchPlanList() async throws -> [Plan] {
        let api: ApiResponse<PlanListResponseDTO> = try await provider.requestDecodableAutoRefresh(.list, as: ApiResponse<PlanListResponseDTO>.self)
        guard api.isSuccess, let envelope = api.result else {
            throw NetworkError.server(.init(code: api.code, message: api.message), status: 200)
        }
        return envelope.planList.map(PlanMapper.toPlan(from:))
    }
    
    func generatePlan(planId: Int) async throws {
        let api: ApiResponse<PlanIdResultDTO> = try await provider.requestDecodableAutoRefresh(
            .generate(planId: planId),
            as: ApiResponse<PlanIdResultDTO>.self
        )
        guard api.isSuccess else {
            throw NetworkError.server(.init(code: api.code, message: api.message), status: 200)
        }
    }

    func fetchGeneratedPlan(planId: Int) async throws -> PlanResultResponseDTO {
        let api: ApiResponse<PlanResultResponseDTO> = try await provider.requestDecodableAutoRefresh(
            .fetchGeneratedPlan(planId: planId),
            as: ApiResponse<PlanResultResponseDTO>.self
        )
        guard api.isSuccess, let dto = api.result else {
            throw NetworkError.server(.init(code: api.code, message: api.message), status: 200)
        }
        return dto
    }

    func fetchGeneratedPlanSummary(planId: Int) async throws -> PlanSummaryResponseDTO {
        let api: ApiResponse<PlanSummaryResponseDTO> = try await provider.requestDecodableAutoRefresh(
            .fetchGeneratedPlanSummary(planId: planId),
            as: ApiResponse<PlanSummaryResponseDTO>.self
        )
        guard api.isSuccess, let dto = api.result else {
            throw NetworkError.server(.init(code: api.code, message: api.message), status: 200)
        }
        return dto
    }
}
