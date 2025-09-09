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
    case generate(planId: Int)
    case duration(planId: Int, duration: Int, startDate: String, finishedDate: String)
    case style(planId: Int, transport: String, categories: [String])
    case companion(planId: Int, party: Int, companion: String)
    case destination(planId: Int, travelPlaces: [TravelPlaceRequestDTO], stayPlaces: [StayPlaceRequestDTO])
    case list
}

extension PlanTargetType: BaseTargetType {
    var path: String {
        switch self {
        case .mood:
            return "/plan/template/mood"
        case .videos(let id, _, _):
            return "/plan/template/\(id)/videos"
        case .generate(let id):
            return "/plan/template/\(id)/generate"
        case .duration(let id, _, _, _):
            return "/plan/template/\(id)/duration"
        case .style(let id, _, _):
            return "/plan/template/\(id)/style"
        case .companion(let id, _, _):
            return "/plan/template/\(id)/companion"
        case .destination(let id, _, _):
            return "/plan/template/\(id)/destination"
        case .list:
            return "/plan/template"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .mood, .generate, .destination:
            return .post
        case .videos, .duration, .style, .companion:
            return .patch
        case .list:
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case .mood(let text):
            return .requestJSONEncodable(MoodRequestDTO(inputText: text))
            
        case .videos(_, let region, let urls):
            return .requestJSONEncodable(VideosRequestDTO(region: region, videoUrlList: urls))
            
        case .generate:
            return .requestPlain
            
        case .duration(_, let duration, let start, let finish):
            return .requestJSONEncodable(DurationRequestDTO(duration: duration, startDate: start, finishedDate: finish))
            
        case .style(_, let transport, let categories):
            return .requestJSONEncodable(StyleRequestDTO(transport: transport, categoryTypeList: categories))
            
        case .companion(_, let party, let companion):
            return .requestJSONEncodable(CompanionRequestDTO(party: party, companion: companion))
            
        case .destination(_, let travel, let stay):
            return .requestJSONEncodable(DestinationRequestDTO(travelPlaceDtoList: travel, stayPlaceDtoList: stay))
            
        case .list:
            return .requestPlain
        }
    }
}
