//
//  BeerViewModelTests.swift
//  BevTests
//
//  Created by Jacob Bartlett on 02/04/2023.
//

import Combine
import Domain
import RepositoryMocks
import XCTest
@testable import Bev

@MainActor
final class BeerViewModelTests: XCTestCase {
    
    var sut: BeerViewModel!
    var mockBeerRepository: MockBeerRepository!
    var cancel: AnyCancellable?
    
    private enum TestViewModelError: LocalizedError {
        case testError
        
        var errorDescription: String {
            switch self {
            case .testError: return "Test error"
            }
        }
    }
    
    override func setUp() {
        super.setUp()
        mockBeerRepository = MockBeerRepository()
        sut = BeerViewModel(repository: mockBeerRepository)
    }
    
    override func tearDown() {
        sut = nil
        mockBeerRepository = nil
        super.tearDown()
    }
    
    func test_initialState() {
        XCTAssertTrue(sut.beers.isEmpty)
        XCTAssertFalse(sut.showAlert)
        XCTAssertNil(sut.errorMessage)
    }
    
    func test_loadBeers_callsLoadOnRepository() async {
        mockBeerRepository.stubLoadBeersResponse = .success([])
        await sut.loadBeers()
        XCTAssertEqual(mockBeerRepository.loadBeersCallCount, 1)
    }
    
    func test_refreshBeers_tellsRepositoryToLoad() {
        mockBeerRepository.stubLoadBeersResponse = .success([])
        let exp = expectation(description: #function)
        mockBeerRepository.didLoadBeers = { exp.fulfill() }
        sut.refreshBeers()
        waitForExpectations(timeout: 1)
        XCTAssertEqual(mockBeerRepository.loadBeersCallCount, 1)
    }
    
    func test_listenerSentBeersSuccessfully_setsBeers() {
        let sampleBeers = [Beer.sample()]
        mockBeerRepository.beersPublisher.send(.success(sampleBeers))
        let exp = expectation(description: #function)
        cancel = sut.$beers.sink {
            guard !$0.isEmpty else { return }
            exp.fulfill()
        }
        waitForExpectations(timeout: 1)
        XCTAssertEqual(sampleBeers, sut.beers)
    }
    
    func test_listenerSentError_setsErrorMessageAndTogglesAlert() {
        let testError = TestViewModelError.testError
        mockBeerRepository.beersPublisher.send(.failure(testError))
        let exp = expectation(description: #function)
        cancel = sut.$showAlert.sink {
            guard $0 else { return }
            exp.fulfill()
        }
        waitForExpectations(timeout: 1)
        XCTAssertEqual(sut.errorMessage, testError.localizedDescription)
        XCTAssertTrue(sut.showAlert)
    }
}
