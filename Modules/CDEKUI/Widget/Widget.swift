//
//  Widget.swift
//  Widgets
//
//  Created by Марина Чемезова on 07.06.2023.
//

import Foundation
import Combine

public protocol Widget<View> {
    associatedtype View
    
    var ui: View { get }
    var isDisplaying: CurrentValueSubject<Bool, Never> { get }
}


// MARK: - Type erasure
public class AnyWidgetBox<View> {
    var ui: View { fatalError() }
    var isDisplaying: CurrentValueSubject<Bool, Never> { fatalError() }
}

public class AnyWidgetBoxBase<P: Widget>: AnyWidgetBox<P.View> {
    let base: P
    override var ui: P.View { return base.ui }
    override var isDisplaying: CurrentValueSubject<Bool, Never> { return base.isDisplaying }
    init(_ base: P) { self.base = base }
}

extension Widget {
    func erasedToWidget() -> AnyWidgetBox<View> {
        return AnyWidgetBoxBase(self)
    }
}
