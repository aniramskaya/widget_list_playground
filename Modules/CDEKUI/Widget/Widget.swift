//
//  Widget.swift
//  Widgets
//
//  Created by Марина Чемезова on 07.06.2023.
//

import Foundation
import Combine

public protocol Widget {
    associatedtype View
    
    var ui: View { get }
    var isDisplaying: CurrentValueSubject<Bool, Never> { get }
}


// MARK: - Type erasure

public struct AnyWidget<View>: Widget {
    
    private class AnyWidgetBox<View> {
        var ui: View { fatalError() }
        var isDisplaying: CurrentValueSubject<Bool, Never> { fatalError() }
    }

    private class AnyWidgetBoxBase<P: Widget>: AnyWidgetBox<P.View> {
        let base: P
        override var ui: P.View { return base.ui }
        override var isDisplaying: CurrentValueSubject<Bool, Never> { return base.isDisplaying }
        init(_ base: P) { self.base = base }
    }
    
    private let box: AnyWidgetBox<View>
    
    public init<T>(_ wrappee: T) where T: Widget, T.View == View {
        box = AnyWidgetBoxBase(wrappee)
    }

    public var ui: View { box.ui }
    public var isDisplaying: CurrentValueSubject<Bool, Never> { box.isDisplaying }
}


extension Widget {
    func erasedToWidget() -> AnyWidget<View> {
        return AnyWidget(self)
    }
}
