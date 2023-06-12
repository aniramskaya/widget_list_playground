//
//  WidgetsTests.swift
//  WidgetsTests
//
//  Created by Марина Чемезова on 07.06.2023.
//

import UIKit
import XCTest
import Combine
@testable import Widgets

/**
 [] Выводим виджеты с разным состоянием isDisplaying. Проверяем, что они стали дочерними контроллерами родительского контроллера и у каждого из них были вызваны методы willMove(to:), didMove(to:)
 [] Выводим виджеты с разным состоянием isDisplaying. Те, которые isDisplaying = true отображаются на экране. Остальные - не отображаются.
 [] Выводим виджеты с разным состоянием isDisplaying. При изменении isDisplaying у виджетов они соответствующим образом отображаются/ скрываются на экране
 [] Выводим виджеты с разным состоянием isDisplaying. Изменяем сразу у двух виджетов состояние isDisplaying. Проверяем что их отображение на экране меняется только после выполнения цикла runloop, а не сразу
 
 */
final class WidgetListViewControllerTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }
}


class WidgetSpy: UIViewController, Widget {
    enum Message {
        case willMoveToParent
        case didMoveToParent
    }
    
    var ui: UIViewController { self }
    var isDisplaying = CurrentValueSubject<Bool, Never>(false)
    
    //override func will
    
}
