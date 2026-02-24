import SwiftUI

struct SubscriptionCard: View {
    let subscription: Subscription
    var currencyCode: String = "USD"
    var isDarkMode: Bool = true
    @State private var showingDetail = false
    
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
        Button(action: {
            showingDetail = true
        }) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: subscription.colorHex).opacity(0.2))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: subscription.iconName)
                        .font(.system(size: 20))
                        .foregroundColor(Color(hex: subscription.colorHex))
                }
                
                // Details
                VStack(alignment: .leading, spacing: 4) {
                    Text(subscription.name)
                        .font(.headline)
                        .foregroundColor(textColor)
                    
                    Text("\(subscription.daysUntilNextPayment) days • \(subscription.billingCycle.rawValue)")
                        .font(.caption)
                        .foregroundColor(secondaryTextColor)
                }
                
                Spacer()
                
                // Price (converted)
                let convertedPrice = CurrencyConverter.convert(subscription.price, from: "USD", to: currencyCode)
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(CurrencyConverter.symbol(for: currencyCode))\(String(format: "%.2f", convertedPrice))")
                        .font(.headline)
                        .foregroundColor(textColor)
                    
                    Text("/\(subscription.billingCycle.shortName)")
                        .font(.caption)
                        .foregroundColor(secondaryTextColor)
                }
            }
            .padding(16)
            .background(cardBackgroundColor)
            .cornerRadius(16)
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showingDetail) {
            SubscriptionDetailView(subscription: subscription, currencyCode: currencyCode, isDarkMode: isDarkMode)
        }
    }
}

struct SubscriptionDetailView: View {
    let subscription: Subscription
    var currencyCode: String = "USD"
    var isDarkMode: Bool = true
    @Environment(\.dismiss) var dismiss
    
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
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header with icon
                        ZStack {
                            Circle()
                                .fill(Color(hex: subscription.colorHex).opacity(0.2))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: subscription.iconName)
                                .font(.system(size: 36))
                                .foregroundColor(Color(hex: subscription.colorHex))
                        }
                        .padding(.top, 20)
                        
                        // Name
                        Text(subscription.name)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(textColor)
                        
                        // Category badge
                        HStack {
                            Image(systemName: subscription.category.iconName)
                            Text(subscription.category.rawValue)
                        }
                        .font(.subheadline)
                        .foregroundColor(Color(hex: subscription.colorHex))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color(hex: subscription.colorHex).opacity(0.2))
                        .cornerRadius(20)
                        
                        // Price details (with conversion)
                        let convertedPrice = CurrencyConverter.convert(subscription.price, from: "USD", to: currencyCode)
                        let convertedMonthly = CurrencyConverter.convert(subscription.monthlyPrice, from: "USD", to: currencyCode)
                        let convertedYearly = CurrencyConverter.convert(subscription.yearlyPrice, from: "USD", to: currencyCode)
                        
                        VStack(spacing: 16) {
                            DetailRow(label: "Price", value: "\(CurrencyConverter.symbol(for: currencyCode))\(String(format: "%.2f", convertedPrice)) / \(subscription.billingCycle.shortName)", textColor: textColor, secondaryTextColor: secondaryTextColor)
                            DetailRow(label: "Monthly", value: "\(CurrencyConverter.symbol(for: currencyCode))\(String(format: "%.2f", convertedMonthly))", textColor: textColor, secondaryTextColor: secondaryTextColor)
                            DetailRow(label: "Yearly", value: "\(CurrencyConverter.symbol(for: currencyCode))\(String(format: "%.2f", convertedYearly))", textColor: textColor, secondaryTextColor: secondaryTextColor)
                            DetailRow(label: "Next Payment", value: nextPaymentText, textColor: textColor, secondaryTextColor: secondaryTextColor)
                            DetailRow(label: "Start Date", value: formattedDate(subscription.startDate), textColor: textColor, secondaryTextColor: secondaryTextColor)
                        }
                        .padding()
                        .background(cardBackgroundColor)
                        .cornerRadius(16)
                        .padding(.horizontal)
                        
                        // Notes (if any)
                        if !subscription.notes.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Notes")
                                    .font(.headline)
                                    .foregroundColor(textColor)
                                Text(subscription.notes)
                                    .font(.body)
                                    .foregroundColor(secondaryTextColor)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(cardBackgroundColor)
                            .cornerRadius(16)
                            .padding(.horizontal)
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    var nextPaymentText: String {
        let days = subscription.daysUntilNextPayment
        if days == 0 {
            return "Today"
        } else if days == 1 {
            return "Tomorrow"
        } else {
            return "\(days) days"
        }
    }
    
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    var textColor: Color = .white
    var secondaryTextColor: Color = .gray
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(secondaryTextColor)
            Spacer()
            Text(value)
                .foregroundColor(textColor)
        }
    }
}

#Preview {
    SubscriptionCard(subscription: Subscription(
        id: UUID(),
        name: "Netflix",
        price: 15.99,
        billingCycle: .monthly,
        category: .entertainment,
        iconName: "tv.fill",
        startDate: Date(),
        colorHex: "#FF453A",
        notes: "Family plan shared with 4 members"
    ), currencyCode: "EUR", isDarkMode: true)
    .padding()
    .background(Color.black)
}
