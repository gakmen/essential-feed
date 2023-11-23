//
//  LoadResourcePresenter.swift
//  EssentialFeed
//
//  Created by  Gosha Akmen on 01.11.2023.
//

public protocol ResourceView {
    associatedtype ResourceViewModel
    
    func display(_ viewModel: ResourceViewModel)
}

public final class LoadResourcePresenter<Resource, View: ResourceView> {
    public typealias Mapper = (Resource) throws -> View.ResourceViewModel
    
    private let errorView: ResourceErrorView
    private let loadingView: ResourceLoadingView
    private let resourceView: View
    private let mapper: Mapper
    
    public static var loadingErrorMessage: String {
        NSLocalizedString (
            "GENERIC_CONNECTION_ERROR",
            tableName: "Shared",
            bundle: Bundle(for: Self.self),
            comment: "Error message displayed, when we can't load the resource from the server"
        )
    }
    
    public init(errorView: ResourceErrorView, loadingView: ResourceLoadingView, resourceView: View, mapper: @escaping Mapper) {
        self.errorView = errorView
        self.loadingView = loadingView
        self.resourceView = resourceView
        self.mapper = mapper
    }
    
    public func didStartLoading() {
        errorView.display(.noError)
        loadingView.display(ResourceLoadingViewModel(isLoading: true))
    }
    
    public func didFinishLoading(with resource: Resource) {
        do {
            resourceView.display(try mapper(resource))
            loadingView.display(ResourceLoadingViewModel(isLoading: false))
        } catch {
            didFinishLoading(with: error)
        }
    }
    
    public func didFinishLoading(with eror: Error) {
        loadingView.display(ResourceLoadingViewModel(isLoading: false))
        errorView.display(.error(Self.loadingErrorMessage))
    }
}

