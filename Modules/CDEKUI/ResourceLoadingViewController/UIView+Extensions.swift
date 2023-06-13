//
//  UIView+Extensions.swift
//  WidgetsTests
//
//  Created by Марина Чемезова on 12.06.2023.
//

import UIKit

extension UIView {
    /// Добавляет view в container и устанавливает констрейны со всех сторон
    public func fitIntoView(
        _ container: UIView?,
        leading: CGFloat = 0,
        trailing: CGFloat = 0,
        top: CGFloat = 0,
        bottom: CGFloat = 0
    ) {
        guard let container = container else {
            fatalError("Контейнер не определен, невозможно создать NSLayoutConstraint")
        }
        self.translatesAutoresizingMaskIntoConstraints = false
        self.frame = container.bounds
        container.addSubview(self)
        
        NSLayoutConstraint.activate([
            self.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: leading),
            self.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: trailing),
            self.topAnchor.constraint(equalTo: container.topAnchor, constant: top),
            self.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: bottom)
        ])
    }
}
