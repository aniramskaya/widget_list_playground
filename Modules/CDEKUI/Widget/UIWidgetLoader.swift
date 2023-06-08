//
//  WidgetLoader.swift
//  Widgets
//
//  Created by Марина Чемезова on 08.06.2023.
//

import Foundation

protocol UIWidgetLoader  {
    var isMandatory: Bool { get }

    func load(_ completion: @escaping (Result<any UIWidget, Swift.Error>) -> Void)
}
