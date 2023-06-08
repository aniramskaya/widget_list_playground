//
//  LCMViewController.swift
//  Loyalty
//
//  Created by Alesya Volosach on 06.06.2023.
//

import Foundation
import UIKit

/// (Loading & Content & Message) VC
public class LoadResourceViewController<
    ResourceContentController: UIViewController,
    Message: Swift.Error
>: UIViewController, ResourceLoadingView, ResourceMessageView, ResourceContentView
where ResourceContentController: ResourceContentView {
    
    public typealias ResourceViewModel = ResourceContentController.ResourceViewModel
    
    public var loadingController: (UIViewController & ResourceLoadingView)!
    public var messageController: PlaceholderViewController!
    public var contentController: (ResourceContentController)!
    
    public var messageConvertor: ((Error) -> PlaceholderConfiguration)?
    
    var onDidLoad: (() -> Void)?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        onDidLoad?()
    }

    public func display(_ viewModel: ResourceViewModel) {
        displayContentController()
        contentController.display(viewModel)
    }
    
    public func display(_ isloading: Bool) {
        guard isloading else { return }
        displayLoadingController()
        loadingController.display(isloading)
    }
    
    public func display(_ error: Message?) {
        guard let error else { return }
        displayMessageController()
        
        guard let messageConvertor else { return }
        messageController.configure(messageConvertor(error))
    }
}

extension LoadResourceViewController {
    public func displayLoadingController() {
        if activeChildController !== loadingController {
            detachAllChildren()
            attach(loadingController)
        }
    }
    
    public func displayContentController() {
        if activeChildController !== contentController {
            detachAllChildren()
            attach(contentController)
        }
    }
    
    public func displayMessageController() {
        if activeChildController !== messageController {
            detachAllChildren()
            attach(messageController)
        }
    }
}

extension LoadResourceViewController {
    private func attach(_ viewController: UIViewController?) {
        guard let viewController else { return }
        addChild(viewController)
        attachViewIntoContainer(viewController.view, into: view)
        viewController.didMove(toParent: self)
    }
 
    private func detach(_ viewController: UIViewController?) {
        guard let viewController else { return }
        viewController.willMove(toParent: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParent()
    }
 
    private var activeChildController: UIViewController? {
        [loadingController, messageController, contentController]
        .compactMap { $0 }
        .first { $0.view.superview === view }
    }
 
    private func detachAllChildren() {
        children.forEach(detach)
    }
    
    private func attachViewIntoContainer(
        _ view: UIView,
        into container: UIView
    ) {
        view.translatesAutoresizingMaskIntoConstraints = false
        view.frame = container.bounds
        container.addSubview(view)
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: container.safeAreaLayoutGuide.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: container.safeAreaLayoutGuide.trailingAnchor),
            view.topAnchor.constraint(equalTo: container.safeAreaLayoutGuide.topAnchor),
            view.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
    }
}
