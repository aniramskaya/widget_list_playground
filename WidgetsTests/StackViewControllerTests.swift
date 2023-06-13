//
//  StackViewControllerTests.swift
//  WidgetsTests
//
//  Created by Марина Чемезова on 12.06.2023.
//

import UIKit
import XCTest
@testable import Widgets

class StackViewControllerTests: XCTestCase {
    func test_addRemoveControllers() {
        let sut = StackViewController()
        let vc1 = SpyVC()
        let vc2 = SpyVC()
        
        sut.triggerLifecycleIfNeeded()
        sut.view.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: UIScreen.main.nativeBounds.size)
        sut.display([vc1, vc2])
        
        XCTAssertEqual(vc1.messages, [.willAddToParent, .didAddToParent])
        XCTAssertEqual(vc2.messages, [.willAddToParent, .didAddToParent])
        
        XCTAssertTrue(vc1.view.superview is UIStackView)
        XCTAssertTrue(vc2.view.superview is UIStackView)
        
        sut.display([])
        
        XCTAssertEqual(vc1.messages, [.willAddToParent, .didAddToParent, .willRemoveFromParent, .didRemoveFromParent])
        XCTAssertEqual(vc2.messages, [.willAddToParent, .didAddToParent, .willRemoveFromParent, .didRemoveFromParent])
        
        XCTAssertNil(vc1.view.superview)
        XCTAssertNil(vc2.view.superview)
    }
    
    func test_adjustControllers() {
        let sut = StackViewController()
        let vc1 = SpyVC()
        let vc2 = SpyVC()
        let vc3 = SpyVC()

        sut.triggerLifecycleIfNeeded()
        sut.view.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: UIScreen.main.nativeBounds.size)
        sut.display([vc1, vc2])
        
        XCTAssertEqual(vc1.messages, [.willAddToParent, .didAddToParent])
        XCTAssertEqual(vc2.messages, [.willAddToParent, .didAddToParent])
        XCTAssertEqual(vc3.messages, [])

        XCTAssertTrue(vc1.view.superview is UIStackView)
        XCTAssertTrue(vc2.view.superview is UIStackView)
        XCTAssertNil(vc3.view.superview)

        sut.display([vc3, vc2])
        
        XCTAssertEqual(vc1.messages, [.willAddToParent, .didAddToParent, .willRemoveFromParent, .didRemoveFromParent])
        XCTAssertEqual(vc2.messages, [.willAddToParent, .didAddToParent])
        XCTAssertEqual(vc3.messages, [.willAddToParent, .didAddToParent])

        XCTAssertNil(vc1.view.superview)
        XCTAssertTrue(vc2.view.superview is UIStackView)
        XCTAssertTrue(vc3.view.superview is UIStackView)
    }
    
    func test_titleViewIsFirstViewInStack() {
        let sut = StackViewController()
        let vc1 = SpyVC()
        let vc2 = SpyVC()
        let titleView = UIView()
        sut.titleView = { titleView }
        
        sut.triggerLifecycleIfNeeded()
        sut.view.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: UIScreen.main.nativeBounds.size)
        sut.display([vc1, vc2])
        
        XCTAssertIdentical(sut.stackView.arrangedSubviews.first, titleView)
    }

}

class SpyVC: UIViewController {
    enum Message {
        case willAddToParent
        case didAddToParent
        case willRemoveFromParent
        case didRemoveFromParent
    }
    
    var messages: [Message] = []
    
    override func loadView() {
        view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 100).isActive = true
    }
    
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        messages.append(parent != nil ? .willAddToParent : .willRemoveFromParent )
    }
    
    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        messages.append(parent != nil ? .didAddToParent : .didRemoveFromParent)
    }
}

extension UIViewController {
    func triggerLifecycleIfNeeded() {
        guard !isViewLoaded else { return }
        
        loadViewIfNeeded()
        beginAppearanceTransition(true, animated: false)
        endAppearanceTransition()
    }
    
    func triggerViewWillAppear() {
        beginAppearanceTransition(true, animated: false)
        endAppearanceTransition()
    }
}
