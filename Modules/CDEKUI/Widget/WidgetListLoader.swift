//
//  WidgetListLoader.swift
//  Widgets
//
//  Created by Марина Чемезова on 10.06.2023.
//

import Foundation

public protocol WidgetListLoader {
    associatedtype View
    
    func load(_ completion: @escaping (Result<[AnyWidgetBox<View>?], Error>) -> Void)
}
