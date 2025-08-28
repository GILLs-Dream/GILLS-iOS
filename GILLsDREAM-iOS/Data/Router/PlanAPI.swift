//
//  PlanAPI.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 8/27/25.
//

import Moya

enum PlanAPI {
    case mood(inputText: String) // 여행 분위기 ai로 저장 및 Plan 생성
    case videos(planId: Int, region: String, videoURLs: [String]) // 유튜브 링크 (추후 링크 여러개로 확장 예정)
    case generate(planId: Int) // 템플릿 정보기반 여행생성
    case duration(planId: Int, duration: Int, startDate: String, finishedDate: String) // 얼마나
    case style(planId: Int, transport: String, categories: [String]) // 어떻게
    case companion(planId: Int, party: Int, companion: String) // 누구와
    case destination(planId: Int, travelPlaces: [TravelPlaceRequestDTO], stayPlaces: [StayPlaceRequestDTO]) // 어디로
}

extension PlanAPI: BaseTargetType {
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
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .mood, .generate, .destination:
            return .post
        case .videos, .duration, .style, .companion:
            return .patch
        }
    }
    
    var task: Task {
        switch self {
        case .mood(let text):
            return .requestJSONEncodable(MoodRequestDTO(inputText: text))
            
        case .videos(_, let region, let urls):
            return .requestJSONEncodable(VideosRequestDTO(region: region, video_url_list: urls))
            
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
        }
    }
}
