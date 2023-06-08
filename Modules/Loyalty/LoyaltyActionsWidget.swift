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

class LoyaltyActionsWidget: UIViewController, UIWidget {
    var ui: UIViewController { self }
    
    var isDisplaying = CurrentValueSubject<Bool, Never>(false)
    
    func configure(with model: URL, completion: @escaping (Error?) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now().advanced(by: .milliseconds(500)), execute: DispatchWorkItem(block: {
            completion(nil)
        }))
    }
}

class LoyaltyActionsWidgetLoader: UIWidgetLoader {
    let isMandatory: Bool
    let url: URL
    
    init(isMandatory: Bool, url: URL) {
        self.url = url
        self.isMandatory = isMandatory
    }
    
    func load(_ completion: @escaping (Result<any UIWidget, Error>) -> Void) {
        let widget = LoyaltyActionsWidget()
        widget.configure(with: url) { error in
            if let error {
                completion(.failure(error))
            } else {
                completion(.success(widget))
            }
        }
    }
}
