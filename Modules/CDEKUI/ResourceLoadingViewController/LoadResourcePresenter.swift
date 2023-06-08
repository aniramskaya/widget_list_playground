//
//  LoyaltyPointsPresenter.swift
//  Loyalty
//
//  Created by Alesya Volosach on 06.06.2023.
//

import Foundation

public protocol ResourceLoadingView {
    func display(_ isloading: Bool)
}

public protocol ResourceMessageView {
    associatedtype Message: Swift.Error

    func display(_ error: Message?)
}

public protocol ResourceContentView {
    associatedtype ResourceViewModel
    func display(_ viewModel: ResourceViewModel)
}


public final class LoadResourcePresenter<
    Resource,
    View: ResourceContentView,
    MessageView: ResourceMessageView
> {
    public typealias Message = MessageView.Message
    public typealias Mapper = (Resource) -> View.ResourceViewModel
    
    private let resourceView: View
    private let loadingView: ResourceLoadingView
    private let messageView: MessageView
    private let mapper: Mapper
    
    public init(
        resourceView: View,
        loadingView: ResourceLoadingView,
        messageView: MessageView,
        mapper: @escaping Mapper
    ) {
        self.resourceView = resourceView
        self.loadingView = loadingView
        self.messageView = messageView
        self.mapper = mapper
    }
    
    public func didStartLoading() {
        messageView.display(nil)
        loadingView.display(true)
    }
    
    public func didFinishLoading(with resource: Resource) {
        loadingView.display(false)
        resourceView.display(mapper(resource))
    }
    
    public func didFinishLoading(with error: Message) {
        loadingView.display(false)
        messageView.display(error)
    }
}
