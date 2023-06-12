//
//  CdekIdWidgetLoader.swift
//  Widgets
//
//  Created by Марина Чемезова on 09.06.2023.
//

import UIKit

class CdekIdWidgetLoader: PriorityLoadingItem {
    let priority = ParallelizedLoaderPriority.required
    
    func load(_ completion: @escaping (Result<AnyWidget<UIViewController>, Error>) -> Void) {
        completion(.success(CdekIdWidget().erasedToWidget()))
    }
}
