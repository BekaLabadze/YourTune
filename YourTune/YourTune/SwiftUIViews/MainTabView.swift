//
//  MainTabView.swift
//  YourTune
//
//  Created by Beka on 12.01.25.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        ZStack {
            themeManager.backgroundGradient
                .ignoresSafeArea()

            TabView {
                TVShowsView()
                    .tabItem { Label("TV Shows", systemImage: "tv") }

                Explore(viewModel: ExploreViewModel())
                    .tabItem { Label("Explore", systemImage: "globe") }

                FavoritesView(viewModel: FavoritesViewModel())
                    .tabItem { Label("Favorites", systemImage: "heart.fill") }

                ProfileView()
                    .tabItem { Label("Profile", systemImage: "person.fill") }
            }
            .accentColor(Color.green)
            .onAppear {
                themeManager.setupTabBarAppearance()
            }
            .onChange(of: themeManager.isDarkMode) { _ in
                themeManager.setupTabBarAppearance()
            }

            VStack {
                Spacer()
                Rectangle()
                    .fill(themeManager.isDarkMode ? Color.black.opacity(0.10) : Color.white.opacity(0.05))
                    .frame(height: 12)
                    .edgesIgnoringSafeArea(.bottom)
                    .blur(radius: 10)
            }
            .allowsHitTesting(false)
        }
    }
}
