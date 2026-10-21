//
//  NewHabitViewController.swift
//  Tracker
//
//  Created by арина сильченко on 21.09.26.
//

import UIKit

final class NewHabitViewController: UIViewController {
    // MARK: - Output
    
    // Вызывается, когда пользователь нажал «Создать».
    var onCreate: ((Tracker) -> Void)?
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let emojis = ["🙂","😻","🌺","🐶","❤️","😱","😇","😡","🥶","🤔","🙌","🍔","🥦","🏓","🥇","🎸","🏝️","😪"]
    private let colorNames = (1...18).map { "Color selection \($0)" }
    
    private var chosenEmoji: String? {
        didSet {
            emojiCollectionView.reloadData()
            updateCreateButtonState()
        }
    }
    
    private var chosenColorName: String? {
        didSet {
            colorCollectionView.reloadData()
            updateCreateButtonState()
        }
    }
    
    // MARK: - State
    private var schedule: Set<WeekDay> = [] {
        didSet {
            tableView.reloadData()
            updateCreateButtonState()
        }
    }
    
    // MARK: - UI
    
    private let titleLabel = UILabel()
    private let nameTextField = UITextField()
    private let tableView = UITableView()
    
    private let emojiTitle = UILabel()
    private lazy var emojiCollectionView = makeCollectionView(
        cellType: EmojiCell.self,
        reuseIdentifier: EmojiCell.reuseIdentifier
    )
    
    private let colorsTitle = UILabel()
    private lazy var colorCollectionView = makeCollectionView(
        cellType: ColorCell.self,
        reuseIdentifier: ColorCell.reuseIdentifier
    )
    
    private func makeCollectionView(
        cellType: UICollectionViewCell.Type,
        reuseIdentifier: String
    ) -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(cellType, forCellWithReuseIdentifier: reuseIdentifier)
        return collectionView
    }
    
    private let cancelButton = UIButton(type: .system)
    private let createButton = UIButton(type: .system)
    private let buttonsStack = UIStackView()
    
    private enum SettingsRow: Int, CaseIterable {
        case category
        case schedule

        var title: String {
            switch self {
            case .category:
                return "Категория"
            case .schedule:
                return "Расписание"
            }
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad( )
        view.backgroundColor = .systemBackground
        setupTitle()
        setupButtons()
        setupScrollView()
        setupNameField()
        setupTableView()
        setupEmojiCollectionView()
        setupColorCollectionView()
        updateCreateButtonState()
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    private func setupTitle() {
        titleLabel.text = "Новая привычка"
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = UIColor(named: "Black [day]")
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 26),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setupNameField() {
        nameTextField.attributedPlaceholder = NSAttributedString(
            string: "Введите название трекера",
            attributes: [.foregroundColor: UIColor(named: "Gray") ?? .gray]
        )
        nameTextField.font = .systemFont(ofSize: 17)
        nameTextField.textColor = UIColor(named: "Black [day]")
        nameTextField.backgroundColor = UIColor(named: "Background [day]")
        nameTextField.layer.cornerRadius = 16
        nameTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
        nameTextField.leftViewMode = .always
        nameTextField.clearButtonMode = .whileEditing
        nameTextField.returnKeyType = .done
        nameTextField.delegate = self
        nameTextField.addTarget(self, action: #selector(nameChanged), for: .editingChanged)
        
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nameTextField)
        
        NSLayoutConstraint.activate([
            nameTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 38),
            nameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            nameTextField.heightAnchor.constraint(equalToConstant: 75)
        ])
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIColor(named: "Background [day]")?.withAlphaComponent(0.3)
        tableView.layer.cornerRadius = 16
        tableView.clipsToBounds = true
        tableView.isScrollEnabled = false
        tableView.rowHeight = 75
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: CGFloat(SettingsRow.allCases.count) * 75)
        ])
    }
    
    private func setupEmojiCollectionView() {
        emojiTitle.text = "Emoji"
        emojiTitle.font = .systemFont(ofSize: 19, weight: .bold)
        emojiTitle.textColor = UIColor(named: "Black [day]")
        contentView.addSubview(emojiTitle)
        contentView.addSubview(emojiCollectionView)
        emojiTitle.translatesAutoresizingMaskIntoConstraints = false
        emojiCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emojiTitle.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 32),
            emojiTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            emojiCollectionView.topAnchor.constraint(equalTo: emojiTitle.bottomAnchor, constant: 24),
            emojiCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            emojiCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            emojiCollectionView.heightAnchor.constraint(equalTo: emojiCollectionView.widthAnchor, multiplier: 0.5)
        ])
    }
    
    private func setupColorCollectionView() {
        colorsTitle.text = "Цвет"
        colorsTitle.font = .systemFont(ofSize: 19, weight: .bold)
        colorsTitle.textColor = UIColor(named: "Black [day]")
        contentView.addSubview(colorsTitle)
        contentView.addSubview(colorCollectionView)
        colorsTitle.translatesAutoresizingMaskIntoConstraints = false
        colorCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            colorsTitle.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 40),
            colorsTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            colorCollectionView.topAnchor.constraint(equalTo: colorsTitle.bottomAnchor, constant: 24),
            colorCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            colorCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            colorCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            colorCollectionView.heightAnchor.constraint(equalTo: colorCollectionView.widthAnchor, multiplier: 0.5)
        ])
    }
    
    private func setupButtons() {
        cancelButton.setTitle("Отменить", for: .normal)
        cancelButton.setTitleColor(UIColor(named: "Red"), for: .normal)
        cancelButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        cancelButton.layer.cornerRadius = 16
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor(named: "Red")?.cgColor
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        
        createButton.backgroundColor = UIColor(named: "Black [day]")
        createButton.setTitle("Создать", for: .normal)
        createButton.setTitleColor(UIColor(named: "White [day]"), for: .normal)
        createButton.setTitleColor(.white, for: .disabled)
        createButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        createButton.layer.cornerRadius = 16
        createButton.addTarget(self, action: #selector(createTapped), for: .touchUpInside)
        
        buttonsStack.addArrangedSubview(cancelButton)
        buttonsStack.addArrangedSubview(createButton)
        buttonsStack.axis = .horizontal
        buttonsStack.spacing = 8
        buttonsStack.distribution = .fillEqually
        buttonsStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonsStack)
        
        NSLayoutConstraint.activate([
            buttonsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonsStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            buttonsStack.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: buttonsStack.topAnchor, constant: -16)
        ])
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
    }
    
    // MARK: - State helpers
    private var trimmedName: String {
        nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }
    
    private func updateCreateButtonState() {
        let isReady = !trimmedName.isEmpty && !schedule.isEmpty && chosenColorName != nil && chosenEmoji != nil
        createButton.isEnabled = isReady
        createButton.backgroundColor = isReady ? UIColor(named: "Black [day]") : UIColor(named: "Gray")
    }
    
    private var scheduleSubtitle: String? {
        guard !schedule.isEmpty else { return nil }
        if schedule.count == WeekDay.allCases.count { return "Каждый день" }
        return WeekDay.mondayFirst
            .filter { schedule.contains($0) }
            .map(\.shortTitle)
            .joined(separator: ", ")
    }
    
    // MARK: - Actions
    @objc private func nameChanged() {
        updateCreateButtonState()
    }
    
    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    @objc private func createTapped() {
        guard !trimmedName.isEmpty, !schedule.isEmpty, let colorName = chosenColorName, let emoji = chosenEmoji else { return }
        
        let tracker = Tracker(
            id: UUID(),
            name: trimmedName,
            colorName: colorName,
            emoji: emoji,
            schedule: WeekDay.mondayFirst.filter { schedule.contains($0) }
        )
        onCreate?(tracker)
        dismiss(animated: true)
    }
    
    private func showSchedule() {
        let scheduleVC = ScheduleViewController(selectedDays: schedule)
        scheduleVC.onDone = { [weak self] days in
            self?.schedule = days
        }
        present(scheduleVC, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension NewHabitViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        SettingsRow.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        guard let row = SettingsRow(rawValue: indexPath.row) else { return cell }
        cell.backgroundColor = .clear
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = row.title
        cell.textLabel?.font = .systemFont(ofSize: 17)
        cell.detailTextLabel?.font = .systemFont(ofSize: 17)
        cell.detailTextLabel?.textColor = UIColor(named: "Gray")
        cell.detailTextLabel?.text = row == .schedule ? scheduleSubtitle : nil
        if indexPath.row < SettingsRow.allCases.count - 1 { cell.addSeparator() }
        return cell
    }
}
    
