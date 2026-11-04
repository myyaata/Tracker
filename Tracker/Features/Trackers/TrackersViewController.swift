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
    private let filtersButton = UIButton(type: .system)
    
    private enum Layout {
        static let filtersButtonHeight: CGFloat = 50
        static let filtersButtonWidth: CGFloat = 114
        static let filtersButtonBottomInset: CGFloat = 16
    }
    
    // MARK: - Data
    
    private let trackerStore: TrackerStore
    private let categoryStore: TrackerCategoryStore
    private let recordStore: TrackerRecordStore
    
    private var categories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    
    private var selectedDate: Date = Date()
    private var searchText: String = ""
    
    private var currentFilter: TrackerFilter = .all
    
    private var visibleCategories: [TrackerCategory] {
        let weekDay = WeekDay.from(date: selectedDate)
        return categories.compactMap { category -> TrackerCategory? in
            let filteredTrackers = category.trackers.filter { tracker in
                let matchesSсhedule = tracker.schedule.isEmpty || tracker.schedule.contains(weekDay)
                let matchesSearch = searchText.isEmpty || tracker.name.lowercased().contains(searchText.lowercased())
                let matchesFilter: Bool
                switch currentFilter {
                case .all, .today: matchesFilter = true
                case .completed: matchesFilter = isTrackerCompleted(tracker)
                case .uncompleted: matchesFilter = !isTrackerCompleted(tracker)
                }
                return matchesSсhedule && matchesSearch && matchesFilter
            }
            guard !filteredTrackers.isEmpty else { return nil }
            return TrackerCategory(title: category.title, trackers: filteredTrackers)
        }
    }
    
    // MARK: - Lifecycle
    
    init(trackerStore: TrackerStore, trackerCategoryStore: TrackerCategoryStore, trackerRecordStore: TrackerRecordStore) {
        self.trackerStore = trackerStore
        self.categoryStore = trackerCategoryStore
        self.recordStore = trackerRecordStore
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "White [day]")
        
        setupNavigationBar()
        setupSearchBar()
        setupCollectionView()
        setupFiltersButton()
        setupEmptyState()
        updateEmptyState()
        
        trackerStore.delegate = self
        recordStore.delegate = self
        reloadFromStores()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AnalyticsService.report(event: .open, screen: "Main")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        AnalyticsService.report(event: .close, screen: "Main")
    }
    
    // MARK: - Navigation bar
    
    private func setupNavigationBar() {
        title = NSLocalizedString("trackers.title", comment: "")
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
        dateLabel.textColor = UIColor(named: "Black [day]")
        
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
        searchBar.placeholder = NSLocalizedString("trackers.search.placeholder", comment: "")
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
        collectionView.contentInset.bottom = Layout.filtersButtonHeight + Layout.filtersButtonBottomInset * 2
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 24),
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
        
        emptyStateLabel.text = NSLocalizedString("trackers.empty", comment: "")
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
        filtersButton.isHidden = !hasTrackersForSelectedDay

        let isEmpty = visibleCategories.isEmpty
        emptyStateStack.isHidden = !isEmpty
        collectionView.isHidden = isEmpty
        guard isEmpty else { return }
        
        if hasTrackersForSelectedDay {
            emptyStateImageView.image = UIImage(named: "search_empty_icon")
            emptyStateLabel.text = NSLocalizedString("trackers.notFound", comment: "")
        } else {
            emptyStateImageView.image = UIImage(named: "trackers_empty_icon")
            emptyStateLabel.text = NSLocalizedString("trackers.empty", comment: "")
        }
    }
    
    private var hasTrackersForSelectedDay: Bool {
        let weekDay = WeekDay.from(date: selectedDate)
        return categories.contains { category in
            category.trackers.contains { $0.schedule.isEmpty || $0.schedule.contains(weekDay) }
        }
    }
    
    // MARK: - Actions
    
    @objc private func addButtonTapped() {
        AnalyticsService.report(event: .click, screen: "Main", item: .addTrack)
        let vc = NewHabitViewController(categoryStore: categoryStore)
        vc.onCreate = { [weak self] tracker, category in
            self?.addTracker(tracker, categoryTitle: category)
        }
        present(vc, animated: true)
    }
    
    @objc private func dateChanged() {
        selectedDate = datePicker.date
        dateLabel.text = dateFormatter.string(from: selectedDate)
        collectionView.reloadData()
        updateEmptyState()
    }
    
    private func addTracker(_ tracker: Tracker, categoryTitle: String) {
        do {
            try trackerStore.addNewTracker(tracker, categoryTitle: categoryTitle)
        } catch {
            print("Не удалось добавить трекер: \(error)")
        }
    }
    
    private func reloadFromStores() {
        categories = categoryStore.fetchCategories()
        completedTrackers = recordStore.fetchRecords()
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
        if isTrackerCompleted(tracker) {
            do {
                try recordStore.deleteRecord(TrackerRecord(id: tracker.id, date: selectedDate))
            } catch {
                print("Не удалось снять отметку: \(error)")
            }
        } else {
            do {
                try recordStore.addNewRecord(TrackerRecord(id: tracker.id, date: selectedDate))
            } catch {
                print("Не удалось поставить отметку: \(error)")
            }
        }
    }
    
    // MARK: - FilterButton
    private func setupFiltersButton() {
        filtersButton.setTitle(NSLocalizedString("filters.title", comment: ""), for: .normal)
        filtersButton.setTitleColor(.white, for: .normal)
        filtersButton.titleLabel?.font = .systemFont(ofSize: 17)
        filtersButton.backgroundColor = UIColor(named: "Blue")
        filtersButton.layer.cornerRadius = 16
        filtersButton.addTarget(self, action: #selector(filtersButtonTapped), for: .touchUpInside)
        
        filtersButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(filtersButton)
        NSLayoutConstraint.activate([
            filtersButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filtersButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Layout.filtersButtonBottomInset),
            filtersButton.widthAnchor.constraint(equalToConstant: Layout.filtersButtonWidth),
            filtersButton.heightAnchor.constraint(equalToConstant: Layout.filtersButtonHeight)
        ])
    }
    
    @objc private func filtersButtonTapped() {
        AnalyticsService.report(event: .click, screen: "Main", item: .filter)
        let vc = FiltersViewController(selectedFilter: currentFilter)
        vc.onSelect = { [weak self] filter in
            self?.applyFilter(filter)
        }
        present(vc, animated: true)
    }
    
    private func applyFilter(_ filter: TrackerFilter) {
        if filter == .today {
            datePicker.date = Date()
            selectedDate = datePicker.date
            dateLabel.text = dateFormatter.string(from: selectedDate)
            currentFilter = .all
        } else {
            currentFilter = filter
        }
        collectionView.reloadData()
        updateEmptyState()
        filtersButton.setTitleColor(currentFilter == .all ? .white : UIColor(named: "Red"), for: .normal)
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
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
        collectionView.reloadData()
        updateEmptyState()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
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
    
    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemsAt indexPaths: [IndexPath],
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        guard let indexPath = indexPaths.first else { return nil }
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        
        return UIContextMenuConfiguration(actionProvider: { [weak self] _ in
            let edit = UIAction(title: NSLocalizedString("trackers.menu.edit", comment: "")) { _ in
                AnalyticsService.report(event: .click, screen: "Main", item: .edit)
                self?.editTracker(tracker)
            }
            let delete = UIAction(
                title: NSLocalizedString("trackers.menu.delete", comment: ""),
                attributes: .destructive
            ) { _ in
                AnalyticsService.report(event: .click, screen: "Main", item: .delete)
                self?.confirmDelete(tracker)
            }
            return UIMenu(children: [edit, delete])
        })
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfiguration configuration: UIContextMenuConfiguration,
        highlightPreviewForItemAt indexPath: IndexPath) -> UITargetedPreview? {
        makePreview(for: indexPath)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfiguration configuration: UIContextMenuConfiguration,
        dismissalPreviewForItemAt indexPath: IndexPath) -> UITargetedPreview? {
        makePreview(for: indexPath)
    }
    
    private func makePreview(for indexPath: IndexPath) -> UITargetedPreview? {
        guard let cell = collectionView.cellForItem(at: indexPath) as? TrackerCollectionViewCell else { return nil }
        return UITargetedPreview(view: cell.previewView)
    }
    
    private func editTracker(_ tracker: Tracker) {
        guard let categoryTitle = categories.first(where: { category in
            category.trackers.contains { $0.id == tracker.id }
        })?.title else { return }
        let completedDays = completedDaysCount(for: tracker)
        let newHabitVC = NewHabitViewController(
            categoryStore: categoryStore,
            mode: .edit(tracker: tracker, categoryTitle: categoryTitle, completedDays: completedDays)
        )
        newHabitVC.onCreate = { [weak self] updatedTracker, categoryTitle in
            do {
                try self?.trackerStore.updateTracker(updatedTracker, categoryTitle: categoryTitle)
            } catch {
                print("Не удалось обновить трекер: \(error)")
            }
        }
        present(newHabitVC, animated: true)
    }
    
    private func confirmDelete(_ tracker: Tracker) {
        let alert = UIAlertController(
            title: nil,
            message: NSLocalizedString("trackers.delete.confirm", comment: ""),
            preferredStyle: .actionSheet
        )
        alert.addAction(UIAlertAction(
            title: NSLocalizedString("trackers.menu.delete", comment: ""),
            style: .destructive
        ) { [weak self] _ in
            self?.deleteTracker(tracker)
        })
        alert.addAction(UIAlertAction(title: NSLocalizedString("common.cancel", comment: ""), style: .cancel))
        present(alert, animated: true)
    }
    
    private func deleteTracker(_ tracker: Tracker) {
        do {
            try trackerStore.deleteTracker(id: tracker.id)
        } catch {
            print("Не удалось удалить трекер: \(error)")
        }
    }
}

// MARK: - TrackerCellDelegate
extension TrackersViewController: TrackerCellDelegate {
    func trackerCellDidTapCompleteButton(_ cell: TrackerCollectionViewCell) {
        AnalyticsService.report(event: .click, screen: "Main", item: .track)
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        toggleCompletion(for: tracker)
    }
}

// MARK: - StoreDelegate
extension TrackersViewController: TrackerStoreDelegate, TrackerRecordStoreDelegate {
    func trackerStoreDidUpdate() {
        reloadFromStores()
    }
    
    func trackerRecordStoreDidUpdate() {
        reloadFromStores()
    }
}
