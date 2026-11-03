//
//  CategoriesViewController.swift
//  Tracker
//
//  Created by арина сильченко on 2.11.26.
//

import UIKit

final class CategoriesViewController: UIViewController {
    private let viewModel: CategoriesViewModel
    private let titleLabel = UILabel()
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let emptyStateStack = UIStackView()
    private let addButton = UIButton(type: .system)
    
    private let emptyStateImageView = UIImageView()
    private let emptyStateLabel = UILabel()
    
    
    init(viewModel: CategoriesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "White [day]")
        setupButton()
        setupTitle()
        setupTableView()
        setupEmptyState()
        
        viewModel.onCategoriesChange = { [weak self] _ in
            self?.tableView.reloadData()
            self?.updateEmptyState()
        }
        updateEmptyState()
    }
    
    private func updateEmptyState() {
        let isEmpty = viewModel.categoryTitles.isEmpty
        emptyStateStack.isHidden = !isEmpty
        tableView.isHidden = isEmpty
    }

    private func setupButton() {
        addButton.backgroundColor = UIColor(named: "Black [day]")
        addButton.setTitle(NSLocalizedString("categories.add", comment: ""), for: .normal)
        addButton.setTitleColor(UIColor(named: "White [day]"), for: .normal)
        addButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        addButton.layer.cornerRadius = 16
        addButton.addTarget(self, action: #selector(addCategoryButtonTapped), for: .touchUpInside)
        view.addSubview(addButton)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc private func addCategoryButtonTapped() {
        let newCategoryVC = NewCategoryViewController()
        newCategoryVC.onDone = { [weak self] title in
            self?.viewModel.addCategory(title: title) ?? nil
        }
        present(newCategoryVC, animated: true)
    }
    
    private func setupTitle() {
        titleLabel.text = NSLocalizedString("categories.title", comment: "")
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
            tableView.bottomAnchor.constraint(equalTo: addButton.topAnchor, constant: -16)
        ])
    }
    
    private func setupEmptyState() {
        emptyStateImageView.contentMode = .scaleAspectFit
        if let icon = UIImage(named: "trackers_empty_icon") {
            emptyStateImageView.image = icon
        } else {
            emptyStateImageView.image = UIImage(systemName: "sparkle")
            emptyStateImageView.tintColor = .systemGray3
        }
        
        emptyStateLabel.text = NSLocalizedString("categories.empty", comment: "")
        emptyStateLabel.font = .systemFont(ofSize: 12, weight: .medium)
        emptyStateLabel.textColor = UIColor(named: "Black [day]")
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.numberOfLines = 2
        
        emptyStateStack.axis = .vertical
        emptyStateStack.alignment = .center
        emptyStateStack.spacing = 8
        emptyStateStack.addArrangedSubview(emptyStateImageView)
        emptyStateStack.addArrangedSubview(emptyStateLabel)
        
        emptyStateStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyStateStack)
        
        NSLayoutConstraint.activate([
            emptyStateImageView.widthAnchor.constraint(equalToConstant: 80),
            emptyStateImageView.heightAnchor.constraint(equalToConstant: 80),
            
            emptyStateStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateStack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

extension CategoriesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.categoryTitles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryCell.reuseIdentifier, for: indexPath) as? CategoryCell else { return UITableViewCell() }
        cell.configure(title: viewModel.categoryTitles[indexPath.row], isChecked: viewModel.isSelected(at: indexPath.row))
        return cell
    }
}

extension CategoriesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelectCategory(at: indexPath.row)
        tableView.reloadData()
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        .leastNormalMagnitude
    }
}
