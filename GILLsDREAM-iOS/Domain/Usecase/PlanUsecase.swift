//
//  PlanUsecase.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 8/31/25.
//

import Foundation

protocol PlanUsecase {
    func createPlanFromMood(_ text: String) async throws -> PlanMood
    func setVideos(planId: Int, region: String, urls: [String]) async throws -> Bool
    func setDuration(planId: Int, duration: Int, start: String, finish: String) async throws -> Bool
    func setCompanion(planId: Int, party: Int, companion: String) async throws -> Bool
    func setDestination(planId: Int, travel: [TravelPlaceRequestDTO], stay: [StayPlaceRequestDTO]) async throws -> Bool
    func setStyle(planId: Int, transport: String, categories: [String]) async throws -> Bool
    func generate(planId: Int) async throws -> Plan
    func fetchMyPlans() async throws -> [Plan]
}

final class PlanUsecaseImpl: PlanUsecase {
    private let repository: PlanRepository

    public init(repository: PlanRepository) {
        self.repository = repository
    }

    public func createPlanFromMood(_ text: String) async throws -> PlanMood {
        try await repository.setMood(text)
    }

    public func setVideos(planId: Int, region: String, urls: [String]) async throws -> Bool {
        try await repository.setVideos(planId: planId, region: region, urls: urls)
    }

    public func setDuration(planId: Int, duration: Int, start: String, finish: String) async throws -> Bool {
        try await repository.setDuration(planId: planId, duration: duration, start: start, finish: finish)
    }

    public func setCompanion(planId: Int, party: Int, companion: String) async throws -> Bool {
        try await repository.setCompanion(planId: planId, party: party, companion: companion)
    }

    public func setDestination(planId: Int,
                               travel: [TravelPlaceRequestDTO],
                               stay: [StayPlaceRequestDTO]) async throws -> Bool {
        try await repository.setDestination(planId: planId, travel: travel, stay: stay)
    }
    
    public func setStyle(planId: Int, transport: String, categories: [String]) async throws -> Bool {
        try await repository.setStyle(planId: planId, transport: transport, categories: categories)
    }

    public func generate(planId: Int) async throws -> Plan {
        try await repository.generate(planId: planId)
    }
    
    public func fetchMyPlans() async throws -> [Plan] {
        try await repository.fetchPlanList()
    }
}
