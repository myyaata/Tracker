//
//  ScheduleViewController.swift
//  Tracker
//
//  Created by арина сильченко on 21.09.26.
//

import UIKit

extension WeekDay {
    static let mondayFirst: [WeekDay] = [
        .monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday
    ]
}

final class ScheduleViewController: UIViewController {
    
    // MARK: - Output
    var onDone: ((Set<WeekDay>) -> Void)?
    
    // MARK: - State
    private var selectedDays: Set<WeekDay>
    private let days = WeekDay.mondayFirst
    
    // MARK: - UI
    private let titleLabel = UILabel()
    private let tableView = UITableView()
    private let doneButton = UIButton(type: .system)
    
    init(selectedDays: Set<WeekDay>) {
        self.selectedDays = selectedDays
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad( )
        view.backgroundColor = UIColor(named: "White [day]")
        setupTitle()
        setupDoneButton()
        setupTableView()
    }
    
    // MARK: - Setup
    private func setupTitle() {
        titleLabel.text = "Расписание"
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = UIColor(named: "Black [day]")
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 26),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setupDoneButton() {
        doneButton.setTitle("Готово", for: .normal)
        doneButton.setTitleColor(UIColor(named: "White [day]"), for: .normal)
        doneButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        doneButton.backgroundColor = UIColor(named: "Black [day]")
        doneButton.layer.cornerRadius = 16
        doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.backgroundColor = UIColor(named: "Background [day]")
        tableView.layer.cornerRadius = 16
        tableView.clipsToBounds = true
        tableView.rowHeight = 75
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        let idealHeight = tableView.heightAnchor.constraint(equalToConstant: CGFloat(days.count) * 75)
        idealHeight.priority = .defaultHigh
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(lessThanOrEqualTo: doneButton.topAnchor, constant: -16), idealHeight
        ])
    }
    
    // MARK: - Actions
    @objc private func switchChanged(_ sender: UISwitch) {
        let day = days[sender.tag]
        if sender.isOn {
            selectedDays.insert(day)
        } else {
            selectedDays.remove(day)
        }
    }
    
    @objc private func doneTapped() {
        onDone?(selectedDays)
        dismiss(animated: true)
    }
}

// MARK: - UITableViewDataSource
extension ScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        days.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let day = days[indexPath.row]
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.backgroundColor = UIColor(named: "Background [day]")?.withAlphaComponent(0.3)
        cell.selectionStyle = .none
        cell.textLabel?.text = day.fullTitle
        cell.textLabel?.font = .systemFont(ofSize: 17)
        let toggle = UISwitch()
        toggle.onTintColor = UIColor(named: "Blue")
        toggle.isOn = selectedDays.contains(day)
        toggle.tag = indexPath.row
        toggle.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
        cell.accessoryView = toggle
        if indexPath.row < days.count - 1 { cell.addSeparator() }
        return cell
    }
}

