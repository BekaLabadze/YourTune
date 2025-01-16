//
//  MainTabView.swift
//  YourTune
//
//  Created by Beka on 12.01.25.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        ZStack {
            LinearGradient.shinyDarkGradient.ignoresSafeArea(.all)
            TabView {
                TVShowView()
                    .tabItem {
                        Label("TV Shows", systemImage: "tv")
                    }
                ExploreView()
                    .tabItem {
                        Label("Explore", systemImage: "globe")
                    }
                FavoritesView()
                    .tabItem {
                        Label("Favorites", systemImage: "heart.fill")
                    }
                ProfileView()
                    .tabItem {
                        Label("Profile", systemImage: "person.fill")
                    }
            }
            .toolbarBackground(LinearGradient.shinyDarkGradient, for: .tabBar)
            .accentColor(.purple)
            VStack {
                Spacer()
                Rectangle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.2),
                            Color.gray.opacity(0.4)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
                    .frame(height: 1)
                    .offset(y: -90)
                    .shadow(color: Color.black.opacity(0.6), radius: 5, x: 0, y: 5)
            }
        }
        .edgesIgnoringSafeArea(.bottom)
        }
    }
