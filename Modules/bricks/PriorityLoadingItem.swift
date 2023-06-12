//
//  PriorityLoadingItem.swift
//  Widgets
//
//  Created by Марина Чемезова on 12.06.2023.
//

import Foundation

public protocol PriorityLoadingItem {
    associatedtype Success
    associatedtype Failure: Swift.Error
    var priority: ParallelPriority { get }
    
    func load(_ completion: @escaping (Result<Success, Failure>) -> Void)
}

public class AnyPriorityLoadingItem<Item: PriorityLoadingItem>: AnyPriorityLoadingItemBox<Item.Success, Item.Failure> {
    let base: Item
    init(base: Item) {
        self.base = base
    }
    override var priority: ParallelPriority { base.priority }
    
    override func load(_ completion: @escaping (Result<Item.Success, Item.Failure>) -> Void) {
        base.load(completion)
    }
}

public class AnyPriorityLoadingItemBox<Success, Failure: Error> {
    var priority: ParallelPriority { fatalError() }
    
    func load(_ completion: @escaping (Result<Success, Failure>) -> Void) {
        fatalError()
    }
}

public extension PriorityLoadingItem {
    func eraseToAnyPriorityLoadingItem() -> AnyPriorityLoadingItemBox<Success, Failure> {
        return AnyPriorityLoadingItem(base: self)
    }
}
