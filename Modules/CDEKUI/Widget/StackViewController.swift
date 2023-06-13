//
//  WidgetListViewController.swift
//  Widgets
//
//  Created by Марина Чемезова on 07.06.2023.
//

import Foundation
import Combine
import UIKit

public class StackViewController: UIViewController, ResourceContentView {
    public typealias ResourceViewModel = [UIViewController]

    internal var scrollView: UIScrollView!
    internal var stackView: UIStackView!
    internal var childrenStackView: UIStackView!
    
    internal var refreshControl: UIRefreshControl!
    
    public var onRefreshNeeded: (() -> Void)?
    public var titleView: (() -> UIView?)?
    
    override public func loadView() {
        super.loadView()
        view = UIView()
        setupUI()
    }
    
    public override func willMove(toParent: UIViewController?) {
        super.willMove(toParent: parent)
        if parent == nil {
            refreshControl.endRefreshing()
        }
    }
    
    public func display(_ viewControllers: [UIViewController]) {
        update(viewControllers)
        refreshControl.endRefreshing()
    }
    
    // MARK: - Private
    
    private func setupUI() {
        loadScrollView()
        loadStackView()
        loadChildrenStackView()
        
        attachTitleView()
        attachRefreshControl()
    }
    
    private func loadScrollView() {
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.fitIntoView(view)
    }
    
    private func loadStackView() {
        stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
    }
    
    private func loadChildrenStackView() {
        childrenStackView = UIStackView()
        childrenStackView.axis = .vertical
        childrenStackView.alignment = .fill
        childrenStackView.distribution = .equalSpacing
        childrenStackView.spacing = 0
        childrenStackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(childrenStackView)
    }
    
    private func attachTitleView() {
        if let titleView = titleView?() {
            stackView.insertArrangedSubview(titleView, at: 0)
        }
    }

    private func attachRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(onRefresh), for: .valueChanged)
        scrollView.insertSubview(refreshControl, at: 0)
        self.refreshControl = refreshControl
    }
    
    @objc private func onRefresh() {
        refreshControl.beginRefreshing()
        onRefreshNeeded?()
    }
    
    private func update(_ viewControllers: [UIViewController]) {
        let (controllersToRemove, controllersToInsert) = diff(newItems: viewControllers, oldItems: children)
        
        detach(controllersToRemove)

        for (index, controller) in controllersToInsert {
            addChild(controller)
            childrenStackView.insertArrangedSubview(controller.view, at: index)
            controller.didMove(toParent: self)
        }
    }

    private func detach(_ controllers: [UIViewController]) {
        controllers.forEach {
            $0.willMove(toParent: nil)
            $0.view.removeFromSuperview()
            $0.removeFromParent()
        }
    }
    
    private func diff(newItems: [UIViewController], oldItems: [UIViewController]) -> ([UIViewController], [(Int, UIViewController)]) {
        let diff = newItems.difference(from: oldItems) { existing, ongoing in
            ongoing === existing
        }

        var controllersToRemove: [UIViewController] = []
        var controllersToInsert: [(Int, UIViewController)] = []
        for change in diff {
            switch change {
            case let .remove(offset: _, element: controller, associatedWith: _):
                controllersToRemove.append(controller)
            case let .insert(offset: index, element: controller, associatedWith: _):
                controllersToInsert.append((index, controller))
            }
        }
        return (controllersToRemove, controllersToInsert)
    }
}

extension StackViewController {
    public enum WidgetPosition {
        case top
        case middle
        case bottom
    }

    func scrollTo(_ viewController: UIViewController, position: WidgetPosition, shift: CGFloat = 0) {
        guard
            children.contains(where: { $0 === viewController }),
            !viewController.view.isHidden
        else { return }
        var scrollOffset: CGPoint = .zero
        switch position {
        case .top:
            scrollOffset = CGPoint(x: 0, y: viewController.view.frame.minY - shift)
        case .middle:
            scrollOffset = CGPoint(x: 0, y: viewController.view.frame.midY - scrollView.frame.size.height / 2 - shift)
        case .bottom:
            scrollOffset = CGPoint(x: 0, y: viewController.view.frame.maxY - scrollView.frame.size.height / 2 - shift)
        }
        scrollOffset.y = max(scrollOffset.y, 0)
        scrollView.setContentOffset(scrollOffset, animated: true)
    }
}
