import Foundation

// Currency conversion utilities
struct CurrencyConverter {
    // Exchange rates relative to USD
    static let rates: [String: Double] = [
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
    
    static func convert(_ amount: Double, from: String, to: String) -> Double {
        guard let fromRate = rates[from], let toRate = rates[to] else {
            return amount
        }
        
        // Convert to USD first, then to target currency
        let amountInUSD = amount / fromRate
        return amountInUSD * toRate
    }
    
    static func symbol(for code: String) -> String {
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
