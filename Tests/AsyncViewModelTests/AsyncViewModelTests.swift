import XCTest
@testable import AsyncViewModel

class MockAsyncViewModel: AsyncViewModel<String> {
    
    enum Error: Swift.Error, Equatable {
        case testFailure
    }
    
    let result: Result<String, Error>
    
    init(result: Result<String, Error>) {
        self.result = result
    }
    
    override func performLoad() async throws -> String {
        switch result {
        case .success(let success):
            return success
        case .failure(let failure):
            throw failure
        }
    }
}

final class AsyncViewModelTests: XCTestCase {

    @MainActor
    func testInitialState() async throws {
        let sut = AsyncViewModel<String>()

        switch sut.state {
        case .loading:
            // Pass
            break
        default:
            XCTFail("Initial state should be .loading")
        }
    }
    
    @MainActor
    func testCallingBaseClassThrowsNotImplementedError() async throws {
        let sut = AsyncViewModel<String>()
        
        await sut.load()

        switch sut.state {
        case .error(_):
            // Pass
            break
        default:
            XCTFail("State should be .error(.notImplemented)")
        }
    }
    
    @MainActor
    func testHappyPath() async throws {
        let successString = "HELLO WORLD"
        let sut = MockAsyncViewModel(result: .success(successString))
        
        await sut.load()
        
        switch sut.state {
        case .loaded(let result):
            XCTAssertEqual(result, successString)
        default:
            XCTFail("State should be .loaded(\(successString))")
        }
    }
    
    @MainActor
    func testFailurePath() async throws {
        let sut = MockAsyncViewModel(result: .failure(MockAsyncViewModel.Error.testFailure))
        
        await sut.load()
        
        switch sut.state {
        case .error(let error):
            XCTAssertEqual(error as? MockAsyncViewModel.Error, MockAsyncViewModel.Error.testFailure)
            // Pass
            break
        default:
            XCTFail("State should be .error(.testFailure)")
        }
    }
}
