//
//  LoyaltyActionsWidgetLoader.swift
//  Widgets
//
//  Created by Марина Чемезова on 09.06.2023.
//

import UIKit

class LoyaltyActionsWidgetLoader: PriorityLoadingItem {
    let priority = ParallelizedLoaderPriority.optional
    let url: URL
    
    init(url: URL) {
        self.url = url
    }
    
    func load(_ completion: @escaping (Result<AnyWidget<UIViewController>, Error>) -> Void) {
        let widget = LoyaltyActionsWidget()
        widget.configure(with: url) { error in
            if let error {
                completion(.failure(error))
            } else {
                completion(.success(widget.erasedToWidget()))
            }
        }
    }
}
