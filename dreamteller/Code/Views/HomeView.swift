//
//  HomeView.swift
//  dreamteller
//
//  Created by suha.isik on 31.10.2025.
//

import SwiftUI

struct HomeView: View {
    @State private var selectedDate = Date()
    
    // Mock data corrected: use `dream:` instead of `description:` and add interpretations
    private var dreams: [Dream] = [
        Dream(dateKey: "20251118", input: "I was walking through a misty forest hearing distant whispers.", interpretation: "Seeking guidance / introspection", title: "Walking in the woods", imageName: "dream1"),
        Dream(dateKey: "20251118", input: "I soared above skyscrapers feeling completely free.", interpretation: "Freedom and escape from pressure", title: "Flying over the city", imageName: "dream2"),
        Dream(dateKey: "20251118", input: "Endless shelves of books, but all pages were blank.", interpretation: "Hunger for knowledge or blocked expression", title: "In the library", imageName: "dream2"),
        Dream(dateKey: "20251118", input: "Fragments of symbols I couldn't decode.", interpretation: nil, title: "Interpreting...", imageName: "nodream")
    ]
    
    // Date key formatter (reuse to avoid recreation)
    private static let dateKeyFormatter: DateFormatter = {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .gregorian)
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyyMMdd"
        return f
    }()
    
    // Filter dreams for selected day (String dateKey vs selectedDate)
    private var filteredDreams: [Dream] {
        let selectedKey = Self.dateKeyFormatter.string(from: selectedDate)
        return dreams.filter { $0.dateKey == selectedKey }
    }
    
    var body: some View {
        // Removed NavigationView wrapper; assume parent provides NavigationStack.
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Dream Journal")
                    .font(.title.bold())
                    .padding(.horizontal)
                
                CustomCalendar(
                    selectedDate: $selectedDate,
                    dayColor: { date in
                        let cal = Calendar.current
                        if cal.isDateInToday(date) { return .yellow }
                        let weekday = cal.component(.weekday, from: date)
                        return (weekday == 1 || weekday == 7) ? .orange : .white
                    },
                    selectedBackground: .purple
                )
                .padding(.horizontal)
                
                Text("Dreams")
                    .font(.title2.bold())
                    .padding(.horizontal)
                
                if filteredDreams.isEmpty {
                    Text("No dreams for this day. Tap another date or add a new entry.")
                        .font(.callout)
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.horizontal)
                } else {
                    VStack(spacing: 12) {
                        ForEach(filteredDreams) { dream in
                            NavigationLink(destination: DreamDetailView(dream: dream)) {
                                DreamCard(dream: dream)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .background(LinearGradient.onboardingBackground.ignoresSafeArea())
        .foregroundColor(.white)
        // Modern way to hide navigation bar for this root view only.
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    NavigationStack { // Provide stack in preview to test links
        HomeView()
    }
}
