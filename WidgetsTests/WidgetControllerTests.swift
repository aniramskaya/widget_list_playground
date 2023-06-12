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
 [✅] Вызывает presenter.didFinishLoading(with: Error) при ошибке загрузки
 [✅] Вызывает presenter.didFinishLoading(with: [Widget]) при успешной загрузке
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

    func test_load_deliversErrorOnLoadingError() throws {
        let (sut, spy) = makeSUT()

        sut.load()
        spy.complete(with: .failure(NSError.any()))
        
        XCTAssertEqual(spy.messages, [.didStartLoading, .load, .didFinishLoadingFailure])
    }

    func test_load_deliversWidgetsOnLoadingSuccess() throws {
        let (sut, spy) = makeSUT()
        let widgetId = UUID()

        sut.load()
        spy.complete(with: .success([WidgetStub(id: widgetId).erasedToWidget()]))
        RunLoop.main.run(until: Date() + 0.1)

        XCTAssertEqual(spy.messages, [.didStartLoading, .load, .didFinishLoadingSuccess([widgetId])])
    }

    func test_widgetController_tracksWidgetVisibility() throws {
        let (sut, spy) = makeSUT()
        let widget1Id = UUID()
        let widget2Id = UUID()
        
        let widget1 = WidgetStub(id: widget1Id).erasedToWidget()
        let widget2 = WidgetStub(id: widget2Id).erasedToWidget()

        sut.load()
        spy.complete(with: .success([widget1, widget2]))
        RunLoop.main.run(until: Date() + 0.1)

        XCTAssertEqual(spy.messages, [.didStartLoading, .load, .didFinishLoadingSuccess([widget1Id, widget2Id])])
        
        widget1.isDisplaying.send(false)
        RunLoop.main.run(until: Date() + 0.1)

        XCTAssertEqual(spy.messages, [
            .didStartLoading,
            .load,
            .didFinishLoadingSuccess([widget1Id, widget2Id]),
            .didFinishLoadingSuccess([widget2Id])
        ])
    }
    
    func test_widgetController_callsPresenterOnlyOnceForMultipleWdgetsUpdates() throws {
        let (sut, spy) = makeSUT()
        let widget1Id = UUID()
        let widget2Id = UUID()
        
        let widget1 = WidgetStub(id: widget1Id).erasedToWidget()
        let widget2 = WidgetStub(id: widget2Id).erasedToWidget()
        widget2.isDisplaying.send(false)

        sut.load()
        spy.complete(with: .success([widget1, widget2]))
        RunLoop.main.run(until: Date() + 0.1)

        XCTAssertEqual(spy.messages, [.didStartLoading, .load, .didFinishLoadingSuccess([widget1Id])])
        
        widget1.isDisplaying.send(false)
        widget2.isDisplaying.send(true)
        RunLoop.main.run(until: Date() + 0.1)

        XCTAssertEqual(spy.messages, [
            .didStartLoading,
            .load,
            .didFinishLoadingSuccess([widget1Id]),
            .didFinishLoadingSuccess([widget2Id])
        ])
    }

    // MARK: Private
    
    private func makeSUT() -> (WidgetListController<WidgetSpy, WidgetSpy>, WidgetSpy) {
        let spy = WidgetSpy()
        let sut = WidgetListController(loader: spy, presenter: spy)
        
        trackForMemoryLeaks(spy)
        trackForMemoryLeaks(sut)
        return (sut, spy)
    }
    
    private func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
        }
    }
}

class WidgetStub: UIViewController, Widget {
    typealias View = UIViewController
    
    var ui: UIViewController { self }
    var isDisplaying = CurrentValueSubject<Bool, Never>(true)
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
    enum Message: Equatable {
        case load
        case didStartLoading
        case didFinishLoadingSuccess([UUID])
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
        messages.append(.didFinishLoadingSuccess(resource.map { ($0 as! WidgetStub).id }))
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
