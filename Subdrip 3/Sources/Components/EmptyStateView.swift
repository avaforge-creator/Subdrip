import SwiftUI

struct EmptyStateView: View {
    @AppStorage("isDarkMode") private var isDarkMode = true
    
    var textColor: Color {
        isDarkMode ? .white : .black
    }
    
    var secondaryTextColor: Color {
        isDarkMode ? .gray : .gray
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "creditcard.fill")
                .font(.system(size: 48))
                .foregroundColor(secondaryTextColor)
            
            Text("No Subscriptions Yet")
                .font(.headline)
                .foregroundColor(textColor)
            
            Text("Tap the + button to add your first subscription")
                .font(.subheadline)
                .foregroundColor(secondaryTextColor)
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }
}

#Preview {
    EmptyStateView()
        .background(Color.black)
}
