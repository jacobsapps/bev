//
//  BeerListView.swift
//  Bev
//
//  Created by Jacob Bartlett on 01/04/2023.
//

import Domain
import SwiftUI

struct BeerListView: View {
    
    @StateObject var viewModel = BeerViewModel()
    @Namespace private var animation
    @State private var beer: Beer?
    
    var body: some View {
        NavigationStack {
            beerListView
                .overlay(loadingIndicator)
                .navigationTitle("Bev")
                .toolbar(viewModel.beers.isEmpty ? .hidden : .automatic, for: .navigationBar)
                .toolbar { ToolbarItem(placement: .navigationBarTrailing) { refreshButton } }
        }
        .alert(isPresented: $viewModel.showAlert) { errorAlert }
        .refreshable { viewModel.refreshBeers() }
        .task { await viewModel.loadBeers() }
    }
    
    private var beerListView: some View {
        ScrollView {
            ForEach(viewModel.beers) { beer in
                NavigationLink(value: beer, label: {
                    BeerListCell(beer: beer)
                })
            }
        }
        .navigationDestination(for: Beer.self, destination: {
            BeerDetailView(beer: $0)
        })
    }
    
    private var refreshButton: some View {
        Button(action: {
            viewModel.refreshBeers()
            
        }, label: {
            Image(systemName: "arrow.clockwise")
        })
    }
    
    @ViewBuilder
    private var loadingIndicator: some View {
        if viewModel.isLoading {
            ProgressView()
        }
    }
    
    private var errorAlert: Alert {
        Alert(
            title: Text("Error"),
            message: Text(viewModel.errorMessage ?? ""),
            dismissButton: .default(Text("OK")) {
                viewModel.showAlert.toggle()
            }
        )
    }
}

struct BeerGridView_Previews: PreviewProvider {
    static var previews: some View {
        BeerListView()
    }
}
