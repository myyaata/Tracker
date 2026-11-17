//
//  OnboardingViewController.swift
//  Tracker
//
//  Created by арина сильченко on 1.11.26.
//

import UIKit

final class OnboardingViewController: UIPageViewController {
    
    private let button = UIButton()
    private let pageControl = UIPageControl()
    
    var onFinish: (() -> Void)?
    
    private lazy var pages: [UIViewController] = [
        OnboardingPageViewController(imageName: "onboarding_blue", title: NSLocalizedString("onboarding.page1", comment: "")),
        OnboardingPageViewController(imageName: "onboarding_red", title: NSLocalizedString("onboarding.page2", comment: "")),

    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setViewControllers([pages[0]], direction: .forward, animated: false)
        setupButton()
        setupPageControl()
        dataSource = self
        delegate = self
    }
    
    init() {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    private func setupButton() {
        button.setTitle(NSLocalizedString("onboarding.button", comment: ""), for: .normal)
        button.backgroundColor = UIColor(named: "Black [day]")
        button.setTitleColor(UIColor(named: "White [day]"), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 60),
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50)
        ])
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    private func setupPageControl() {
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = UIColor(named: "Black [day]")
        pageControl.pageIndicatorTintColor = UIColor(named: "Black [day]")?.withAlphaComponent(0.3)
        view.addSubview(pageControl)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: button.topAnchor, constant: -24)
        ])
    }
    
    @objc private func buttonTapped() {
        onFinish?()
    }
}

extension OnboardingViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentVCIndex = pages.firstIndex(of: viewController) else { return nil }
        let previousIndex = currentVCIndex - 1
        if previousIndex < 0 { return nil }
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentVCIndex = pages.firstIndex(of: viewController) else { return nil }
        let nextIndex = currentVCIndex + 1
        if nextIndex >= pages.count { return nil }
        return pages[nextIndex]
    }
}

extension OnboardingViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed, let currentVC = viewControllers?.first, let index = pages.firstIndex(of: currentVC) else { return }
        pageControl.currentPage = index
    }
}
