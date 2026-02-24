import SwiftUI

struct AddSubscriptionView: View {
    @EnvironmentObject var store: SubscriptionStore
    @Environment(\.dismiss) var dismiss
    @AppStorage("currencyCode") private var currencyCode = "USD"
    
    @State private var name = ""
    @State private var price = ""
    @State private var billingCycle: Subscription.BillingCycle = .monthly
    @State private var category: Subscription.Category = .entertainment
    @State private var startDate = Date()
    @State private var notes = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Subscription Details") {
                    TextField("Name (e.g. Netflix)", text: $name)
                    HStack {
                        TextField("Price", text: $price)
                            .keyboardType(.decimalPad)
                        Text(CurrencyConverter.symbol(for: currencyCode))
                            .foregroundColor(.gray)
                    }
                }
                
                Section("Billing") {
                    Picker("Billing Cycle", selection: $billingCycle) {
                        ForEach(Subscription.BillingCycle.allCases, id: \.self) { cycle in
                            Text(cycle.rawValue).tag(cycle)
                        }
                    }
                    
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                }
                
                Section("Category") {
                    Picker("Category", selection: $category) {
                        ForEach(Subscription.Category.allCases, id: \.self) { cat in
                            Label(cat.rawValue, systemImage: cat.iconName)
                                .tag(cat)
                        }
                    }
                }
                
                Section("Notes (Optional)") {
                    TextEditor(text: $notes)
                        .frame(height: 80)
                }
            }
            .navigationTitle("Add Subscription")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveSubscription()
                    }
                    .disabled(name.isEmpty || price.isEmpty)
                }
            }
        }
    }
    
    func saveSubscription() {
        guard let priceValue = Double(price) else { return }
        
        let subscription = Subscription(
            id: UUID(),
            name: name,
            price: priceValue,  // Store in USD (base currency)
            billingCycle: billingCycle,
            category: category,
            iconName: category.iconName,
            startDate: startDate,
            colorHex: category.colorHex,
            notes: notes
        )
        
        store.addSubscription(subscription)
        dismiss()
    }
}

#Preview {
    AddSubscriptionView()
        .environmentObject(SubscriptionStore())
}
