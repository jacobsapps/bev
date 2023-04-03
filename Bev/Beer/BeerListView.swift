//
//  BeerListView.swift
//  Bev
//
//  Created by Jacob Bartlett on 01/04/2023.
//

import SwiftUI

public struct BeerListView: View {
    
    @StateObject var viewModel = BeerViewModel()
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            beersView
                .overlay(loadingIndicator)
                .navigationTitle("Bev")
                .toolbar(viewModel.beers.isEmpty ? .hidden : .automatic, for: .navigationBar)
                .toolbar { ToolbarItem(placement: .navigationBarTrailing) { refreshButton } }
                .alert(isPresented: $viewModel.showAlert) { errorAlert }
                .task { await viewModel.loadBeers() }
        }
    }
    
    private var beersView: some View {
        ScrollView {
            VStack {
                ForEach(viewModel.beers) { beer in
                    BeerView(beer: beer)
                }
            }
        }
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
        if viewModel.beers.isEmpty {
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
