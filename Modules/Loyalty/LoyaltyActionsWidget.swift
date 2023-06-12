//
//  LoyaltyActionsWidget.swift
//  Widgets
//
//  Created by Марина Чемезова on 08.06.2023.
//

import UIKit
import Combine

struct LoyaltyActionsDTO: Decodable {
    let url: URL
}

class LoyaltyActionsWidget: UIViewController, Widget {
    var ui: UIViewController { self }
    
    var isDisplaying = CurrentValueSubject<Bool, Never>(false)
    
    func configure(with model: URL, completion: @escaping (Error?) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now().advanced(by: .milliseconds(500)), execute: DispatchWorkItem(block: {
            completion(nil)
        }))
    }
}
