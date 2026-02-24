import Foundation

struct Subscription: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var price: Double
    var billingCycle: BillingCycle
    var category: Category
    var iconName: String
    var startDate: Date
    var colorHex: String
    var notes: String  // New: optional notes
    
    enum BillingCycle: String, Codable, CaseIterable {
        case weekly = "Weekly"
        case monthly = "Monthly"
        case yearly = "Yearly"
        
        var shortName: String {
            switch self {
            case .weekly: return "wk"
            case .monthly: return "mo"
            case .yearly: return "yr"
            }
        }
        
        func daysInCycle() -> Int {
            switch self {
            case .weekly: return 7
            case .monthly: return 30
            case .yearly: return 365
            }
        }
    }
    
    enum Category: String, Codable, CaseIterable {
        case entertainment = "Entertainment"
        case software = "Software"
        case health = "Health"
        case utilities = "Utilities"
        case shopping = "Shopping"
        case other = "Other"
        
        var iconName: String {
            switch self {
            case .entertainment: return "tv.fill"
            case .software: return "laptopcomputer"
            case .health: return "heart.fill"
            case .utilities: return "bolt.fill"
            case .shopping: return "cart.fill"
            case .other: return "square.grid.2x2.fill"
            }
        }
        
        var colorHex: String {
            switch self {
            case .entertainment: return "#FF453A"
            case .software: return "#007AFF"
            case .health: return "#30D158"
            case .utilities: return "#FFD60A"
            case .shopping: return "#BF5AF2"
            case .other: return "#8E8E93"
            }
        }
    }
    
    var monthlyPrice: Double {
        switch billingCycle {
        case .weekly: return price * 4.33
        case .monthly: return price
        case .yearly: return price / 12
        }
    }
    
    var yearlyPrice: Double {
        switch billingCycle {
        case .weekly: return price * 52
        case .monthly: return price * 12
        case .yearly: return price
        }
    }
    
    var nextPaymentDate: Date {
        let calendar = Calendar.current
        var nextDate = startDate
        let now = Date()
        
        while nextDate < now {
            switch billingCycle {
            case .weekly:
                nextDate = calendar.date(byAdding: .day, value: 7, to: nextDate) ?? nextDate
            case .monthly:
                nextDate = calendar.date(byAdding: .month, value: 1, to: nextDate) ?? nextDate
            case .yearly:
                nextDate = calendar.date(byAdding: .year, value: 1, to: nextDate) ?? nextDate
            }
        }
        
        return nextDate
    }
    
    var daysUntilNextPayment: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: nextPaymentDate)
        return components.day ?? 0
    }
}
