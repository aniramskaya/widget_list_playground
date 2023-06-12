//
//  WidgetListController.swift
//  Widgets
//
//  Created by Марина Чемезова on 09.06.2023.
//

import UIKit
import Combine

public final class WidgetListController<Presenter: WidgetListPresenter, Loader: WidgetListLoader> where Loader.View == Presenter.View {
    
    typealias Element = AnyWidget<Presenter.View>
    let presenter: Presenter
    let loader: Loader
    
    init(loader: Loader, presenter: Presenter) {
        self.loader = loader
        self.presenter = presenter
    }

    func load() {
        presenter.didStartLoading()
        loader.load { [weak self] (result: Result<[Element?], Error>) in
            guard let self else { return }
            switch result {
            case let .success(widgets):
                self.didLoadWidgets(widgets)
            case let .failure(error):
                self.presenter.didFinishLoading(with: error)
            }
        }
    }
    
    private var widgets: [Element] = []
    private var widgetObservers: [AnyCancellable] = []
    private var widgetUpdateOperation: BlockOperation?
    
    private func didLoadWidgets(_ widgets: [Element?]) {
        let nonEmptyWidgets = widgets.compactMap { $0 }
        self.widgets = nonEmptyWidgets
        widgetObservers = []
        widgetUpdateOperation?.cancel()
        for widget in nonEmptyWidgets {
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
            self.presenter.didFinishLoading(with: widgetsToDisplay.filter({ $0.isDisplaying.value }).map({ $0.ui }))
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
