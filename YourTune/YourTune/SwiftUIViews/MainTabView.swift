//
//  MainTabView.swift
//  YourTune
//
//  Created by Beka on 12.01.25.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State var toolColor: LinearGradient = ThemeManager.shared.tabBarGradient

    var body: some View {
        ZStack {
            TabView {
                TVShowsView()
                    .tabItem { Label("TV Shows", systemImage: "tv") }
                    .toolbarBackground(toolColor, for: .tabBar)
                Explore(viewModel: ExploreViewModel())
                    .tabItem { Label("Explore", systemImage: "globe") }
                    .toolbarBackground(toolColor, for: .tabBar)
                FavoritesView(viewModel: FavoritesViewModel())
                    .tabItem { Label("Favorites", systemImage: "heart.fill") }
                    .toolbarBackground(toolColor, for: .tabBar)
                ProfileView()
                    .tabItem { Label("Profile", systemImage: "person.fill") }
                    .toolbarBackground(toolColor, for: .tabBar)
            }
            .accentColor(Color.green)
            .onAppear {
                themeManager.setupTabBarAppearance()
            }
        }
    }
}
