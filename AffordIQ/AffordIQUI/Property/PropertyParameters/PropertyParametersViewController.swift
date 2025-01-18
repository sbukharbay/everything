//
//  PropertyParametersViewController.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 11.03.2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import AffordIQFoundation
import Combine
import UIKit

class PropertyParametersViewController: FloatingButtonController, Stylable, ErrorPresenter {
    private lazy var backgroundImageView: BackgroundImageView = .init(frame: .zero)

    private lazy var customNavBar: CustomNavigationBar = {
        let navBar = CustomNavigationBar(title: "Set a Goal") { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        return navBar
    }()

    private let blurEffectView: UIVisualEffectView = {
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.layer.cornerRadius = 30
        blurView.clipsToBounds = true
        return blurView
    }()

    private let headerLabel: HeadingTitleLabel = {
        let label = HeadingTitleLabel()
        label.text = "Property"
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let titleIconImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "property", in: uiBundle, compatibleWith: nil)
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = UIColor(hex: "72F0F0")
        return imageView
    }()

    private lazy var titleStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleIconImage, headerLabel])
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.setCustomSpacing(8, after: titleIconImage)
        return stackView
    }()

    private let questionLabel: HeadlineLabelDark = {
        let label = HeadlineLabelDark()
        label.text = "What kind of home do you want?"
        label.textAlignment = .center
        label.numberOfLines = 0
        
        return label
    }()
    
    private let locationLabel: BodyLabelDark = {
        let label = BodyLabelDark()
        label.text = "Location"
        label.textAlignment = .left
        return label
    }()

    private lazy var searchField: TextFieldDark = {
        let textField = TextFieldDark()
        textField.delegate = self
        var imageView = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        imageView.tintColor = .white
        imageView.frame = CGRect(x: 6, y: 10, width: 24, height: 20)
        textField.addSubview(imageView)
        textField.paddingLeft = 28
        textField.placeholder = "City, Postcode Area or Suburb"
        return textField
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.layer.cornerRadius = 4.0
        tableView.layer.masksToBounds = true
        tableView.showsVerticalScrollIndicator = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PropertyParametersTableViewCell.self, forCellReuseIdentifier: PropertyParametersTableViewCell.reuseIdentifier)
        tableView.register(PropertyAutocompleteCell.self, forCellReuseIdentifier: PropertyAutocompleteCell.reuseIdentifier)
        return tableView
    }()

    private lazy var searchButton: PrimaryButtonDark = {
        let button = PrimaryButtonDark()
        button.setTitle("Search", for: .normal)
        button.addTarget(self, action: #selector(handleSearch), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    private lazy var emptyLocationsText: ErrorLabel = {
        let label = ErrorLabel()
        label.text = "Not found - Search City, Postcode Area or Suburb"
        label.textAlignment = .left
        label.isHidden = true
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()

    private lazy var filterPickerView: UIPickerView = {
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        picker.backgroundColor = UIColor(hex: "0F0728")
        picker.tintColor = .white
        return picker
    }()

    private lazy var filterToolbarTitle: UIBarButtonItem = {
        var title = UIBarButtonItem(title: "Minimum Bedrooms", style: .done, target: self, action: nil)
        title.tintColor = .white
        return title
    }()

    private lazy var filterToolbar: UIToolbar = {
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(filterDone))
        doneButton.tintColor = UIColor(hex: "72F0F0")

        let toolBar = UIToolbar(frame: .zero)
        toolBar.backgroundColor = UIColor(hex: "0F0728")

        let emptySpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.setItems([emptySpace, emptySpace, emptySpace, emptySpace, emptySpace, filterToolbarTitle, emptySpace, emptySpace, emptySpace, doneButton], animated: true)
        return toolBar
    }()

    private lazy var filterPickerStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [filterToolbar, filterPickerView])
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.isHidden = true
        return stackView
    }()

    private let zooplaLogoImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "zoopla", in: uiBundle, compatibleWith: nil)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private var viewModel: PropertyParametersViewModel?
    private var contentSizeMonitor: ContentSizeMonitor = .init()
    var subscriptions: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        contentSizeMonitor.delegate = self

        textFieldDidChange()

        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        tap.delegate = self
        view.addGestureRecognizer(tap)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        contentSizeMonitor.removeObserver()
    }

    func bind(
        homeValue: Decimal,
        parameters: ChosenPropertyParameters?,
        months: Int,
        isDashboard: Bool
    ) {
        loadViewIfNeeded()

        viewModel = PropertyParametersViewModel(
            homeValue: homeValue,
            parameters: parameters,
            months: months,
            isDashboard: isDashboard
        )
        
        setupViews()
        setupListeners()
        apply(styles: AppStyles.shared)
        
        if let search = parameters {
            changeSearchText(search: search.suggestion.value)
            titleIconImage.image = UIImage(systemName: "slider.horizontal.3")
            headerLabel.text = "Filters"
            searchButton.setTitle("Apply", for: .normal)
            searchButton.isEnabled = true
            titleStackView.alignment = .center
        }

        bringFeedbackButton(String(describing: type(of: self)))
    }

    override func viewDidLayoutSubviews() {
        NSLayoutConstraint.activate([
            customNavBar.topAnchor.constraint(equalTo: view.topAnchor),
            customNavBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customNavBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customNavBar.heightAnchor.constraint(equalToConstant: 40 + view.safeAreaInsets.top)
        ])
    }

    func setupViews() {
        [backgroundImageView, blurEffectView, titleStackView, questionLabel, searchField, tableView, searchButton, zooplaLogoImage, filterPickerStackView, emptyLocationsText, customNavBar, locationLabel].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            blurEffectView.topAnchor.constraint(equalTo: customNavBar.bottomAnchor, constant: 16),
            blurEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            blurEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            blurEffectView.bottomAnchor.constraint(equalTo: searchButton.bottomAnchor, constant: 24),

            titleStackView.topAnchor.constraint(equalTo: blurEffectView.topAnchor, constant: 16),
            titleStackView.centerXAnchor.constraint(equalTo: blurEffectView.centerXAnchor),

            questionLabel.topAnchor.constraint(equalTo: titleStackView.bottomAnchor, constant: 12),
            questionLabel.leadingAnchor.constraint(equalTo: blurEffectView.leadingAnchor, constant: 16),
            questionLabel.trailingAnchor.constraint(equalTo: blurEffectView.trailingAnchor, constant: -16),
            
            locationLabel.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 16),
            locationLabel.leadingAnchor.constraint(equalTo: blurEffectView.leadingAnchor, constant: 16),
            locationLabel.trailingAnchor.constraint(equalTo: blurEffectView.trailingAnchor, constant: -16),

            searchField.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 8),
            searchField.leadingAnchor.constraint(equalTo: blurEffectView.leadingAnchor, constant: 16),
            searchField.trailingAnchor.constraint(equalTo: blurEffectView.trailingAnchor, constant: -24),
            searchField.heightAnchor.constraint(equalToConstant: 40),
            
            emptyLocationsText.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 8),
            emptyLocationsText.leadingAnchor.constraint(equalTo: blurEffectView.leadingAnchor, constant: 16),
            emptyLocationsText.trailingAnchor.constraint(equalTo: blurEffectView.trailingAnchor, constant: -16),

            tableView.topAnchor.constraint(equalTo: searchField.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: blurEffectView.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: blurEffectView.trailingAnchor, constant: -24),
            tableView.heightAnchor.constraint(equalToConstant: 172),

            searchButton.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 24),
            searchButton.centerXAnchor.constraint(equalTo: blurEffectView.centerXAnchor),
            searchButton.widthAnchor.constraint(equalToConstant: 180),
            searchButton.heightAnchor.constraint(equalToConstant: 40),

            filterPickerStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            filterPickerStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            filterPickerStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            filterPickerStackView.heightAnchor.constraint(equalToConstant: view.frame.height * 0.35),

            zooplaLogoImage.topAnchor.constraint(equalTo: blurEffectView.bottomAnchor, constant: 16),
            zooplaLogoImage.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }

    private func setupListeners() {
        // Listener fires alert if error not nil
        viewModel?.$error
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                guard let error else { return }
                self?.present(error: error)
            }
            .store(in: &subscriptions)
        
        viewModel?.$chosenPropertyParameters
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] parameters in
                guard let parameters else { return }
                self?.showResults(parameters: parameters)
            })
            .store(in: &subscriptions)
        
        viewModel?.$updateData
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.updateData()
            })
            .store(in: &subscriptions)
        
        viewModel?.$updateButton
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.updateButton()
            })
            .store(in: &subscriptions)
    }
    
    func textFieldDidChange() {
        let publisher = NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: searchField)
        publisher.compactMap {
            ($0.object as? UITextField)?.text
        }
        .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
        .removeDuplicates()
        .filter { !$0.isEmpty }
        .sink(receiveValue: { [weak self] text in
            Task {
                await self?.viewModel?.autocomplete(text)
            }
        }).store(in: &subscriptions)
    }

    @objc func handleSearch() {
        viewModel?.prepareResults()
    }
    
    func showResults(parameters: ChosenPropertyParameters) {
        if let presenter = navigationController, let viewModel {
            presenter.dismiss(animated: true, completion: {
                let coordinator = PropertyResultsCoordinator(presenter: presenter, search: parameters, mortgageLimits: viewModel.mortgageLimits, months: viewModel.months, isDashboard: viewModel.isDashboard)
                coordinator.start()
            })
        }
    }

    @objc func dismissKeyboard() {
        if searchField.isEditing {
            view.endEditing(true)

            if let vm = viewModel, !vm.isFilter {
                vm.isFilter = true
                tableView.reloadData()
            }
        }
    }

    @objc func filterDone() {
        filterPickerStackView.isHidden = true
    }

    func updateData() {
        updateButton()
        tableView.reloadData()
        
        if let viewModel, viewModel.suggestions.isEmpty, !viewModel.searchText.isEmpty {
            showEmptyLocationsText()
        } else {
            hideEmptyLocationsText()
        }
    }

    func updateButton() {
        guard let vm = viewModel else { return }
        searchButton.isEnabled = vm.selectedSuggestion != nil
    }

    func changeSearchText(search: String) {
        let separators = CharacterSet(charactersIn: "[]")
        searchField.text = search.components(separatedBy: separators).compactMap { $0.sanitized }.joined(separator: " ")
    }
    
    func showEmptyLocationsText() {
        guard let text = searchField.text, text.count > 1 else { return }
        emptyLocationsText.isHidden = false
    }
    
    func hideEmptyLocationsText() {
        emptyLocationsText.isHidden = true
    }
}

