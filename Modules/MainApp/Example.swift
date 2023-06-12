//
//  Example.swift
//  Widgets
//
//  Created by Марина Чемезова on 07.06.2023.
//

import UIKit

/*
        Требования:
 
 1. Виджет - программный компонент, у которого есть визаульное представление (View) и который может:
  - конфигурироваться входными данными
  - асинхронно, в течение некоторого времени, подготавливаться перед началом работы
  - произвольно изменять свое состояние (отображается/не отображается)
 
 2. Экран списка виджетов - ViewController или View (в SUI), который выводит вертикальный список виджетов в scrollView и реагирует на изменения отображаемости каждого виджета
 
 3. Механизм загрузки (подготовки) виджетов - програмный компонент, который получет на вход список виджетов и данных для их конфигурирования, а также флаг обязательности для каждого виджета. Выполняет асинхронное конфигурирование виджета, дожидаясь момента загрузки всех обязательных виджетов
 */

protocol UserProfileWidgetsDTOLoader {
    func load(_ completion: @escaping (Result<WidgetListDTO<UserProfileWidgetDTO>, Error>) -> Void)
}


typealias StackViewResourceController = LoadResourceViewController<StackViewController, Swift.Error>

extension LoadResourcePresenter: WidgetListPresenter where Resource == [UIViewController], View == StackViewResourceController, MessageView == StackViewResourceController {}

enum UserProfileBuilder {
    static func build(dtoLoader: UserProfileWidgetsDTOLoader){
        let viewController = LoadResourceViewController<StackViewController, Swift.Error>()
        viewController.loadingController = LoadingViewController()
        viewController.messageController = PlaceholderViewController()
        viewController.contentController = StackViewController()
        
        let presenter = LoadResourcePresenter(
            resourceView: viewController,
            loadingView: viewController,
            messageView: viewController
        ) { (widgets: [UIViewController]) in
            widgets
        }
        
        let widgetListLoader = UserProfileWidgetListLoaderAdapter(dtoLoader: dtoLoader)
        
        let widgetListController = WidgetListController(
            loader: widgetListLoader,
            presenter: presenter
        )
        
        viewController.onDidLoad = widgetListController.load
    }
}
