import SwiftUI

struct ProductListView: View {
    @Bindable var viewModel: ProductListViewModel
    let onLogout: () async -> Void

    var body: some View {
        List {
            ForEach(viewModel.products) { product in
                ProductRow(product: product)
                    .onAppear {
                        if product.id == viewModel.products.last?.id {
                            Task { await viewModel.loadProducts() }
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

            if let error = viewModel.errorMessage {
                Text(error).foregroundStyle(.red)
            }
        }
        .searchable(text: $viewModel.searchQuery)
        .task(id: viewModel.searchQuery) { await viewModel.search() }
        .refreshable { await viewModel.refresh() }
        .navigationTitle("Products")
        .toolbar {
            Button("Logout") { Task { await onLogout() } }
        }
        .task { await viewModel.loadProducts() }
    }
}

private struct ProductRow: View {
    let product: Product

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(product.title).font(.headline)
            Text(product.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)
            HStack {
                Text(product.discountedPrice, format: .currency(code: "USD"))
                    .font(.title3.bold())
                Spacer()
                Label(product.rating.formatted(.number.precision(.fractionLength(1))), systemImage: "star.fill")
                    .font(.caption)
                    .foregroundStyle(.yellow)
            }
        }
        .padding(.vertical, 4)
    }
}
