//
//  MainHomeView.swift
//  GILLsDREAM-iOS
//
//  Created by 오연서 on 5/17/25.
//

import UIKit
import SnapKit
import Then

final class MainHomeView: UIView {
    
    // MARK: Properties
    private let cities = ["서울", "제주", "속초", "원주", "여수", "전주", "김해", "완도", "나주", "목포",
                          "파주", "구미", "진주", "군포", "공주", "거제", "구리", "광주", "남해", "청주"]
    private var cityIndex = 0
    private var cityTimer: Timer?
    
    // MARK: Views
    private let topBarView = TopBarView()
    private let textLabel = UILabel()
    private let backgroundImage = UIImageView()
    lazy var travelButton = CustomButton(title: "여행계획 세우기")
    
    // MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpFoundation()
        setUpHierarchy()
        setUpUI()
        setUpLayout()
        startCityCycle()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: setUpFoundation
    private func setUpFoundation() {
        self.backgroundColor = .clear
    }
    
    // MARK: setUpHierarchy
    private func setUpHierarchy() {
        [
            topBarView,
            textLabel,
            backgroundImage,
            travelButton
        ].forEach { self.addSubview($0) }
    }
    
    // MARK: setUpUI
    private func setUpUI() {
        textLabel.do {
            $0.textAlignment = .left
            $0.numberOfLines = 3
        }
        
        backgroundImage.do {
            $0.image = .imgGradGill
            $0.contentMode = .scaleAspectFill
        }
    }
    
    // MARK: setUpLayout
    private func setUpLayout() {
        topBarView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(60)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(50)
        }
        
        textLabel.snp.makeConstraints {
            $0.top.equalTo(topBarView.snp.bottom).offset(50)
            $0.leading.equalTo(self.safeAreaLayoutGuide).offset(20)
            $0.width.equalTo(300)
        }
        
        backgroundImage.snp.makeConstraints {
            $0.top.equalTo(textLabel.snp.bottom).offset(-50)
            $0.trailing.equalToSuperview()
        }
        
        travelButton.snp.makeConstraints {
            $0.height.equalTo(51)
            $0.horizontalEdges.equalToSuperview().inset(43)
            $0.bottom.equalTo(self.safeAreaLayoutGuide).inset(20)
        }
    }
    
    // MARK: City Cycle
    private func startCityCycle() {
        updateCityText(cities[cityIndex])

        cityTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.cityIndex = (self.cityIndex + 1) % self.cities.count
            let nextCity = self.cities[self.cityIndex]
            self.updateCityText(nextCity)
        }
    }
    
    private func updateCityText(_ city: String) {
        textLabel.setCityText(city)
    }
    
    // MARK: deinit
    deinit {
        cityTimer?.invalidate()
    }
}

extension UILabel {
    func setCityText(_ city: String) {
        let base = "( \(city) ) 로 가는\n가장 트렌디한\n여행계획을 세워보세요."
        let matrix = CGAffineTransform(a: 1, b: 0, c: CGFloat(tanf(12 * .pi / 180)), d: 1, tx: 0, ty: 0)
        let desc = UIFontDescriptor(name: "EBSJSKBold", matrix: matrix)
        let attributed = base.pretendardAttributedString(style: .title1)
        self.attributedText = attributed
        self.applyMultipleAttributes(styles: [
            (target: city, font: UIFont(descriptor: desc, size: 40), color: .mainOrange),
            (target: "(", font: .PretendardStyle.extratitle2.font, color: .white),
            (target: ")", font: .PretendardStyle.extratitle2.font, color: .white)
        ])
    }
}
