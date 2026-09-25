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
    
    // MARK: - Default
    private enum Defaults {
        static let emoji = "❤️"
        static let colorName = "Color selection 12"
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
    private let cancelButton = UIButton(type: .system)
    private let createButton = UIButton(type: .system)
    private let rowTitles = ["Категория", "Расписание"]
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad( )
        view.backgroundColor = .systemBackground
        setupTitle()
        setupNameField()
        setupTableView()
        setupButtons()
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
        view.addSubview(nameTextField)
        
        NSLayoutConstraint.activate([
            nameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
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
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: CGFloat(rowTitles.count) * 75)
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
        
        let stack = UIStackView(arrangedSubviews: [cancelButton, createButton])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            stack.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    // MARK: - State helpers
    private var trimmedName: String {
        nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }
    
    private func updateCreateButtonState() {
        let isReady = !trimmedName.isEmpty && !schedule.isEmpty
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
        guard !trimmedName.isEmpty, !schedule.isEmpty else { return }
        
        let tracker = Tracker(
            id: UUID(),
            name: trimmedName,
            color: Defaults.colorName,
            emoji: Defaults.emoji,
            schedule: WeekDay.mondayFirst.filter { schedule.contains($0) }
        )
        onCreate?(tracker)
        dismiss(animated: true)
    }
}

// MARK: - UITableViewDataSource

extension NewHabitViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rowTitles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.backgroundColor = .clear
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = rowTitles[indexPath.row]
        cell.textLabel?.font = .systemFont(ofSize: 17)
        cell.detailTextLabel?.font = .systemFont(ofSize: 17)
        cell.detailTextLabel?.textColor = UIColor(named: "Gray")
        cell.detailTextLabel?.text = indexPath.row == 1 ? scheduleSubtitle : nil
        if indexPath.row < rowTitles.count - 1 { cell.addSeparator() }
        return cell
    }
}
    
// MARK: - UITableViewDelegate

extension NewHabitViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        view.endEditing(true)
        
        guard indexPath.row == 1 else { return } // «Категория» пока не работает
        
        let scheduleVC = ScheduleViewController(selectedDays: schedule)
        scheduleVC.onDone = { [weak self] days in
            self?.schedule = days
        }
        present(scheduleVC, animated: true)
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
