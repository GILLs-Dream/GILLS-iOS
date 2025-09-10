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
        let api: ApiResponse<MoodResultDTO> = try await provider.requestDecodable(.mood(inputText: text), as: ApiResponse<MoodResultDTO>.self)
        guard api.isSuccess, let dto = api.result else {
            throw NetworkError.server(.init(code: api.code, message: api.message), status: 200)
        }
        return PlanMapper.toPlanMood(from: dto)
    }
    
    func setVideos(planId: Int, region: String, urls: [String]) async throws -> Bool {
        let api: ApiResponse<VideosResultDTO> = try await provider.requestDecodable(.videos(planId: planId, region: region, videoURLs: urls), as: ApiResponse<VideosResultDTO>.self)
        return api.isSuccess
    }
    
    func setDuration(planId: Int, duration: Int, start: String, finish: String) async throws -> Bool {
        let api: ApiResponse<PlanIdResultDTO> = try await provider.requestDecodable(.duration(planId: planId, duration: duration, startDate: start, finishedDate: finish), as: ApiResponse<PlanIdResultDTO>.self)
        return api.isSuccess
    }
    
    func setStyle(planId: Int, transport: String, categories: [String]) async throws -> Bool {
        let api: ApiResponse<PlanIdResultDTO> = try await provider.requestDecodable(.style(planId: planId, transport: transport, categories: categories), as: ApiResponse<PlanIdResultDTO>.self)
        return api.isSuccess
    }

    func setCompanion(planId: Int, party: Int, companion: String) async throws -> Bool {
        let api: ApiResponse<PlanIdResultDTO> = try await provider.requestDecodable(.companion(planId: planId, party: party, companion: companion), as: ApiResponse<PlanIdResultDTO>.self)
        return api.isSuccess
    }

    func setDestination(planId: Int, travel: [TravelPlaceRequestDTO], stay: [StayPlaceRequestDTO]) async throws -> Bool {
        let api: ApiResponse<PlanIdResultDTO> = try await provider.requestDecodable(.destination(planId: planId, travelPlaces: travel, stayPlaces: stay), as: ApiResponse<PlanIdResultDTO>.self)
        return api.isSuccess
    }
    
    func generate(planId: Int) async throws -> Plan {
        let api: ApiResponse<PlanIdResultDTO> = try await provider.requestDecodable(.generate(planId: planId), as: ApiResponse<PlanIdResultDTO>.self)
        guard api.isSuccess, let dto = api.result else {
            throw NetworkError.server(.init(code: api.code, message: api.message), status: 200)
        }
        return PlanMapper.toMinimalPlan(from: dto)
    }

    func fetchPlanList() async throws -> [Plan] {
        let api: ApiResponse<PlanListResponseDTO> = try await provider.requestDecodable(.list, as: ApiResponse<PlanListResponseDTO>.self)
        guard api.isSuccess, let envelope = api.result else {
            throw NetworkError.server(.init(code: api.code, message: api.message), status: 200)
        }
        return envelope.planList.map(PlanMapper.toPlan(from:))
    }
}
