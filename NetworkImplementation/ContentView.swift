//
//  ContentView.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 24/04/2026.
//

import SwiftUI

struct ContentView: View {
    
    // MARK: - PROPERTIES -
    
    /// State
    @State private var loginViewModel = LoginViewModel()
    @State private var productViewModel = ProductListViewModel()
    
    // MARK: - BODY -
    var body: some View {
        NavigationView {
            if loginViewModel.isLoading {
                ProductListView(viewModel: $productViewModel)
            } else {
                LoginView(viewModel: $loginViewModel)
            }
        }
    }
}

#Preview {
    ContentView()
}
