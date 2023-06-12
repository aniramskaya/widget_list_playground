//
//  ParallelPriorityLoaderTests.swift
//  WidgetsTests
//
//  Created by Марина Чемезова on 12.06.2023.
//

import Foundation
import XCTest
import Widgets

/**
 Что тестируем
 
 ### Проверки логики загрузки
 
 [✅] Передаем 3 элемента с приоритетом ниже mandatory, равный ему и выше. Завершаем ошибкой загрузку того, что выше mandatory, проверяем что загрузка завершилась ошибкой.
 [✅] Передаем 3 элемента с приоритетом ниже mandatory, равный ему и выше. Завершаем ошибкой загрузку того, что равен mandatory, проверяем что загрузка завершилась ошибкой.
 [✅] Передаем 3 элемента с приоритетом ниже mandatory, равный ему и выше. Завершаем ошибкой загрузку того, что ниже mandatory, проверяем что загрузка не завершена.
 [✅] Передаем 3 элемента с приоритетом ниже mandatory, равный ему и выше. Ждем таймаут. Проверяем что загрузка завершилась ошибкой.
 [✅] Передаем 3 элемента с приоритетом ниже mandatory, равный ему и выше. Завершаем загрузку того, что выше mandatory, проверяем что загрузка не завершена. Завершаем загрузку того, что равен mandatory - проверяем что загрузка завершена. Завершаем загрузку последнего - никаких новых действий не происходит.
 
 ### Проверки независимости запросов
 [] Запускаем 2 загрузки. Проверяем что когда одна из них завершилась, вторая все еще идет.

 */

class ParallelPriorityLoaderTests: XCTestCase {
    enum Constants {
        static let mandtoryPriority: UInt = 100
    }
    
    func test_load_deliversRequiredLoadingErrorWhenOverMandatoryFails() {
        let (high, med, low) = makeItems()
        let sut = ParallelPriorityLoader<UUID, NSError>()

        expect(
            sut: sut,
            loads: [high, med, low].erased,
            timeout: 0.5,
            when: { high.complete(with: .failure(NSError.any())) },
            toCompleteWith: .failure(ParallelizedLoaderError.requredLoadingFailed)
        )
    }
    
    func test_load_deliversRequiredLoadingErrorWhenMandatoryFails() {
        let (high, med, low) = makeItems()
        let sut = ParallelPriorityLoader<UUID, NSError>()

        expect(
            sut: sut,
            loads: [high, med, low].erased,
            timeout: 0.5,
            when: { med.complete(with: .failure(NSError.any())) },
            toCompleteWith: .failure(ParallelizedLoaderError.requredLoadingFailed)
        )
    }

    func test_load_deliversTimeoutErrorWhenAtLeaseOneMandatoryTimedOut() {
        let (high, med, low) = makeItems()
        let sut = ParallelPriorityLoader<UUID, NSError>()

        expect(
            sut: sut,
            loads: [high, med, low].erased,
            timeout: 0.5,
            when: {
                low.complete(with: .success(UUID()))
                high.complete(with: .success(UUID()))
            },
            toCompleteWith: .failure(ParallelizedLoaderError.timeoutExpired)
        )
    }

    func test_load_deliversSuccessWhenMandatorySucceeded() {
        let (high, med, low) = makeItems()
        let sut = ParallelPriorityLoader<UUID, NSError>()

        let highSuccess = UUID()
        let medSuccess = UUID()
        expect(
            sut: sut,
            loads: [high, med, low].erased,
            timeout: 0.5,
            when: {
                high.complete(with: .success(highSuccess))
                med.complete(with: .success(medSuccess))
            },
            toCompleteWith: .success([highSuccess, medSuccess, nil])
        )
    }

    private func makeItems() -> (ParallelPriorityItemSpy, ParallelPriorityItemSpy, ParallelPriorityItemSpy) {
        return (
            ParallelPriorityItemSpy(priority: .custom(Constants.mandtoryPriority + 1)),
            ParallelPriorityItemSpy(priority: .custom(Constants.mandtoryPriority)),
            ParallelPriorityItemSpy(priority: .custom(Constants.mandtoryPriority - 1))
        )
    }
    
    private func expect(sut: ParallelPriorityLoader<UUID, NSError>, loads items: [AnyPriorityLoadingItem<UUID, NSError>], timeout: TimeInterval, when action: () -> Void, toCompleteWith expectedResult: Result<[UUID?], Error>) {
        let exp = expectation(description: "Wait for loading to complete")
        sut.load(
            items: items,
            mandatoryPriority: .custom(Constants.mandtoryPriority),
            timeout: timeout
        ) { result in
            switch (result, expectedResult) {
            case let (.failure(error), .failure(expectedError)):
                XCTAssertEqual(error as NSError, expectedError as NSError)
            case let (.success(value), .success(expectedValue)):
                XCTAssertEqual(value, expectedValue)
            default:
                XCTFail("Expected \(expectedResult) got \(result) instead")
            }
            exp.fulfill()
        }
        action()

        wait(for: [exp], timeout: 1.0)
    }

}

private extension Array where Element == ParallelPriorityItemSpy {
    var erased: [AnyPriorityLoadingItem<UUID, NSError>] { self.map { $0.eraseToAnyPriorityLoadingItem() } }
}

private class ParallelPriorityItemSpy: PriorityLoadingItem {
    typealias Success = UUID
    typealias Failure = NSError
    
    let priority: Widgets.ParallelPriority
    
    init(priority: Widgets.ParallelPriority) {
        self.priority = priority
    }

    enum Message {
        case load
    }
    var messages: [Message] = []
    var completions: [(Result<UUID, NSError>) -> Void] = []
    
    func load(_ completion: @escaping (Result<UUID, NSError>) -> Void) {
        messages.append(.load)
        completions.append(completion)
    }
    
    func complete(with result: Result<UUID, NSError>, at index: Int = 0) {
        completions[index](result)
    }
}

extension NSError {
    static func any() -> NSError {
        return NSError(domain: UUID().uuidString, code: 1)
    }
}
