//
//  DestinationRequestDTO.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 8/31/25.
//

struct DestinationRequestDTO: Encodable {
    let travelPlaceDtoList: [TravelPlaceRequestDTO]
    let stayPlaceDtoList: [StayPlaceRequestDTO]
}
