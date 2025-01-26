//
//  MainTabView.swift
//  YourTune
//
//  Created by Beka on 12.01.25.
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var viewModel = TVShowViewModel()
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        ZStack {
            themeManager.backgroundGradient
                .ignoresSafeArea()
            TabView {
                TVShowView(viewModel: viewModel)
                    .tabItem {
                        Label("TV Shows", systemImage: "tv")
                    }
                    .environmentObject(PlayListManager.shared)
                
                Explore(viewModel: ExploreViewModel(tvShows: viewModel.tvShows))
                    .tabItem {
                        Label("Explore", systemImage: "globe")
                    }
                    .environmentObject(PlayListManager.shared)
                
                FavoritesView(viewModel: FavoritesViewModel(tvShows: viewModel.tvShows))
                    .tabItem {
                        Label("Favorites", systemImage: "heart.fill")
                    }
                    .environmentObject(PlayListManager.shared)
                
                ProfileView()
                    .tabItem {
                        Label("Profile", systemImage: "person.fill")
                    }
                    .environmentObject(viewModel)
                    .environmentObject(PlayListManager.shared)
            }
            .toolbarBackground(
                themeManager.backgroundGradient,
                for: .tabBar
            )
            .accentColor(.purple)
            VStack {
                Spacer()
                Rectangle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [
                            Color.black.opacity(0.2),
                            Color.gray.opacity(0.4)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
                    .frame(height: 1)
                    .offset(y: -90)
                    .shadow(color: Color.black.opacity(0.4), radius: 5, x: 0, y: 5)
            }
        }
        .edgesIgnoringSafeArea(.bottom)
        .onAppear {
            viewModel.fetchTVShows()
        }
    }
}
