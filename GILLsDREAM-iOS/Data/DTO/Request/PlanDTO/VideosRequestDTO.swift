//
//  VideosRequestDTO.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 8/31/25.
//

struct VideosRequestDTO: Encodable {
    let videoUrlList: [String]

    enum CodingKeys: String, CodingKey {
        case videoUrlList = "video_url_list"
    }
}
