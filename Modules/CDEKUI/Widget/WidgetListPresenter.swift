//
//  WidgetListPresenter.swift
//  Widgets
//
//  Created by Марина Чемезова on 10.06.2023.
//

import Foundation

public protocol WidgetListPresenter {
    associatedtype View

    func didStartLoading()
    func didFinishLoading(with resource: [View])
    func didFinishLoading(with error: Error)
}
