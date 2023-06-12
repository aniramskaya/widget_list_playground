//
//  UserProfileWidgetDTO.swift
//  Widgets
//
//  Created by Марина Чемезова on 08.06.2023.
//

import UIKit

enum UserProfileWidgetDTO: Decodable {
    private enum WidgetType: Decodable {
        case loyaltyActions
        case cdekId
    }
    
    enum CodingKeys: CodingKey {
        case type
    }
    
    case loyaltyActions(LoyaltyActionsDTO)
    case cdekId
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(WidgetType.self, forKey: .type)
        switch type {
        case .loyaltyActions:
            self = .loyaltyActions(try LoyaltyActionsDTO(from: decoder))
        case .cdekId:
            self = .cdekId
        }
    }
}

extension UserProfileWidgetDTO {
    var widgetLoader: AnyPriorityLoadingItem<AnyWidget<UIViewController>, Error> {
        switch self {
        case let .loyaltyActions(dto):
            return LoyaltyActionsWidgetLoader(url: dto.url).eraseToAnyPriorityLoadingItem()
        case .cdekId:
            return CdekIdWidgetLoader().eraseToAnyPriorityLoadingItem()
        }
    }
}
