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
    @Published private(set) var isLoading: Bool = false
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
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] in
                self?.handleBeer(loadingState: $0)
            }).store(in: &cancelBag)
    }
    
    private func handleBeer(loadingState: LoadingState<[Beer]>) {
        switch loadingState {
        case .idle:
            isLoading = false
            return
            
        case .loading:
            isLoading = true
            
        case .success(let beers):
            isLoading = false
            self.beers = beers
            
        case .failure(let error):
            isLoading = false
            showAlert.toggle()
            errorMessage = error.localizedDescription
        }
    }
}
