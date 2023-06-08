//
//  WidgetListDTO.swift
//  Widgets
//
//  Created by Марина Чемезова on 07.06.2023.
//

import Foundation

public struct WidgetListDTO<WidgetDTO: Decodable>: Decodable {
    public let maxAge: Int
    public let mandatoryWidgetsTimeout: Int
    public let webUrl: URL?
    public let widgets: [WidgetDTO]
    
    enum CodingKeys: CodingKey {
        case maxAge
        case mandatoryWidgetsTimeout
        case webUrl
        case widgets
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.maxAge = (try? container.decode(Int.self, forKey: .maxAge)) ?? 0
        self.mandatoryWidgetsTimeout = (try? container.decode(Int.self, forKey: .mandatoryWidgetsTimeout)) ?? 0
        self.webUrl = try? container.decode(URL.self, forKey: .webUrl)

        var widgetContainer = try container.nestedUnkeyedContainer(forKey: .widgets)

        var elements: [WidgetDTO] = []
        if let count = widgetContainer.count {
            elements.reserveCapacity(count)
        }
        // swiftlint:disable indentation_width
        while !widgetContainer.isAtEnd {
#if DEBUG
            do {
                if let element = try widgetContainer.decode(FailableDecodable<WidgetDTO>.self).base {
                    elements.append(element)
                }
            } catch {
                print(error)
            }
#else
            if let element = try? widgetContainer.decode(FailableDecodable<WidgetDTO>.self).base {
                elements.append(element)
            }
#endif
        }
        // swiftlint:enable indentation_width

        self.widgets = elements
    }
    
    private struct FailableDecodable<Base: Decodable>: Decodable {
        let base: Base?

        // swiftlint:disable indentation_width
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
#if DEBUG
            do {
                self.base = try container.decode(Base.self)
            } catch {
                self.base = nil
                print(error)
            }
#else
            self.base = try? container.decode(Base.self)
#endif
        }
        // swiftlint:enable indentation_width
    }
}
