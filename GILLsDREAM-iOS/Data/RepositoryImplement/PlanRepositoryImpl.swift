//
//  PlanRepositoryImpl.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 8/30/25.
//

import Foundation
import Moya

final class PlanRepositoryImpl: PlanRepository {
    private let publicProvider = Providers.planPublic
    private let provider = Providers.planUser
    
    func setRegion(region: String) async throws -> RegionResultDTO {
        do { let api: ApiResponse<RegionResultDTO> = try await provider.requestDecodableAutoRefresh( .region(region: region),
                                                                                                     as: ApiResponse<RegionResultDTO>.self)
            
            guard api.isSuccess, let dto = api.result else {
                throw RegionError.invalidRegion
            }
            return dto
        } catch let moyaErr as MoyaError {
            if case .statusCode(let response) = moyaErr {
                if response.statusCode == 400 {
                    throw RegionError.invalidRegion
                }
            }
            throw moyaErr
        } catch let NetworkError.server(err, status) {
            if status == 400, err.code == "INVALID REGION" {
                throw RegionError.invalidRegion
            }
            throw NetworkError.server(err, status: status)
        } catch {
            throw error
        }
    }
    
    func setMood(planId: Int, text: String) async throws -> PlanMood {
        let api: ApiResponse<MoodResultDTO> = try await publicProvider.requestDecodableAutoRefresh(.mood(planId: planId, inputText: text), as: ApiResponse<MoodResultDTO>.self)
        guard api.isSuccess, let dto = api.result else {
            throw NetworkError.server(.init(code: api.code, message: api.message), status: 200)
        }
        return PlanMapper.toPlanMood(from: dto)
    }
    
    func setVideos(planId: Int, region: String, urls: [String]) async throws -> Bool {
        let api: ApiResponse<VideosResultDTO> = try await publicProvider.requestDecodableAutoRefresh(.videos(planId: planId, videoURLs: urls), as: ApiResponse<VideosResultDTO>.self)
        return api.isSuccess
    }
    
    func setDuration(planId: Int, duration: Int, start: String, finish: String) async throws -> Bool {
        let api: ApiResponse<PlanIdResultDTO> = try await publicProvider.requestDecodableAutoRefresh(.duration(planId: planId, duration: duration, startDate: start, finishedDate: finish), as: ApiResponse<PlanIdResultDTO>.self)
        return api.isSuccess
    }
    
    func setStyle(planId: Int, transport: String, categories: [String]) async throws -> Bool {
        let api: ApiResponse<PlanIdResultDTO> = try await publicProvider.requestDecodableAutoRefresh(.style(planId: planId, transport: transport, categories: categories), as: ApiResponse<PlanIdResultDTO>.self)
        return api.isSuccess
    }
    
    func setCompanion(planId: Int, party: Int, companion: String) async throws -> Bool {
        let api: ApiResponse<PlanIdResultDTO> = try await publicProvider.requestDecodableAutoRefresh(.companion(planId: planId, party: party, companion: companion), as: ApiResponse<PlanIdResultDTO>.self)
        return api.isSuccess
    }
    
    func setDestination(planId: Int, travel: [TravelPlaceRequestDTO], stay: [StayPlaceRequestDTO]) async throws -> Bool {
        let api: ApiResponse<PlanIdResultDTO> = try await publicProvider.requestDecodableAutoRefresh(.destination(planId: planId, travelPlaces: travel, stayPlaces: stay), as: ApiResponse<PlanIdResultDTO>.self)
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
        let api: ApiResponse<PlanGenerateResponseDTO> = try await provider.requestDecodableAutoRefresh(
            .generate(planId: planId),
            as: ApiResponse<PlanGenerateResponseDTO>.self
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
    
    func patchGeneratedPlanSummary(planId: Int) async throws -> PlanSummaryResponseDTO {
        let api: ApiResponse<PlanSummaryResponseDTO> = try await provider.requestDecodableAutoRefresh(
            .patchGeneratedPlanSummary(planId: planId),
            as: ApiResponse<PlanSummaryResponseDTO>.self
        )
        guard api.isSuccess, let dto = api.result else {
            throw NetworkError.server(.init(code: api.code, message: api.message), status: 200)
        }
        return dto
    }
    
    func updatePlanProfile(planId: Int, title: String, imageData: Data?) async throws -> PlanIdResultDTO {
        let res = try await provider.asyncRequest(
            .profile(planId: planId, title: title, imageData: imageData))
        let api = try JSONDecoder().decode(ApiResponse<PlanIdResultDTO>.self, from: res.data)
        guard api.isSuccess, let dto = api.result else {
            throw NetworkError.server(.init(code: api.code, message: api.message), status: res.statusCode)
        }
        return dto
    }
    
    @discardableResult
    func exportPlanPDF(planId: Int, title: String) async throws -> URL {
        let res = try await provider.asyncRequest(.exportPDF(planId: planId))
        guard (200..<300).contains(res.statusCode) else {
            throw NetworkError.server(
                (try? JSONDecoder().decode(ErrorResponse.self, from: res.data))
                ?? .init(code: "HTTP_\(res.statusCode)", message: "PDF 내보내기 실패"),
                status: res.statusCode
            )
        }

        let safeTitle = title
            .replacingOccurrences(of: "[/:]", with: "_", options: .regularExpression)
//            .replacingOccurrences(of: "[^0-9a-zA-Z가-힣!?]", with: "_", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let filename = (safeTitle.isEmpty ? "plan" : safeTitle) + ".pdf"

        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        try res.data.write(to: url, options: .atomic)
        return url
    }
}
