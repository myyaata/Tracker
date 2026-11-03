//
//  FiltersViewController.swift
//  Tracker
//
//  Created by арина сильченко on 4.11.26.
//

import UIKit

final class FiltersViewController: UIViewController {
    var onSelect: ((TrackerFilter) -> Void)?

    private let selectedFilter: TrackerFilter
    private let filters = TrackerFilter.allCases
    private let titleLabel = UILabel()
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    init(selectedFilter: TrackerFilter) {
        self.selectedFilter = selectedFilter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "White [day]")
        setupTitle()
        setupTableView()
    }
    
    private func setupTitle() {
        titleLabel.text = NSLocalizedString("filters.title", comment: "")
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = UIColor(named: "Black [day]")
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(CategoryCell.self, forCellReuseIdentifier: CategoryCell.reuseIdentifier)
        tableView.backgroundColor = .clear
        tableView.sectionHeaderTopPadding = 0
        tableView.rowHeight = 75
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNonzeroMagnitude))
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func isChecked(_ filter: TrackerFilter) -> Bool {
        switch filter {
        case .completed, .uncompleted: filter == selectedFilter
        case .all, .today: false
        }
    }
}

extension FiltersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CategoryCell.reuseIdentifier,
            for: indexPath
        ) as? CategoryCell else { return UITableViewCell() }
        let filter = filters[indexPath.row]
        cell.configure(title: filter.title, isChecked: isChecked(filter))
        return cell
    }
}

extension FiltersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        onSelect?(filters[indexPath.row])
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        .leastNormalMagnitude
    }
}

