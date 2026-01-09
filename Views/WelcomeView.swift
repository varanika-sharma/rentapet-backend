import SwiftUI

struct WelcomeView: View {
    @Binding var hasStarted: Bool

    var body: some View {
        VStack(spacing: 24) {
            Text("Loving Care for Your Pets")
                .font(.title)
                .fontWeight(.bold)

            Button {
                hasStarted = true
            } label: {
                Text("Book a Pet Sitter")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppTheme.primary)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
        }
        .padding()
    }
}