extension PropertyParametersViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection _: Int) -> Int {
        guard let vm = viewModel else { return 0 }

        if vm.isFilter {
            tableView.separatorStyle = .none

            return vm.parameters.count
        } else {
            tableView.separatorStyle = .singleLine

            return vm.suggestions.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let vm = viewModel else { return UITableViewCell() }

        if vm.isFilter {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: PropertyParametersTableViewCell.reuseIdentifier, for: indexPath) as? PropertyParametersTableViewCell else { return UITableViewCell() }

            cell.titleLabel.text = vm.parameters[indexPath.row].title
            cell.valueLabel.text = vm.parameters[indexPath.row].value
            cell.apply(styles: AppStyles.shared)

            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: PropertyAutocompleteCell.reuseIdentifier, for: indexPath) as? PropertyAutocompleteCell else { return UITableViewCell() }

            cell.titleLabel.text = vm.suggestions[indexPath.row].value
            cell.apply(styles: AppStyles.shared)

            return cell
        }
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let vm = viewModel else { return }

        if vm.isFilter {
            vm.parameterIndex = indexPath.row
            filterPickerView.reloadAllComponents()
            filterPickerStackView.isHidden = false
        } else {
            changeSearchText(search: vm.suggestions[indexPath.row].value)
            vm.selectedSuggestion = vm.suggestions[indexPath.row]
            updateButton()
            dismissKeyboard()
        }
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        guard let vm = viewModel else { return 0 }

        if vm.isFilter {
            return 40
        }

        return UITableView.automaticDimension
    }

    func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
        guard let vm = viewModel else { return 0 }

        if vm.isFilter {
            return 40
        }
        return 0
    }

    func tableView(_: UITableView, estimatedHeightForHeaderInSection _: Int) -> CGFloat {
        guard let vm = viewModel else { return 0 }

        if vm.isFilter {
            return 40
        }
        return 0
    }

    func tableView(_: UITableView, viewForHeaderInSection _: Int) -> UIView? {
        guard let vm = viewModel else { return nil }

        if vm.isFilter {
            let view = UIView(frame: .zero)
            view.backgroundColor = .clear
            return view
        }
        return nil
    }
}

