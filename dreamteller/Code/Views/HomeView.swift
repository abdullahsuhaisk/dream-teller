//
//  HomeView.swift
//  dreamteller
//
//  Created by suha.isik on 31.10.2025.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var dreamVM: DreamViewModel
    
    init() {
        Logger.log("HomeView initialized", level: .info)
    }
        
    // Formatter reused for comparing dateKey
    private static let keyFormatter: DateFormatter = {
        let f = DateFormatter()
        f.calendar = .init(identifier: .gregorian)
        f.locale = .init(identifier: "en_US_POSIX")
        f.dateFormat = "yyyyMMdd"
        return f
    }()

    private var filteredDreams: [Dream] {
        let key = Self.keyFormatter.string(from: dreamVM.selectedDate)
        return dreamVM.dreams.filter { $0.dateKey == key }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Dream Journal")
                    .font(.title.bold())
                    .padding(.horizontal)

                CustomCalendar(
                    selectedDate: $dreamVM.selectedDate,
                    dayColor: { date in
                        let cal = Calendar.current
                        if cal.isDateInToday(date) { return .yellow }
                        let weekday = cal.component(.weekday, from: date)
                        return (weekday == 1 || weekday == 7) ? .orange : .white
                    },
                    selectedBackground: .purple
                )
                .padding(.horizontal)
                .onChange(of: dreamVM.selectedDate) { _ in
                    // Logger.log("Date changed to: \(dreamVM.selectedDate)", level: .info)
                    Task { await dreamVM.loadDreamsForSelectedDate() }
                }

                Text("Dreams")
                    .font(.title2.bold())
                    .padding(.horizontal)

                if dreamVM.isLoading && dreamVM.dreams.isEmpty {
                    ProgressView().padding(.horizontal)
                } else if filteredDreams.isEmpty {
                    Text("No dreams for this day.")
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
                            .simultaneousGesture(TapGesture().onEnded {
                                Logger.log("Dream card tapped: \(dream.title ?? "Untitled")", level: .info)
                            })
                        }
                    }
                }

                if let err = dreamVM.errorMessage {
                    Text(err)
                        .foregroundColor(.red)
                        .font(.footnote)
                        .padding(.horizontal)
                }
            }
        }
        .background(LinearGradient.onboardingBackground.ignoresSafeArea())
        .foregroundColor(.white)
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            // Logger.log("HomeView appeared", level: .info)
        }
        .task(id: dreamVM.selectedDate.m()) {
            // Logger.log("Loading monthly entries for month: \(dreamVM.selectedDate.m())", level: .info)
            // When month changes load monthly entry indicators
            await dreamVM.loadMonthlyEntries(year: dreamVM.selectedDate.y(),
                                             month: dreamVM.selectedDate.m())
        }
    }
}

#Preview {
    NavigationStack { // Provide stack in preview to test links
        HomeView()
    }
}
