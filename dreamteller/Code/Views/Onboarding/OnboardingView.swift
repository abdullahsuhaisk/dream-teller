//
//  OnboardingView.swift
//  dreamteller
//
//  Created by suha.isik on 28.10.2025.
//

import SwiftUI

struct OnboardingPage {
    let imageName: String
    let title: String
    let buttonTitle: String
}

struct OnboardingView: View {
    @State private var currentPage = 0
    @State private var offset: CGFloat = 0
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding = false
    
    let pages = [
        OnboardingPage(imageName: "onboarding1", title: "Welcome to your dream journal", buttonTitle: "Next"),
        OnboardingPage(imageName: "onboarding2", title: "Track your dreams", buttonTitle: "Next"),
        OnboardingPage(imageName: "onboarding2", title: "Analyze dream patterns", buttonTitle: "Get Started")
    ]
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                LinearGradient.onboardingBackground
                    .ignoresSafeArea()
                
                HStack(spacing: 0) {
                    ForEach(pages.indices, id: \.self) { index in
                        OnboardingPageView(page: pages[index], isLastPage: index == pages.count - 1) {
                            goNext()
                        }
                        .frame(width: geo.size.width) // <- screen width yerine GeometryReader
                    }
                }
                .offset(x: -CGFloat(currentPage) * geo.size.width + offset)
                .animation(.interactiveSpring(), value: offset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            offset = value.translation.width
                        }
                        .onEnded { value in
                            let threshold: CGFloat = geo.size.width / 3
                            if value.translation.width < -threshold && currentPage < pages.count - 1 {
                                currentPage += 1
                            } else if value.translation.width > threshold && currentPage > 0 {
                                currentPage -= 1
                            }
                            offset = 0
                        }
                )
                
                VStack {
                    Spacer()
                    PageIndicator(numberOfPages: pages.count, currentPage: currentPage)
                }
            }
        }
    }
    
    
    private func goNext() {
        withAnimation(.easeInOut(duration: 0.4)) {
            if currentPage < pages.count - 1 {
                currentPage += 1
            } else {
                hasSeenOnboarding = true
                print("Go to main app")
            }
        }
    }
    
    private func goBack() {
        withAnimation(.easeInOut(duration: 0.4)) {
            if currentPage > 0 {
                currentPage -= 1
            }
        }
    }
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    let isLastPage: Bool
    let onNext: () -> Void
    
    var body: some View {
        VStack {
            Image(page.imageName)
                .resizable()
                .scaledToFit()
                .frame(height: 400)
                .padding(.top, 40)
            
            Spacer()
            
            Text(page.title)
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .padding(.horizontal, 32)
            
            Spacer()
            
            HStack {
                if !isLastPage {
                    Button("Skip") {
                        onNext()
                    }
                    .foregroundColor(.gray)
                }
                
                Spacer()
                
                Button(page.buttonTitle) {
                    onNext()
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 10)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
        }
        .animation(.easeInOut, value: page.title)
    }
}


struct PageIndicator: View {
    let numberOfPages: Int
    let currentPage: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<numberOfPages, id: \.self) { index in
                Circle()
                    .fill(index == currentPage ? Color.blue : Color.gray.opacity(0.4))
                    .frame(width: index == currentPage ? 10 : 8,
                           height: index == currentPage ? 10 : 8)
                    .animation(.easeInOut(duration: 0.3), value: currentPage)
            }
        }
        .padding(.bottom, 20)
    }
}

#Preview {
    OnboardingView()
}
