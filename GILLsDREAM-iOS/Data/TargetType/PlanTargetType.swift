//
//  PlanTargetType.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 8/27/25.
//

import Foundation
import Moya

enum PlanTargetType {
    case mood(inputText: String)
    case videos(planId: Int, region: String, videoURLs: [String])
    case duration(planId: Int, duration: Int, startDate: String, finishedDate: String)
    case style(planId: Int, transport: String, categories: [String])
    case companion(planId: Int, party: Int, companion: String)
    case destination(planId: Int, travelPlaces: [TravelPlaceRequestDTO], stayPlaces: [StayPlaceRequestDTO])
    case generate(planId: Int)
    case fetchGeneratedPlan(planId: Int)
    case patchGeneratedPlanSummary(planId: Int)
    case fetchGeneratedPlanSummary(planId: Int)
    case profile(planId: Int, title: String, imageData: Data?)
    case list
}

extension PlanTargetType: BaseTargetType {
    var path: String {
        switch self {
        case .mood:
            return "/v1/plan/template/mood"
        case .videos(let id, _, _):
            return "/v1/plan/template/\(id)/videos"
        case .duration(let id, _, _, _):
            return "/v1/plan/template/\(id)/duration"
        case .style(let id, _, _):
            return "/v1/plan/template/\(id)/style"
        case .companion(let id, _, _):
            return "/v1/plan/template/\(id)/companion"
        case .destination(let id, _, _):
            return "/v1/plan/template/\(id)/destination"
        case .generate(let id):
            return "/v1/plan/template/\(id)/generate"
        case .fetchGeneratedPlan(let id):
            return "/v1/plan/template/\(id)/plan"
        case .patchGeneratedPlanSummary(let id):
            return "/v1/plan/template/\(id)/plan-summary"
        case .fetchGeneratedPlanSummary(let id):
            return "/v1/plan/template/\(id)/plan-summary"
        case .profile(let id, _, _):
            return "/v1/plan/template/\(id)/profile"
        case .list:
            return "/v1/plan/template"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .mood, .generate, .destination:
            return .post
        case .videos, .duration, .style, .companion, .patchGeneratedPlanSummary, .profile:
            return .patch
        case .list, .fetchGeneratedPlan, .fetchGeneratedPlanSummary:
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case .mood(let text):
            return .requestJSONEncodable(MoodRequestDTO(inputText: text))
            
        case .videos(_, let region, let urls):
            return .requestJSONEncodable(VideosRequestDTO(region: region, videoUrlList: urls))
            
        case .duration(_, let duration, let start, let finish):
            return .requestJSONEncodable(DurationRequestDTO(duration: duration, startDate: start, finishedDate: finish))
            
        case .style(_, let transport, let categories):
            return .requestJSONEncodable(StyleRequestDTO(transport: transport, categoryTypeList: categories))
            
        case .companion(_, let party, let companion):
            return .requestJSONEncodable(CompanionRequestDTO(party: party, companion: companion))
            
        case .destination(_, let travel, let stay):
            return .requestJSONEncodable(DestinationRequestDTO(travelPlaceDtoList: travel, stayPlaceDtoList: stay))
            
        case .generate, .list, .fetchGeneratedPlan, .patchGeneratedPlanSummary, .fetchGeneratedPlanSummary:
            return .requestPlain
            
        case let .profile(_, title, imageData):
            var parts: [MultipartFormData] = []

            // profile part
            struct TitlePayload: Encodable {
                let title: String
            }
            
            let payload = TitlePayload(title: title)
            if let jsonData = try? JSONEncoder().encode(payload) {
                parts.append(
                    MultipartFormData(
                        provider: .data(jsonData),
                        name: "title",
                        fileName: "title.json",
                        mimeType: "application/json"
                    )
                )
            }

            // image part
            if let data = imageData {
                parts.append(
                    MultipartFormData(
                        provider: .data(data),
                        name: "image",
                        fileName: "plan.jpg",
                        mimeType: "image/jpeg"
                    )
                )
            }
            return .uploadMultipart(parts)
        }
    }
    
    var headers: [String: String]? {
        switch self {
        case .profile:
            if let token = KeychainManager.shared.accessToken {
                return ["Authorization": "Bearer \(token)"]
            }
            return nil

        default:
            return ["Content-Type": "application/json",
                    "Accept": "application/json"]
        }
    }
    
    var validationType: ValidationType {
        .successCodes
    }
}
