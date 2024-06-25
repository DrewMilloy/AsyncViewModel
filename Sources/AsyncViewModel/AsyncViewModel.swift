// by Drew Milloy 2024

import SwiftUI

@MainActor
open class AsyncViewModel<Content>: ObservableObject {
    private enum InternalError: Error {
        case notImplemented
    }
    
    enum State {
        case loading
        case loaded(Content)
        case error(Error)
    }

    @Published var state: State = .loading
    
    public init() {}
    
    final func load() async {
        do {
            let content = try await performLoad()
            state = .loaded(content)
        } catch {
            state = .error(error)
        }
    }
    
    open func performLoad() async throws -> Content {
        throw InternalError.notImplemented
    }
}

public struct AsyncView<Content, ContentView: View, ErrorView: View>: View {
    @ObservedObject var viewModel: AsyncViewModel<Content>
    var contentView: (Content) -> ContentView
    var errorView: (Error) -> ErrorView
    
    public init(
        viewModel: AsyncViewModel<Content>,
        contentView: @escaping (Content) -> ContentView,
        errorView: @escaping (Error) -> ErrorView)
    {
        _viewModel = ObservedObject(wrappedValue: viewModel)
        self.contentView = contentView
        self.errorView = errorView
    }
    
    public var body: some View {
        switch viewModel.state {
        case .loading:
            ProgressView()
                .task {
                    await viewModel.load()
                }
        case .error(let error):
            errorView(error)
        case .loaded(let content):
            contentView(content)
        }
    }
}
