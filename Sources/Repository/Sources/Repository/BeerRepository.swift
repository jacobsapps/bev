//
//  BeerRepository.swift
//  Repository
//
//  Created by Jacob Bartlett on 01/04/2023.
//

import Combine
import Domain
import Foundation
import Networking

public protocol BeerRepository {
    var beersPublisher: PassthroughSubject<Result<[Beer], Error>, Never> { get }
    func loadBeers() async
}

public final class BeerRepositoryImpl: BeerRepository {
    
    public private(set) var beersPublisher = PassthroughSubject<Result<[Beer], Error>, Never>()
    
    private let api: BeerAPI
    
    public init(api: BeerAPI = BeerAPIImpl()) {
        self.api = api
    }
    
    public func loadBeers() async {
        do {
            let beers = try await api.getBeers()
            beersPublisher.send(.success(beers))

        } catch {
            beersPublisher.send(.failure(error))
        }
    }
}
