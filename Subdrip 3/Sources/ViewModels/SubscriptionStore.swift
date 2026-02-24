import Foundation
import Combine

class SubscriptionStore: ObservableObject {
    @Published var subscriptions: [Subscription] = []
    
    private let userDefaultsKey = "subdrip.subscriptions"
    
    init() {
        loadSubscriptions()
    }
    
    func addSubscription(_ subscription: Subscription) {
        subscriptions.append(subscription)
        saveSubscriptions()
    }
    
    func updateSubscription(_ subscription: Subscription) {
        if let index = subscriptions.firstIndex(where: { $0.id == subscription.id }) {
            subscriptions[index] = subscription
            saveSubscriptions()
        }
    }
    
    func deleteSubscription(_ subscription: Subscription) {
        subscriptions.removeAll { $0.id == subscription.id }
        saveSubscriptions()
    }
    
    func deleteSubscription(at offsets: IndexSet) {
        subscriptions.remove(atOffsets: offsets)
        saveSubscriptions()
    }
    
    var totalMonthlySpending: Double {
        subscriptions.reduce(0) { $0 + $1.monthlyPrice }
    }
    
    var totalYearlySpending: Double {
        subscriptions.reduce(0) { $0 + $1.yearlyPrice }
    }
    
    var subscriptionsSortedByNextPayment: [Subscription] {
        subscriptions.sorted { $0.nextPaymentDate < $1.nextPaymentDate }
    }
    
    func subscriptionsForDate(_ date: Date) -> [Subscription] {
        let calendar = Calendar.current
        return subscriptions.filter { subscription in
            let nextPayment = subscription.nextPaymentDate
            return calendar.isDate(nextPayment, inSameDayAs: date)
        }
    }
    
    func spendingByCategory() -> [Subscription.Category: Double] {
        var result: [Subscription.Category: Double] = [:]
        for subscription in subscriptions {
            result[subscription.category, default: 0] += subscription.monthlyPrice
        }
        return result
    }
    
    private func saveSubscriptions() {
        if let encoded = try? JSONEncoder().encode(subscriptions) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    private func loadSubscriptions() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode([Subscription].self, from: data) {
            subscriptions = decoded
        }
    }
}
