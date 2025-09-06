//
//  TravelPlaceRequestDTO.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 8/31/25.
//

struct TravelPlaceRequestDTO: Encodable {
    let placeName: String
    let date: String?
    let img: String?
    let address: String?
    let description: String?
}
