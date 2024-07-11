# AsyncViewModel

Handy way to cut out boilerplate for your async MVVM SwiftUI needs

## How to add to your project

Using [Swift Package Manager](https://swift.org/package-manager/):

in `Package.swift` add the following:

```swift
dependencies: [
    // Dependencies declare other packages that this package depends on.
    // .package(url: /* package url */, from: "1.0.0"),
    .package(url: "https://github.com/DrewMilloy/AsyncViewModel", from: "0.0.1")
],
targets: [
    .target(
        name: "MyProject",
        dependencies: [..., "AsyncViewModel"]
    )
    ...
]
```

## Usage

Your view model will be a subclass of `AsyncViewModel`.

e.g:

```swift
@MainActor
final class MyViewModel: AsyncViewModel<MyContentModel> {

    private let myService: MyService
    
    init(myService: MyService) {
        // inject dependency
        self.myService = myService
    }

    override func performLoad() async throws -> MyContentModel {
        try await myService.fetchSomeContent()
    }
}

struct MyView: View {
    @ObservedObject var viewModel: MyViewModel
    
    var body: some View {
        AsyncView(viewModel: viewModel) { contentModel in
            // display the content
        } errorView: { error in
            // display the error
        }
    }
}

``` 

