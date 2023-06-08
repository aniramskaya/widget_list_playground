//
//  Example.swift
//  Widgets
//
//  Created by Марина Чемезова on 07.06.2023.
//

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

enum UserProfileBuilder {
    static func build(dtoLoader: UserProfileWidgetsDTOLoader){
        let widgetListController = WidgetListViewController()
        
        let viewController = LoadResourceViewController<WidgetListViewController, Swift.Error>()
        viewController.loadingController = LoadingViewController()
        viewController.messageController = PlaceholderViewController()
        viewController.contentController = widgetListController
        
        let presenter = LoadResourcePresenter(
            resourceView: viewController,
            loadingView: viewController,
            messageView: viewController
        ) { (widgets: [any UIWidget]) in
            widgets
        }
        
        let widgetListLoader = WidgetListLoader()
        
        viewController.onDidLoad = {
            presenter.didStartLoading()
            dtoLoader.load { result in
                switch result {
                case let .success(dto):
                    let widgetLoaders = dto.widgets.map { $0.widgetLoader }
                    widgetListLoader.load(items: widgetLoaders, timeout: 1.0) { result in
                        switch result {
                        case let .success(widgets):
                            presenter.didFinishLoading(with: widgets)
                        case let .failure(error):
                            presenter.didFinishLoading(with: error)
                        }
                    }
                case let .failure(error):
                    presenter.didFinishLoading(with: error)
                }
            }
        }
    }
}
