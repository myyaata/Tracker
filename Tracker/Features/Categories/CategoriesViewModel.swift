//  CategoriesViewModel.swift
//  Tracker
//
//  Created by арина сильченко on 2.11.26.
//
import Foundation

typealias Binding<T> = (T) -> Void

final class CategoriesViewModel {
    var onCategorySelected: Binding<String>?
    private let store: TrackerCategoryStore
    private(set) var selectedTitle: String?
    var onCategoriesChange: Binding<[String]>?
    
    private(set) var categoryTitles: [String] = [] {
        didSet { onCategoriesChange?(categoryTitles) }
    }
    
    init(store: TrackerCategoryStore, selectedTitle: String?) {
        self.store = store
        self.selectedTitle = selectedTitle
        store.delegate = self
        loadCategories()
    }
    
    private func loadCategories() {
        categoryTitles = store.fetchCategories().map { $0.title }
    }
    
    func isSelected(at index: Int) -> Bool {
        categoryTitles[index] == selectedTitle
    }
    
    func didSelectCategory(at index: Int) {
        let title = categoryTitles[index]
        selectedTitle = title
        onCategorySelected?(title)
    }
    
    func addCategory(title: String) -> String? {
        do {
            try store.addCategory(title: title)
            return nil
        } catch TrackerCategoryStoreError.duplicateTitle {
            return "Такая категория уже есть"
        } catch {
            return "Не удалось сохранить категорию"
        }
    }
}

extension CategoriesViewModel: TrackerCategoryStoreDelegate {
    func trackerCategoryStoreDidUpdate() {
        loadCategories()
    }
}
