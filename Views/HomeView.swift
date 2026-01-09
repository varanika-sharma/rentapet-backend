import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var authStore: AuthStore
    @StateObject private var viewModel = PetListViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if viewModel.isLoading {
                    ProgressView()
                        .padding(.top, 32)
                } else if let error = viewModel.errorText {
                    Text(error)
                        .foregroundColor(.red)
                        .padding(.top, 32)
                } else if viewModel.pets.isEmpty {
                    Text("No pets yet.")
                        .foregroundColor(.secondary)
                        .padding(.top, 32)
                } else {
                    ForEach(viewModel.pets) { pet in
                        NavigationLink {
                            PetDetailView(pet: pet)
                        } label: {
                            PetCardView(pet: pet)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Available Pets")
        .task {
            await viewModel.loadPets(accessToken: authStore.accessToken)
        }
        .refreshable {
            await viewModel.loadPets(accessToken: authStore.accessToken)
        }
    }
}