// MARK: - UITableViewDelegate

extension NewHabitViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        view.endEditing(true)
        
        guard let row = SettingsRow(rawValue: indexPath.row) else { return }
        switch row {
        case .category:
            break
        case .schedule:
            showSchedule()
        }
    }
}

// MARK: - UITextFieldDelegate
 
extension NewHabitViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension UITableViewCell {
    func addSeparator() {
        let line = UIView()
        line.backgroundColor = .separator
        line.translatesAutoresizingMaskIntoConstraints = false
        addSubview(line)
        NSLayoutConstraint.activate([
            line.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            line.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            line.bottomAnchor.constraint(equalTo: bottomAnchor),
            line.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }
}

// MARK: - UICollectionViewDataSource
extension NewHabitViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView === emojiCollectionView {
            return emojis.count
        } else {
            return colorNames.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView === emojiCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiCell.reuseIdentifier, for: indexPath) as? EmojiCell else {
                return UICollectionViewCell()
            }
            let emoji = emojis[indexPath.item]
            cell.configure(emoji: emoji,
                           isSelected: chosenEmoji == emoji)
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCell.reuseIdentifier, for: indexPath) as? ColorCell else {
                return UICollectionViewCell()
            }
            let colorName = colorNames[indexPath.item]
            cell.configure(colorName: colorName,
                           isSelected: chosenColorName == colorName)
            return cell
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension NewHabitViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView === emojiCollectionView {
            chosenEmoji = emojis[indexPath.item]
        } else {
            chosenColorName = colorNames[indexPath.item]
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let perRow: CGFloat = 6
        let side = floor(collectionView.bounds.width / perRow)
        return CGSize(width: side, height: side)
    }
}
