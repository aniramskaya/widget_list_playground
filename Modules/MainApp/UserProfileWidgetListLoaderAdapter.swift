//
//  WidgetListLoaderAdapter.swift
//  Widgets
//
//  Created by Марина Чемезова on 09.06.2023.
//

import UIKit

class UserProfileWidgetListLoaderAdapter: WidgetListLoader {
    let dtoLoader: UserProfileWidgetsDTOLoader
    let priorityLoader = ParallelPriorityLoader<AnyWidget<View>, Error>()
    
    init(dtoLoader: UserProfileWidgetsDTOLoader) {
        self.dtoLoader = dtoLoader
    }
    
    func load(_ completion: @escaping (Result<[AnyWidget<UIViewController>?], Error>) -> Void) {
        dtoLoader.load { [weak self] result in
            guard let self else { return }
            switch result {
            case let .success(dto):
                self.priorityLoader.load(
                    items: dto.widgets.map { $0.widgetLoader },
                    mandatoryPriorityLevel: .required,
                    timeout: 1.0) { result in
                        switch result {
                        case let .success(widgets):
                            completion(.success(widgets))
                        case let .failure(error):
                            completion(.failure(error))
                        }
                    }
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}
