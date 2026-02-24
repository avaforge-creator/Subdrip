import SwiftUI

struct HomeView: View {
    @EnvironmentObject var store: SubscriptionStore
    @State private var showingAddSheet = false
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
                        // Summary Header
                        VStack(spacing: 8) {
                            Text("Monthly Spend")
                                .font(.subheadline)
                                .foregroundColor(secondaryTextColor)
                            
                            let monthlyConverted = CurrencyConverter.convert(store.totalMonthlySpending, from: "USD", to: currencyCode)
                            Text("\(CurrencyConverter.symbol(for: currencyCode))\(String(format: "%.2f", monthlyConverted))")
                                .font(.system(size: 44, weight: .bold))
                                .foregroundColor(textColor)
                            
                            let yearlyConverted = CurrencyConverter.convert(store.totalYearlySpending, from: "USD", to: currencyCode)
                            Text("Yearly: \(CurrencyConverter.symbol(for: currencyCode))\(String(format: "%.2f", yearlyConverted))")
                                .font(.subheadline)
                                .foregroundColor(secondaryTextColor)
                        }
                        .padding(.top, 20)
                        
                        // Subscriptions List
                        if store.subscriptions.isEmpty {
                            EmptyStateView()
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(store.subscriptionsSortedByNextPayment) { subscription in
                                    SubscriptionCard(subscription: subscription, currencyCode: currencyCode, isDarkMode: isDarkMode)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.bottom, 100)
                }
                
                // Floating Add Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            showingAddSheet = true
                        }) {
                            Image(systemName: "plus")
                                .font(.title2.weight(.semibold))
                                .foregroundColor(.white)
                                .frame(width: 56, height: 56)
                                .background(Color.blue)
                                .clipShape(Circle())
                                .shadow(color: .blue.opacity(0.4), radius: 8, x: 0, y: 4)
                        }
                        .padding(.trailing, 24)
                        .padding(.bottom, 24)
                    }
                }
            }
            .navigationTitle("Subdrip")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingAddSheet) {
                AddSubscriptionView()
            }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(SubscriptionStore())
}
