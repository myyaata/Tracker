//
//  NewCategoryViewController.swift
//  Tracker
//
//  Created by арина сильченко on 2.11.26.
//

import UIKit

final class NewCategoryViewController: UIViewController {
    var onDone: ((String) -> String?)?
    private let titleLabel = UILabel()
    private let nameTextField = UITextField()
    private let doneButton = UIButton(type: .system)
    
    private var trimmedName: String {
        nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "White [day]")
        setupTitle()
        setupNameField()
        setupCreateButton()
        updateDoneButtonState()
    }
    
    private func setupTitle() {
        titleLabel.text = NSLocalizedString("newCategory.title", comment: "")
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = UIColor(named: "Black [day]")
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setupNameField() {
        nameTextField.attributedPlaceholder = NSAttributedString(
            string: NSLocalizedString("newCategory.placeholder", comment: ""),
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
    
    @objc private func nameChanged() {
        updateDoneButtonState()
    }
    
    private func setupCreateButton() {
        doneButton.backgroundColor = UIColor(named: "Black [day]")
        doneButton.setTitle(NSLocalizedString("newCategory.done", comment: ""), for: .normal)
        doneButton.setTitleColor(UIColor(named: "White [day]"), for: .normal)
        doneButton.setTitleColor(UIColor(named: "White [day]"), for: .disabled)
        doneButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        doneButton.layer.cornerRadius = 16
        doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        view.addSubview(doneButton)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func updateDoneButtonState() {
        let isReady = !trimmedName.isEmpty
        doneButton.isEnabled = isReady
        doneButton.backgroundColor = isReady ? UIColor(named: "Black [day]") : UIColor(named: "Gray")
    }

    @objc private func doneTapped() {
        if let errorMessage = onDone?(trimmedName) ?? nil {
            showError(errorMessage)
        } else {
            dismiss(animated: true)
        }
    }

    private func showError(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("common.ok", comment: ""), style: .default))
        present(alert, animated: true)
    }
}

extension NewCategoryViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
