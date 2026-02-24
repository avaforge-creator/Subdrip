import SwiftUI

struct CalendarView: View {
    @EnvironmentObject var store: SubscriptionStore
    @State private var selectedDate = Date()
    @State private var currentMonth = Date()
    @AppStorage("currencyCode") private var currencyCode = "USD"
    @AppStorage("isDarkMode") private var isDarkMode = true
    
    let calendar = Calendar.current
    
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
                
                VStack(spacing: 24) {
                    // Month Navigation
                    HStack {
                        Button(action: previousMonth) {
                            Image(systemName: "chevron.left")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                        
                        Spacer()
                        
                        Text(monthYearString)
                            .font(.headline)
                            .foregroundColor(textColor)
                        
                        Spacer()
                        
                        Button(action: nextMonth) {
                            Image(systemName: "chevron.right")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Calendar Grid
                    VStack(spacing: 8) {
                        // Weekday headers
                        HStack(spacing: 0) {
                            ForEach(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], id: \.self) { day in
                                Text(day)
                                    .font(.caption)
                                    .foregroundColor(secondaryTextColor)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        
                        // Calendar days
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                            ForEach(daysInMonth(), id: \.self) { date in
                                if let date = date {
                                    CalendarDayCell(
                                        date: date,
                                        isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                                        hasPayment: !store.subscriptionsForDate(date).isEmpty,
                                        isToday: calendar.isDateInToday(date),
                                        isDarkMode: isDarkMode
                                    )
                                    .onTapGesture {
                                        selectedDate = date
                                    }
                                } else {
                                    Color.clear
                                        .frame(height: 40)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Selected day payments
                    VStack(alignment: .leading, spacing: 12) {
                        Text(formattedSelectedDate)
                            .font(.headline)
                            .foregroundColor(textColor)
                            .padding(.horizontal)
                        
                        if store.subscriptionsForDate(selectedDate).isEmpty {
                            Text("No payments on this day")
                                .font(.subheadline)
                                .foregroundColor(secondaryTextColor)
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else {
                            ForEach(store.subscriptionsForDate(selectedDate)) { subscription in
                                SubscriptionCard(subscription: subscription, currencyCode: currencyCode, isDarkMode: isDarkMode)
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.top)
            }
            .navigationTitle("Calendar")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentMonth)
    }
    
    var formattedSelectedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: selectedDate)
    }
    
    func daysInMonth() -> [Date?] {
        let interval = calendar.dateInterval(of: .month, for: currentMonth)!
        let firstDay = interval.start
        let lastDay = calendar.date(byAdding: .day, value: -1, to: interval.end)!
        
        let firstWeekday = calendar.component(.weekday, from: firstDay)
        let daysInMonth = calendar.component(.day, from: lastDay)
        
        var days: [Date?] = []
        
        // Add empty cells for days before the first day of the month
        for _ in 1..<firstWeekday {
            days.append(nil)
        }
        
        // Add days of the month
        for day in 1...daysInMonth {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDay) {
                days.append(date)
            }
        }
        
        return days
    }
    
    func previousMonth() {
        currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
    }
    
    func nextMonth() {
        currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
    }
}

struct CalendarDayCell: View {
    let date: Date
    let isSelected: Bool
    let hasPayment: Bool
    let isToday: Bool
    var isDarkMode: Bool = true
    
    var textColor: Color {
        if isSelected {
            return .white
        } else if isToday {
            return .blue
        } else {
            return isDarkMode ? .white : .black
        }
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(Calendar.current.component(.day, from: date))")
                .font(.system(size: 16, weight: isSelected ? .bold : .regular))
                .foregroundColor(textColor)
            
            Circle()
                .fill(hasPayment ? Color.green : Color.clear)
                .frame(width: 6, height: 6)
        }
        .frame(height: 40)
        .frame(maxWidth: .infinity)
        .background(isSelected ? Color.blue.opacity(0.3) : Color.clear)
        .cornerRadius(8)
    }
}

#Preview {
    CalendarView()
        .environmentObject(SubscriptionStore())
}
