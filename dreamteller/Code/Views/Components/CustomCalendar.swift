//
//  CustomCalendar.swift
//  dreamteller
//
//  Created by suha.isik on 31.10.2025.
//

import SwiftUI

struct CustomCalendar: View {
    @Binding var selectedDate: Date
    var dayColor: (Date) -> Color = { _ in .white }
    var selectedBackground: Color = .blue
    
    private var calendar: Calendar { Calendar.current }
    private var monthInterval: DateInterval {
        calendar.dateInterval(of: .month, for: selectedDate)!
    }
    private var days: [Date] {
        var result: [Date] = []
        var current = monthInterval.start
        while current < monthInterval.end {
            result.append(current)
            current = calendar.date(byAdding: .day, value: 1, to: current)!
        }
        return result
    }
    private var leadingEmptyDays: Int {
        let weekday = calendar.component(.weekday, from: monthInterval.start)
        // Make Monday = 1 (adjust if you want Sunday start)
        return (weekday + 6) % 7
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Month header
            HStack {
                Text(monthInterval.start, format: .dateTime.month().year())
                    .font(.headline)
                Spacer()
                Button {
                    withAnimation {
                        selectedDate = calendar.date(byAdding: .month, value: -1, to: selectedDate)!
                    }
                } label: { Image(systemName: "chevron.left") }
                Button {
                    withAnimation {
                        selectedDate = calendar.date(byAdding: .month, value: 1, to: selectedDate)!
                    }
                } label: { Image(systemName: "chevron.right") }
            }
            .foregroundColor(.white)
            
            // Weekday symbols
            let symbols = calendar.shortWeekdaySymbols // Adjust for locale
            LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 7)) {
                ForEach(symbols, id: \.self) { s in
                    Text(s.uppercased())
                        .font(.caption2.bold())
                        .foregroundColor(.gray)
                }
            }
            
            // Days grid
            LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 7), spacing: 8) {
                ForEach(0..<leadingEmptyDays, id: \.self) { _ in
                    Color.clear.frame(height: 24)
                }
                ForEach(days, id: \.self) { day in
                    let isSelected = calendar.isDate(day, inSameDayAs: selectedDate)
                    Text(String(calendar.component(.day, from: day)))
                        .font(.subheadline)
                        .frame(maxWidth: .infinity, minHeight: 32)
                        .background(
                            Circle()
                                .fill(isSelected ? selectedBackground : Color.clear)
                        )
                        .foregroundColor(isSelected ? .white : dayColor(day))
                        .onTapGesture {
                            selectedDate = day
                        }
                        .accessibilityLabel(day.formatted(date: .abbreviated, time: .omitted))
                }
            }
        }
        .padding()
        //.background(LinearGradient.onboardingBackground.ignoresSafeArea())
    }
}
#Preview {
    CustomCalendar(selectedDate: Binding<Date>.constant(Date()))
}
