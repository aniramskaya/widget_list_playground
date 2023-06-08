//
//  Widget.swift
//  Widgets
//
//  Created by Марина Чемезова on 07.06.2023.
//

import Foundation
import Combine

public protocol Widget: AnyObject {
    associatedtype View
    
    var ui: View { get }
    var isDisplaying: CurrentValueSubject<Bool, Never> { get }
}
