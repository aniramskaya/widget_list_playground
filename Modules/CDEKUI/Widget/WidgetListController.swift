//
//  WidgetListController.swift
//  Widgets
//
//  Created by Марина Чемезова on 09.06.2023.
//

import UIKit
import Combine

public protocol WidgetListPresenter {
    associatedtype View

    func displayLoading()
    func display(with resource: [View])
    func display(with error: Error)
}

public protocol WidgetListLoader {
    associatedtype View
    
    func load<Element: Widget>(_ completion: @escaping (Result<[Element], Error>) -> Void) where Element.View == View
}

public final class WidgetListController<Loader: WidgetListLoader, Presenter: WidgetListPresenter, Element: Widget> where Loader.View == Presenter.View, Element.View == Presenter.View {
    let loader: Loader
    let presenter: Presenter
    
    init(loader: Loader, presenter: Presenter) {
        self.loader = loader
        self.presenter = presenter
    }
    
    func load() {
        presenter.displayLoading()
        loader.load { [weak self] (result: Result<[Element], Error>) in
            guard let self else { return }
            switch result {
            case let .success(widgets):
                self.didLoadWidgets(widgets)
            case let .failure(error):
                self.presenter.display(with: error)
            }
        }
    }
    
    private var widgets: [Element] = []
    private var widgetObservers: [AnyCancellable] = []
    private var widgetUpdateOperation: BlockOperation?
    
    private func didLoadWidgets(_ widgets: [Element]) {
        self.widgets = widgets
        widgetObservers = []
        widgetUpdateOperation?.cancel()
        for widget in widgets {
            widgetObservers.append(widget.isDisplaying.sink(receiveValue: { [weak self] _ in
                self?.enqueueWidgetUpdate()
            }))
        }
        enqueueWidgetUpdate()
    }
    
    private func enqueueWidgetUpdate() {
        cancelWidgetUpdateIfNeeded()
        
        let updateOperation = BlockOperation()
        updateOperation.addExecutionBlock { [unowned updateOperation] in
            guard !updateOperation.isCancelled else { return }
            let widgetsToDisplay = self.widgets
            self.presenter.display(with: widgetsToDisplay.filter({ $0.isDisplaying.value }).map({ $0.ui }))
        }
        widgetUpdateOperation = updateOperation
        OperationQueue.main.addOperation(updateOperation)
    }
    
    private func cancelWidgetUpdateIfNeeded() {
        if let widgetUpdateOperation {
            widgetUpdateOperation.cancel()
        }
        widgetUpdateOperation = nil
    }
}
