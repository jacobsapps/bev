//
//  MockBeerRepository.swift
//  
//
//  Created by Jacob Bartlett on 03/04/2023.
//

import Combine
import Domain
import Foundation
import Repository
import TestUtilities

public final class MockBeerRepository: BeerRepository {
    
    public var beersPublisher = PassthroughSubject<Result<[Beer], Error>, Never>()
    
    public init() { }
    
    public var stubLoadBeersResponse: Result<[Beer], Error>?
    public var didLoadBeers: (() -> Void)?
    public var loadBeersCallCount = 0
    public func loadBeers() async {
        defer { didLoadBeers?() }
        loadBeersCallCount += 1
        beersPublisher.send(stubLoadBeersResponse!)
    }
}
