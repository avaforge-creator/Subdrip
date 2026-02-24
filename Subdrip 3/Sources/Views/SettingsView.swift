import SwiftUI

struct SettingsView: View {
    @AppStorage("currencyCode") private var currencyCode = "USD"
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("isDarkMode") private var isDarkMode = true
    
    let currencies = ["USD", "EUR", "GBP", "AED", "CAD", "AUD", "JPY", "INR", "CNY"]
    
    var backgroundColor: Color {
        isDarkMode ? Color.black : Color.white
    }
    
    var cardBackgroundColor: Color {
        isDarkMode ? Color(hex: "#1C1C1E") : Color(.systemGray6)
    }
    
    var textColor: Color {
        isDarkMode ? .white : .black
    }
    
    var secondaryTextColor: Color {
        isDarkMode ? .gray : .gray
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundColor.ignoresSafeArea()
                
                List {
                    // Profile Section
                    Section {
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.blue)
                            
                            VStack(alignment: .leading) {
                                Text("Subdrip User")
                                    .font(.headline)
                                    .foregroundColor(textColor)
                                
                                Text("Free Plan")
                                    .font(.caption)
                                    .foregroundColor(secondaryTextColor)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    .listRowBackground(cardBackgroundColor)
                    
                    // Preferences
                    Section("Preferences") {
                        Picker("Currency", selection: $currencyCode) {
                            ForEach(currencies, id: \.self) { currency in
                                Text(currency).tag(currency)
                            }
                        }
                        .foregroundColor(textColor)
                        
                        Toggle("Notifications", isOn: $notificationsEnabled)
                            .tint(.blue)
                            .foregroundColor(textColor)
                        
                        Toggle("Dark Mode", isOn: $isDarkMode)
                            .tint(.blue)
                            .foregroundColor(textColor)
                    }
                    .listRowBackground(cardBackgroundColor)
                    
                    // Upgrade Section
                    Section {
                        Button(action: {}) {
                            HStack {
                                Image(systemName: "crown.fill")
                                    .foregroundColor(.yellow)
                                
                                Text("Upgrade to Pro")
                                    .font(.headline)
                                    .foregroundColor(textColor)
                                
                                Spacer()
                                
                                Text("$5/mo")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .listRowBackground(cardBackgroundColor)
                    
                    // About Section
                    Section("About") {
                        HStack {
                            Text("Version")
                                .foregroundColor(textColor)
                            Spacer()
                            Text("1.0.0")
                                .foregroundColor(secondaryTextColor)
                        }
                        
                        HStack {
                            Text("Build")
                                .foregroundColor(textColor)
                            Spacer()
                            Text("1")
                                .foregroundColor(secondaryTextColor)
                        }
                    }
                    .listRowBackground(cardBackgroundColor)
                    
                    // Links
                    Section {
                        Button("Privacy Policy") {}
                        Button("Terms of Service") {}
                        Button("Contact Support") {}
                    }
                    .listRowBackground(cardBackgroundColor)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// Currency symbols mapping
extension String {
    var currencySymbol: String {
        switch self {
        case "USD": return "$"
        case "EUR": return "€"
        case "GBP": return "£"
        case "AED": return "AED "  // Changed to AED instead of Arabic
        case "CAD": return "CA$"
        case "AUD": return "A$"
        case "JPY": return "¥"
        case "INR": return "₹"
        case "CNY": return "¥"  // Chinese Yuan
        default: return "$"
        }
    }
}

#Preview {
    SettingsView()
}
