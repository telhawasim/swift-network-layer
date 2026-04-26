//
//  ProductListView.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 26/04/2026.
//

import SwiftUI

struct ProductListView: View {
    
    // MARK: - PROPERTIES -
    
    /// Binding
    @Binding var viewModel: ProductListViewModel
    
    // MARK: - BODY -
    var body: some View {
        List {
            ForEach(viewModel.products, id: \.id) { product in
                ProductRow(product: product)
                    .onAppear {
                        if product.id == viewModel.products.last?.id {
                            Task {
                                await viewModel.loadProducts()
                            }
                        }
                    }
            }
            
            if viewModel.isLoading {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            }
        }
        .searchable(text: $viewModel.searchQuery)
        .onChange(of: viewModel.searchQuery) { _, _ in
            Task {
                await viewModel.searchProducts()
            }
        }
        .refreshable {
            await viewModel.refresh()
        }
        .navigationTitle("Producsts")
        .task {
            await viewModel.loadProducts()
        }
    }
}

#Preview {
    ProductListView(viewModel: Binding.constant(ProductListViewModel()))
}

struct ProductRow: View {
    
    // MARK: - PROPERTIES -
    
    /// Normal
    let product: Product
    
    // MARK: - BODY -
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(product.title)
                .font(.headline)
            
            Text(product.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)
            
            HStack {
                Text("$\(product.price, specifier: "%.2f")")
                    .font(.title3)
                    .fontWeight(.bold)
                
                if product.discountPercentage > 0 {
                    Text("\(product.discountPercentage, specifier: "%.0f")% off")
                        .font(.caption)
                        .foregroundStyle(.red)
                }
                
                Spacer()
                
                HStack(spacing: 2) {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                    Text("\(product.rating, specifier: "%.1f")")
                }
                .font(.caption)
            }
        }
        .padding(.vertical, 4)
    }
}
