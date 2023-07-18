//
//  BeerViewModel.swift
//  Bev
//
//  Created by Jacob Bartlett on 01/04/2023.
//

import Combine
import Domain
import Repository
import SwiftUI

@MainActor
final class BeerViewModel: ObservableObject {
    
    @Published private(set) var beers: [Beer] = []
    @Published var showAlert: Bool = false
    
    private(set) var errorMessage: String?
    private var cancelBag = Set<AnyCancellable>()
    
    private let repository: BeerRepository
    
    init(repository: BeerRepository = BeerRepositoryImpl()) {
        self.repository = repository
        setupBeerListener(on: repository)
    }
    
    func loadBeers() async {
        await repository.loadBeers()
    }
    
    func refreshBeers() {
        Task {
            await repository.loadBeers()
        }
    }
    
    private func setupBeerListener(on repo: BeerRepository) {
        repo.beersPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] in
                self?.handleBeer(from: $0)
            }).store(in: &cancelBag)
    }
    
    private func handleBeer(from result: Result<[Beer], Error>) {
        switch result {
        case .success(let beers):
            self.beers = beers
            
        case .failure(let error):
            errorMessage = error.localizedDescription
            showAlert.toggle()
        }
    }
}