extension PropertyParametersViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in _: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_: UIPickerView, numberOfRowsInComponent _: Int) -> Int {
        guard let vm = viewModel else { return 0 }

        return vm.parameters[vm.parameterIndex].options.count
    }

    func pickerView(_: UIPickerView, attributedTitleForRow row: Int, forComponent _: Int) -> NSAttributedString? {
        guard let vm = viewModel else { return nil }

        filterToolbarTitle.title = vm.parameters[vm.parameterIndex].title

        return NSAttributedString(string: vm.parameters[vm.parameterIndex].options[row], attributes: [.foregroundColor: UIColor.white])
    }

    func pickerView(_: UIPickerView, didSelectRow row: Int, inComponent _: Int) {
        guard let vm = viewModel else { return }

        vm.parameters[vm.parameterIndex].value = vm.parameters[vm.parameterIndex].options[row]

        tableView.reloadData()
    }

    func pickerView(_: UIPickerView, rowHeightForComponent _: Int) -> CGFloat {
        return 32
    }
}

extension PropertyParametersViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderColor = UIColor(hex: "#72F0F0").cgColor
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layer.borderColor = UIColor(white: 0.5, alpha: 0.3).cgColor
    }
}

extension PropertyParametersViewController {
    func gestureRecognizer(_: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let view = touch.view, let superView = view.superview {
            if let superPuperView = superView.superview, superPuperView.isKind(of: UITableViewCell.self) {
                return false
            }
            if superView.isKind(of: UITableViewCell.self) {
                return false
            }
        }
        return true
    }
    
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}

extension PropertyParametersViewController: ContentSizeMonitorDelegate {
    func contentSizeCategoryUpdated() {
        apply(styles: AppStyles.shared)
    }
}
