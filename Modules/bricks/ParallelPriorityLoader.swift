//
//  MandatorySynchronizer.swift
//  Widgets
//
//  Created by Марина Чемезова on 08.06.2023.
//

import Foundation

public class ParallelPriorityLoader<Success, Failure: Swift.Error> {
    public typealias Element = AnyPriorityLoadingItemBox<Success, Failure>
    
    public func load(
        items: [Element],
        mandatoryPriorityLevel: ParallelPriority,
        timeout: TimeInterval,
        completion: @escaping (Result<[Success?], Swift.Error>) -> Void
    ) {
        let id = UUID()
        let loader = InternalPriorityLoader(items: items, mandatoryPriorityLevel: mandatoryPriorityLevel, timeout: timeout) { [weak self] result in
            completion(result)
            self?.removeLoader(id: id)
        }
        addLoader(loader, id: id)
        loader.load()
    }
    
    // MARK: - Private
    
    private var executingLoaders: [UUID: InternalPriorityLoader<Success, Failure>] = [:]
    private var executingLoadersLock = NSRecursiveLock()
    
    private func addLoader(_ loader: InternalPriorityLoader<Success, Failure>, id: UUID) {
        executingLoadersLock.lock()
        executingLoaders[id] = loader
        executingLoadersLock.unlock()
    }
    
    private func removeLoader(id: UUID) {
        executingLoadersLock.lock()
        executingLoaders[id] = nil
        executingLoadersLock.unlock()
    }
}

public enum ParallelizedLoaderError: Error {
    case requredLoadingFailed
    case timeoutExpired
}

private class InternalPriorityLoader<Success, Failure: Swift.Error> {
    typealias Element = AnyPriorityLoadingItemBox<Success, Failure>
    
    private let items: [Element]
    private var results: [Success?]
    private let mandatoryPriorityLevel: ParallelPriority
    private let completion: (Result<[Success?], Swift.Error>) -> Void
    private let timer: Timer

    init(
        items: [Element],
        mandatoryPriorityLevel: ParallelPriority,
        timeout: TimeInterval,
        completion: @escaping (Result<[Success?], Swift.Error>) -> Void
    ) {
        self.items = items
        self.results = [Success?](repeating: nil, count: items.count)
        self.mandatoryPriorityLevel = mandatoryPriorityLevel
        self.timer = Timer(timeInterval: timeout, repeats: false, block: { _ in
            completion(.failure(ParallelizedLoaderError.timeoutExpired))
        })
        self.completion = completion
    }

    deinit {
        timer.invalidate()
    }

    func load() {
        for (index, item) in items.enumerated() {
            item.load { [weak self] result in
                guard let self else { return }
                switch result {
                case .failure:
                    if item.priority >= self.mandatoryPriorityLevel {
                        self.completion(.failure(ParallelizedLoaderError.requredLoadingFailed))
                        return
                    }
                case let .success(value):
                    self.results[index] = value
                }
                self.completeIfNeeded()
            }
        }
    }
    
    // MARK: - Private
    
    private func completeIfNeeded() {
        var areAllMandatoryFinished = true
        for (index, item) in items.enumerated() {
            if item.priority >= mandatoryPriorityLevel {
                if results[index] == nil {
                    areAllMandatoryFinished = false
                }
            }
        }
        if areAllMandatoryFinished {
            completion(.success(results))
        }
    }
}
