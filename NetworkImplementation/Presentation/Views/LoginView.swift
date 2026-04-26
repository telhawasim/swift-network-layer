//
//  LoginView.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 26/04/2026.
//

import SwiftUI

struct LoginView: View {
    
    // MARK: - PROPERTIES -
    
    /// Binding
    @Binding var viewModel: LoginViewModel
    
    // MARK: - BODY -
    var body: some View {
        VStack(spacing: 20) {
            TextField("Username", text: $viewModel.username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
            
            SecureField("Password", text: $viewModel.password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundStyle(.red)
                    .font(.caption)
            }
            
            Button("Login") {
                Task {
                    await viewModel.login()
                }
            }
            .disabled(viewModel.isLoading)
            
            if viewModel.isLoading {
                ProgressView()
            }
        }
        .padding()
        .navigationTitle("Login")
    }
}

#Preview {
    LoginView(viewModel: Binding.constant(LoginViewModel()))
}
