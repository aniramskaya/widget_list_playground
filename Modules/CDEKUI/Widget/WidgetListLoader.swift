//
//  WidgetListLoader.swift
//  Widgets
//
//  Created by Марина Чемезова on 08.06.2023.
//

import Foundation

// Инстанцирует и конфигурирует виджеты с помощью items: [UIWidgetLoader] и реализует логику загрузки обязательных/необязательных виджетов с таймаутом, как было в шоппинге
class WidgetListLoader {
    func load(items: [UIWidgetLoader], timeout: TimeInterval, completion: @escaping (Result<[any UIWidget], Swift.Error>) -> Void) {
        // TODO: Loading logic
    }
}
