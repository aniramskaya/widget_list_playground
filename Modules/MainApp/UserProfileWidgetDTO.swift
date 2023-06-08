//
//  UserProfileWidgetDTO.swift
//  Widgets
//
//  Created by Марина Чемезова on 08.06.2023.
//

import Foundation

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
    var widgetLoader: UIWidgetLoader {
        switch self {
        case let .loyaltyActions(dto):
            return LoyaltyActionsWidgetLoader(isMandatory: true, url: dto.url)
        case .cdekId:
            return CdekIdWidgetLoader(isMandatory: true)
        }
    }
}
