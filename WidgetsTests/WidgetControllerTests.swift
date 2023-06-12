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
 [✅] Вызывает loader.load при старте загрузки
 [✅] Вызывает presenter.didStartLoading при старте загрузки
 [] Вызывает presenter.didFinishLoading(with: Error) при ошибке загрузки
 [] Вызывает presenter.didFinishLoading(with: [Widget]) при успешной загрузке
 [] При изменении видимости виджета вызывает presenter.didFinishLoading(with: [Widget])
 [] При одновременном изменении видимости нескольких виджетов вызывает presenter.didFinishLoading(with: [Widget]) только один раз
 
 */
final class WidgetListControllerTests: XCTestCase {
    func test_init_doesNothing() throws {
        let (_, spy) = makeSUT()

        XCTAssertEqual(spy.messages, [])
    }
    
    func test_load_callsLoaderLoadAndPresenterDidStartLoading() throws {
        let (sut, spy) = makeSUT()

        sut.load()
        
        XCTAssertEqual(spy.messages, [.didStartLoading, .load])
    }
    
    // MARK: Private
    
    private func makeSUT() -> (WidgetListController<WidgetSpy, WidgetSpy>, WidgetSpy) {
        let spy = WidgetSpy()
        let sut = WidgetListController(loader: spy, presenter: spy)
        
        return (sut, spy)
    }
}

class WidgetStub: UIViewController, Widget {
    typealias View = UIViewController
    
    var ui: UIViewController { self }
    var isDisplaying = CurrentValueSubject<Bool, Never>(false)
    var id: UUID
    
    init(id: UUID) {
        self.id = id
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class WidgetSpy: UIViewController, WidgetListPresenter, WidgetListLoader {
    enum Message {
        case load
        case didStartLoading
        case didFinishLoadingSuccess
        case didFinishLoadingFailure
    }
    
    var messages: [Message] = []
    var completions: [(Result<[Widgets.AnyWidget<UIViewController>?], Error>) -> Void] = []
    
    // MARK: - WidgetListPresenter
    typealias View = UIViewController

    func didStartLoading() {
        messages.append(.didStartLoading)
    }
    
    func didFinishLoading(with error: Error) {
        messages.append(.didFinishLoadingFailure)
    }

    func didFinishLoading(with resource: [UIViewController]) {
        messages.append(.didFinishLoadingSuccess)
    }
    
    // MARK: - WidgetListLoader
    func load(_ completion: @escaping (Result<[Widgets.AnyWidget<UIViewController>?], Error>) -> Void) {
        messages.append(.load)
        completions.append(completion)
    }
    
    func complete(with result: Result<[Widgets.AnyWidget<UIViewController>?], Error>, at index: Int = 0) {
        completions[index](result)
    }
}
