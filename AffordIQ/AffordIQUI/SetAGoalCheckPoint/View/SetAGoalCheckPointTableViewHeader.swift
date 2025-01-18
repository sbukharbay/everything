//
//  SetAGoalCheckPointTableViewHeader.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 07/09/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import UIKit
import AffordIQControls
import AffordIQFoundation
import Combine

class SetAGoalCheckPointTableViewHeader: UITableViewHeaderFooterView, Stylable {
    private(set) lazy var container: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private(set) lazy var meterStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.distribution = .fill
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private(set) lazy var monthsLabel: DashboardLargeLabel = {
        let view = DashboardLargeLabel()
        view.text = ""
        view.textAlignment = .center
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private(set) lazy var untilAffordableLabel: FieldLabelDark = {
        let view = FieldLabelDark()
        view.text = "Months until affordable"
        view.numberOfLines = 0
        view.textAlignment = .center
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private(set) lazy var circleMeterView: CircularMeterView = {
        let view = CircularMeterView(frame: .zero)
        view.numberOfSegments = 16
        view.lineWidth = 6
        view.isClockwise = true
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private var subscriptions = Set<AnyCancellable>()
    
    func setup(viewModel: SetAGoalCheckPointViewModel) {
        apply(styles: AppStyles.shared)
        
        setupSubviews()
        switch viewModel.viewType {
        case .savingGoal:
            circleMeterView.isHidden = true
            meterStackView.isHidden = true
            
        default:
            circleMeterView.isHidden = false
            meterStackView.isHidden = false
            
            NSLayoutConstraint.activate([
                circleMeterView.heightAnchor.constraint(equalToConstant: 150),
                circleMeterView.widthAnchor.constraint(equalToConstant: 150)
            ])
        }
        
        // Listen for update of view
        viewModel.willUpdate
            .receive(on: DispatchQueue.main)
            .sink { [weak self] shouldUpdate in
                guard let self, shouldUpdate else { return }
                self.update(viewModel: viewModel)
            }
            .store(in: &subscriptions)
    }
    
    private func update(viewModel: SetAGoalCheckPointViewModel) {
        monthsLabel.text = viewModel.months > 36 ? "36+" : String(describing: viewModel.months)
        
        switch viewModel.months {
        case 0:
            monthsLabel.text = "NOW"
            untilAffordableLabel.text = "Affordable"
        case 1:
            untilAffordableLabel.text = "Month until affordable"
        default:
            untilAffordableLabel.text = "Months until affordable"
        }
        
        circleMeterView.progress = viewModel.months >= 48 ? 0 : (48 - Float(viewModel.months)) / 48
    }
}

extension SetAGoalCheckPointTableViewHeader: AnyConstraintView {
    func embedSubviews() {
        contentView.addSubview(container)
        
        container.addSubview(meterStackView)
        container.addSubview(circleMeterView)
        
        meterStackView.addArrangedSubview(monthsLabel)
        meterStackView.addArrangedSubview(untilAffordableLabel)
    }
    
    func setupSubviewsConstraints() {
        setContainerConstraints()
        setCircleMeterViewConstraints()
        setMeterStackViewConstraints()
    }
    
    private func setContainerConstraints() {
        container.embedToView(contentView)
    }
    
    private func setCircleMeterViewConstraints() {
        NSLayoutConstraint.activate([
            circleMeterView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            circleMeterView.topAnchor.constraint(equalTo: container.topAnchor),
            circleMeterView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16)
        ])
    }
    
    private func setMeterStackViewConstraints() {
        NSLayoutConstraint.activate([
            meterStackView.centerXAnchor.constraint(equalTo: circleMeterView.centerXAnchor),
            meterStackView.centerYAnchor.constraint(equalTo: circleMeterView.centerYAnchor),
            meterStackView.leadingAnchor.constraint(equalTo: circleMeterView.leadingAnchor, constant: 8),
            meterStackView.trailingAnchor.constraint(equalTo: circleMeterView.trailingAnchor, constant: -8)
        ])
    }
}
