import SwiftUI

struct AnalyticsView: View {
    @EnvironmentObject var store: SubscriptionStore
    @AppStorage("currencyCode") private var currencyCode = "USD"
    @AppStorage("isDarkMode") private var isDarkMode = true
    
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
                        // Donut Chart with total in middle
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Spending by Category")
                                .font(.headline)
                                .foregroundColor(textColor)
                            
                            if store.spendingByCategory().isEmpty {
                                Text("No data yet")
                                    .foregroundColor(secondaryTextColor)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(.vertical, 40)
                            } else {
                                ZStack {
                                    // Donut Chart
                                    DonutChart(data: categoryData)
                                        .frame(height: 220)
                                    
                                    // Total in middle (hollow)
                                    VStack(spacing: 4) {
                                        Text("Total")
                                            .font(.caption)
                                            .foregroundColor(secondaryTextColor)
                                        Text("\(getCurrencySymbol(currencyCode))\(String(format: "%.0f", convertCurrency(store.totalMonthlySpending, from: "USD", to: currencyCode)))")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundColor(textColor)
                                        Text("/month")
                                            .font(.caption)
                                            .foregroundColor(secondaryTextColor)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 20)
                            }
                        }
                        .padding()
                        .background(cardBackgroundColor)
                        .cornerRadius(16)
                        .padding(.horizontal)
                        
                        // Category breakdown list
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Category Breakdown")
                                .font(.headline)
                                .foregroundColor(textColor)
                            
                            if store.spendingByCategory().isEmpty {
                                Text("No data yet")
                                    .foregroundColor(secondaryTextColor)
                            } else {
                                ForEach(sortedCategories, id: \.0) { category, amount in
                                    let convertedAmount = convertCurrency(amount, from: "USD", to: currencyCode)
                                    HStack {
                                        Image(systemName: category.iconName)
                                            .foregroundColor(Color(hex: category.colorHex))
                                            .frame(width: 24)
                                        
                                        Text(category.rawValue)
                                            .foregroundColor(textColor)
                                        
                                        Spacer()
                                        
                                        Text("\(getCurrencySymbol(currencyCode))\(String(format: "%.2f", convertedAmount))")
                                            .foregroundColor(textColor)
                                        
                                        Text("/mo")
                                            .font(.caption)
                                            .foregroundColor(secondaryTextColor)
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(cardBackgroundColor)
                        .cornerRadius(16)
                        .padding(.horizontal)
                        
                        // Top Subscription
                        if let topSubscription = store.subscriptions.max(by: { $0.monthlyPrice < $1.monthlyPrice }) {
                            let convertedPrice = convertCurrency(topSubscription.monthlyPrice, from: "USD", to: currencyCode)
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Most Expensive")
                                    .font(.headline)
                                    .foregroundColor(textColor)
                                
                                HStack {
                                    Image(systemName: topSubscription.iconName)
                                        .font(.title)
                                        .foregroundColor(Color(hex: topSubscription.colorHex))
                                        .frame(width: 48, height: 48)
                                        .background(Color(hex: topSubscription.colorHex).opacity(0.2))
                                        .cornerRadius(12)
                                    
                                    VStack(alignment: .leading) {
                                        Text(topSubscription.name)
                                            .font(.headline)
                                            .foregroundColor(textColor)
                                        
                                        Text(topSubscription.category.rawValue)
                                            .font(.caption)
                                            .foregroundColor(secondaryTextColor)
                                    }
                                    
                                    Spacer()
                                    
                                    Text("\(getCurrencySymbol(currencyCode))\(String(format: "%.2f", convertedPrice))")
                                        .font(.headline)
                                        .foregroundColor(.red)
                                }
                            }
                            .padding()
                            .background(cardBackgroundColor)
                            .cornerRadius(16)
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Analytics")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    var categoryData: [(String, Double, Color)] {
        store.spendingByCategory().map { category, amount in
            (category.rawValue, amount, Color(hex: category.colorHex))
        }
    }
    
    var sortedCategories: [(Subscription.Category, Double)] {
        store.spendingByCategory().sorted { $0.value > $1.value }
    }
    
    // Currency conversion rates (relative to USD)
    func convertCurrency(_ amount: Double, from: String, to: String) -> Double {
        let rates: [String: Double] = [
            "USD": 1.0,
            "EUR": 0.92,
            "GBP": 0.79,
            "AED": 3.67,
            "CAD": 1.36,
            "AUD": 1.53,
            "JPY": 149.50,
            "INR": 83.12,
            "CNY": 7.24
        ]
        
        guard let fromRate = rates[from], let toRate = rates[to] else {
            return amount
        }
        
        // Convert to USD first, then to target currency
        let amountInUSD = amount / fromRate
        return amountInUSD * toRate
    }
    
    func getCurrencySymbol(_ code: String) -> String {
        switch code {
        case "USD": return "$"
        case "EUR": return "€"
        case "GBP": return "£"
        case "AED": return "AED "
        case "CAD": return "CA$"
        case "AUD": return "A$"
        case "JPY": return "¥"
        case "INR": return "₹"
        case "CNY": return "¥"
        default: return "$"
        }
    }
}

struct DonutChart: View {
    let data: [(String, Double, Color)]
    
    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            let outerRadius = size / 2
            let innerRadius = outerRadius * 0.6  // Hollow middle
            
            ZStack {
                ForEach(0..<data.count, id: \.self) { index in
                    DonutSlice(
                        startAngle: startAngle(for: index),
                        endAngle: endAngle(for: index),
                        innerRadius: innerRadius,
                        outerRadius: outerRadius
                    )
                    .fill(data[index].2)
                }
            }
        }
    }
    
    func startAngle(for index: Int) -> Angle {
        let total = data.reduce(0) { $0 + $1.1 }
        var angle: Double = -90
        for i in 0..<index {
            angle += (data[i].1 / total) * 360
        }
        return Angle(degrees: angle)
    }
    
    func endAngle(for index: Int) -> Angle {
        let total = data.reduce(0) { $0 + $1.1 }
        var angle: Double = -90
        for i in 0...index {
            angle += (data[i].1 / total) * 360
        }
        return Angle(degrees: angle)
    }
}

struct DonutSlice: Shape {
    var startAngle: Angle
    var endAngle: Angle
    var innerRadius: CGFloat
    var outerRadius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        
        // Outer arc
        path.addArc(center: center, radius: outerRadius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        
        // Line to inner circle
        let endPoint = CGPoint(
            x: center.x + innerRadius * cos(CGFloat(endAngle.radians)),
            y: center.y + innerRadius * sin(CGFloat(endAngle.radians))
        )
        path.addLine(to: endPoint)
        
        // Inner arc (reverse direction)
        path.addArc(center: center, radius: innerRadius, startAngle: endAngle, endAngle: startAngle, clockwise: true)
        
        path.closeSubpath()
        return path
    }
}

#Preview {
    AnalyticsView()
        .environmentObject(SubscriptionStore())
}
