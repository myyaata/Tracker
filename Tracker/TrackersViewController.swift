//
//  TrackersViewController.swift
//  Tracker
//
//  Created by арина сильченко on 1.09.26.
//

import UIKit

final class TrackersViewController: UIViewController {
    
    // MARK: - UI
    
    private let searchBar = UISearchBar()
    private let datePicker = UIDatePicker()
    private let dateLabel = UILabel()
    private let emptyStateImageView = UIImageView()
    private let emptyStateLabel = UILabel()
    private let emptyStateStack = UIStackView()
    private var collectionView: UICollectionView!
    
    // MARK: - Data
    
    private var categories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    
    private var selectedDate: Date = Date()
    private var searchText: String = ""
    
    private var visibleCategories: [TrackerCategory] {
        let weekDay = WeekDay.from(date: selectedDate)
        return categories.compactMap { category -> TrackerCategory? in
            let filteredTrackers = category.trackers.filter { tracker in
                let matchesSсhedule = tracker.schedule.isEmpty || tracker.schedule.contains(weekDay)
                let matchesSearch = searchText.isEmpty || tracker.name.lowercased().contains(searchText.lowercased())
                return matchesSсhedule && matchesSearch
            }
            guard !filteredTrackers.isEmpty else { return nil }
            return TrackerCategory(title: category.title, trackers: filteredTrackers)
        }
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupNavigationBar()
        setupSearchBar()
        setupCollectionView()
        setupEmptyState()
        updateEmptyState()
    }
    
    // MARK: - Navigation bar
    
    private func setupNavigationBar() {
        title = "Трекеры"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            style: .plain,
            target: self,
            action: #selector(addButtonTapped)
        )
        navigationItem.leftBarButtonItem?.tintColor = .label
        
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        
        let dateItem = UIBarButtonItem(customView: makeDateBadge())
        navigationItem.rightBarButtonItem = dateItem
    }
    
    private lazy var dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "dd.MM.yy"
        return f
    }()
    
    private func makeDateBadge() -> UIView {
        dateLabel.text = dateFormatter.string(from: selectedDate)
        dateLabel.font = .systemFont(ofSize: 17, weight: .regular)
        dateLabel.textColor = .label
        
        let container = UIView()
        
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.alpha = 0.011
        
        container.addSubview(dateLabel)
        container.addSubview(datePicker)
        
        NSLayoutConstraint.activate([
            container.widthAnchor.constraint(equalToConstant: 77),
            container.heightAnchor.constraint(equalToConstant: 34),
            
            dateLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            dateLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            
            datePicker.topAnchor.constraint(equalTo: container.topAnchor),
            datePicker.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            datePicker.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            datePicker.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])
        
        return container
    }
    
    // MARK: - Search bar
    
    private func setupSearchBar() {
        searchBar.placeholder = "Поиск"
        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal
        searchBar.backgroundImage = UIImage()
        searchBar.searchTextField.backgroundColor = UIColor(named: "SearchFieldColor")
        
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchBar)
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 7),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    // MARK: - Collection view
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 12, left: 16, bottom: 16, right: 16)
        layout.minimumInteritemSpacing = 9
        layout.minimumLineSpacing = 16
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: TrackerCollectionViewCell.reuseIdentifier)
        collectionView.register(
            TrackerSectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TrackerSectionHeaderView.reuseIdentifier
        )
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Empty state
    
    private func setupEmptyState() {
        emptyStateImageView.contentMode = .scaleAspectFit
        if let icon = UIImage(named: "trackers_empty_icon") {
            emptyStateImageView.image = icon
        } else {
            emptyStateImageView.image = UIImage(systemName: "sparkle")
            emptyStateImageView.tintColor = .systemGray3
        }
        
        emptyStateLabel.text = "Что будем отслеживать?"
        emptyStateLabel.font = .systemFont(ofSize: 12, weight: .medium)
        emptyStateLabel.textColor = .label
        emptyStateLabel.textAlignment = .center
        
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
    
    private func updateEmptyState() {
        let isEmpty = visibleCategories.isEmpty
        emptyStateStack.isHidden = !isEmpty
        collectionView.isHidden = isEmpty
    }
    
    // MARK: - Actions
    
    private let defaultCategoryTitle = "Важное"
    
    @objc private func addButtonTapped() {
        let vc = NewHabitViewController()
        vc.onCreate = { [weak self] tracker in
            self?.addTracker(tracker)
        }
        present(vc, animated: true)
    }
    
    @objc private func dateChanged() {
        selectedDate = datePicker.date
        dateLabel.text = dateFormatter.string(from: selectedDate)
        collectionView.reloadData()
        updateEmptyState()
    }
    
    private func addTracker(_ tracker: Tracker) {
        if let index = categories.firstIndex(where: { $0.title == defaultCategoryTitle }) {
            let old = categories[index]
            categories[index] = TrackerCategory(title: old.title, trackers: old.trackers + [tracker])
        } else {
            categories.append(TrackerCategory(title: defaultCategoryTitle, trackers: [tracker]))
        }
        collectionView.reloadData()
        updateEmptyState()
    }
    
    // MARK: - Completion logic
    
    private func isTrackerCompleted(_ tracker: Tracker) -> Bool {
        completedTrackers.contains {
            $0.id == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: selectedDate)
        }
    }
    
    private func completedDaysCount(for tracker: Tracker) -> Int {
        completedTrackers.filter{ $0.id == tracker.id }.count
    }
    
    private func isSelectedDateInFuture() -> Bool {
        Calendar.current.compare(selectedDate, to: Date(), toGranularity: .day) == .orderedDescending
    }
    
    private func toggleCompletion(for tracker: Tracker) {
        guard !isSelectedDateInFuture() else { return }
        if let index = completedTrackers.firstIndex(where: {
            $0.id == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: selectedDate)
        }) {
            completedTrackers.remove(at: index)
        } else {
            completedTrackers.append(TrackerRecord(id: tracker.id, date: selectedDate))
        }
    }
}

// MARK: - UISearchBarDelegate

extension TrackersViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
        collectionView.reloadData()
        updateEmptyState()
    }
 
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchText = ""
        searchBar.resignFirstResponder()
        collectionView.reloadData()
        updateEmptyState()
    }
}

// MARK: - UICollectionViewDataSource
extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        visibleCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCollectionViewCell.reuseIdentifier, for: indexPath) as? TrackerCollectionViewCell else {
            return UICollectionViewCell()
        }
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        cell.delegate = self
        cell.configure(with: tracker, isCompleted: isTrackerCompleted(tracker), completedDaysCount: completedDaysCount(for: tracker), isFutureDate: isSelectedDateInFuture())
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader, let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TrackerSectionHeaderView.reuseIdentifier, for: indexPath) as? TrackerSectionHeaderView else {
            return UICollectionReusableView()
        }
        header.configure(title: visibleCategories[indexPath.section].title)
        return header
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let spacing: CGFloat = 10
        let insets: CGFloat = 16 * 2
        let width = (collectionView.bounds.width - insets - spacing) / 2
        return CGSize(width: width, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: 18)
    }
}

// MARK: - TrackerCellDelegate
extension TrackersViewController: TrackerCellDelegate {
    func trackerCellDidTapCompleteButton(_ cell: TrackerCollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        toggleCompletion(for: tracker)
        collectionView.reloadItems(at: [indexPath])
    }
}
