//
//  WidgetListViewController.swift
//  Widgets
//
//  Created by Марина Чемезова on 07.06.2023.
//

import Foundation
import Combine
import UIKit

public class WidgetListViewController: UIViewController, ResourceContentView {
    public typealias ResourceViewModel = [any UIWidget]

    internal var scrollView: UIScrollView!
    internal var stackView: UIStackView!
    
    internal var refreshControl: UIRefreshControl!
    internal var widgets: [any UIWidget] = []
    internal var widgetObservers: [AnyCancellable] = []
    
    public var onRefreshNeeded: (() -> Void)?
    public var titleView: (() -> UIView?)?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        attachTitleView()
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(onRefresh), for: .valueChanged)
        scrollView.insertSubview(refreshControl, at: 0)
        self.refreshControl = refreshControl
    }
    
    public override func willMove(toParent: UIViewController?) {
        super.willMove(toParent: parent)
        if parent == nil {
            refreshControl.endRefreshing()
            detachAllWidgets()
        }
    }
    
    public func display(_ widgets: [any UIWidget]) {
        detachAllWidgets()
        self.widgets = widgets
        attach(widgets)
        refreshControl.endRefreshing()
    }
    
    // MARK: - Private
    
    private func attachTitleView() {
        if let titleView = titleView?() {
            stackView.insertArrangedSubview(titleView, at: 0)
        }
    }

    @objc private func onRefresh() {
        refreshControl.beginRefreshing()
        onRefreshNeeded?()
    }
    
    // MARK: - Widget management
    
    private var widgetsToAnimate: [(UIViewController, Bool)] = []
    private func animateWidgetsVisibility() {
        UIView.animate(withDuration: 0.3, delay: 0, options: []) {
            for widget in self.widgetsToAnimate {
                widget.0.view.isHidden = !widget.1
            }
            self.widgetsToAnimate = []
            self.stackView.layoutIfNeeded()
        }
    }
    
    private var animationOperation: BlockOperation?
    private func enqueueWidgetVisibilityAnimation() {
        guard animationOperation == nil else { return }
        let op = BlockOperation(block: {
            self.animateWidgetsVisibility()
            self.animationOperation = nil
        })
        self.animationOperation = op
        OperationQueue.main.addOperation(op)
    }
    
    private func updateWidgetVisibility(_ widget: (UIViewController, Bool)) {
        widgetsToAnimate.append(widget)
        enqueueWidgetVisibilityAnimation()
    }
    
    private func attach(_ widgets: [any UIWidget]) {
        for widget in widgets {
            addChild(widget.ui)
            widget.ui.view.isHidden = !widget.isDisplaying.value
            widgetObservers.append(widget.isDisplaying.sink(receiveValue: { [weak self] isDisplaying in
                self?.updateWidgetVisibility((widget.ui, isDisplaying))
            }))
            stackView.addArrangedSubview(widget.ui.view)
            widget.ui.didMove(toParent: self)
        }
    }

    private func detachAllWidgets() {
        widgetObservers.forEach {
            $0.cancel()
        }
        widgetObservers = []
        widgets.forEach {
            $0.ui.willMove(toParent: nil)
            $0.ui.view.removeFromSuperview()
            $0.ui.removeFromParent()
        }
        widgets = []
    }
}

extension WidgetListViewController {
    public enum WidgetPosition {
        case top
        case middle
        case bottom
    }

    func scrollTo(_ widget: any UIWidget, position: WidgetPosition, shift: CGFloat = 0) {
        guard widget.isDisplaying.value else { return }
        var scrollOffset: CGPoint = .zero
        switch position {
        case .top:
            scrollOffset = CGPoint(x: 0, y: widget.ui.view.frame.minY - shift)
        case .middle:
            scrollOffset = CGPoint(x: 0, y: widget.ui.view.frame.midY - scrollView.frame.size.height / 2 - shift)
        case .bottom:
            scrollOffset = CGPoint(x: 0, y: widget.ui.view.frame.maxY - scrollView.frame.size.height / 2 - shift)
        }
        scrollView.setContentOffset(scrollOffset, animated: true)
    }
}
