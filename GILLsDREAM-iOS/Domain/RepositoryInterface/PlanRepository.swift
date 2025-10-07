//
//  PlanRepository.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 8/30/25.
//

import Foundation

protocol PlanRepository {
    func setRegion(region: String) async throws -> RegionResultDTO
    func setMood(planId: Int, text: String) async throws -> PlanMood
    func setVideos(planId: Int, region: String, urls: [String]) async throws -> Bool
    func setDuration(planId: Int, duration: Int, start: String, finish: String) async throws -> Bool
    func setStyle(planId: Int, transport: String, categories: [String]) async throws -> Bool
    func setCompanion(planId: Int, party: Int, companion: String) async throws -> Bool
    func setDestination(planId: Int, travel: [TravelPlaceRequestDTO], stay: [StayPlaceRequestDTO]) async throws -> Bool
    func generatePlan(planId: Int) async throws
    func fetchGeneratedPlan(planId: Int) async throws -> PlanResultResponseDTO
    func fetchGeneratedPlanSummary(planId: Int) async throws -> PlanSummaryResponseDTO
    func patchGeneratedPlanSummary(planId: Int) async throws -> PlanSummaryResponseDTO
    func updatePlanProfile(planId: Int, title: String, imageData: Data?) async throws -> PlanIdResultDTO
    func fetchPlanList() async throws -> [Plan]
    func exportPlanPDF(planId: Int, title: String) async throws -> URL}
