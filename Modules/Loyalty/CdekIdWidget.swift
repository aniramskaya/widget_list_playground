//
//  CdekIdWidget.swift
//  Widgets
//
//  Created by Марина Чемезова on 08.06.2023.
//

import UIKit
import Combine

class CdekIdWidget: UIViewController, Widget {
    var ui: UIViewController { self }
    
    var isDisplaying = CurrentValueSubject<Bool, Never>(false)
    
    func configure(completion: @escaping (Error?) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now().advanced(by: .milliseconds(500)), execute: DispatchWorkItem(block: {
            completion(nil)
        }))
    }
}
