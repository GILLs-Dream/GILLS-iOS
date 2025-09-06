//
//  StayPlaceRequestDTO.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 8/31/25.
//

struct StayPlaceRequestDTO: Encodable {
    let placeName: String
    let img: String?
    let startDate: String?
    let endDate: String?
    let address: String?
    let description: String?
}
