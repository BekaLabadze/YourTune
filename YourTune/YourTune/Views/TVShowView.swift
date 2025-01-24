//
//  ContentView.swift
//  YourTune
//
//  Created by Beka on 11.01.25.
//

import SwiftUI

struct TVShowView: View {
    @StateObject var viewModel = TVShowViewModel()
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var themeManager: ThemeManager
    @State var searchText = ""
    let gridLayout = [GridItem(.flexible(), spacing: 20), GridItem(.flexible(), spacing: 20)]

    var body: some View {
        ZStack {
            themeManager.backgroundGradient
                .ignoresSafeArea()
            NavigationView {
                VStack(spacing: 16) {
                    Text("TV Shows")
                        .font(.largeTitle)
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [.blue, .purple, .pink]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .padding(.top, 16)

                    TextField("", text: $viewModel.searchQuery, prompt: Text("Search TV Shows").foregroundColor(themeManager.secondaryTextColor))
                        .padding(12)
                        .foregroundColor(themeManager.textColor)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(themeManager.isDarkMode ? Color.white.opacity(0.1) : Color.black.opacity(0.05))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.cyan, Color.purple]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                        .padding(.horizontal, 16)

                    ScrollView {
                        LazyVGrid(columns: gridLayout, spacing: 20) {
                            ForEach(viewModel.filteredTVShows, id: \.id) { tvShow in
                                NavigationLink(destination: songsViewController(tvShow: tvShow)) {
                                    Image(tvShow.image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 170, height: 200)
                                        .clipped()
                                        .opacity(0.85)
                                        .cornerRadius(10)
                                        .shadow(color: themeManager.isDarkMode ? Color.white.opacity(0.2) : Color.black.opacity(0.2), radius: 10, x: 0, y: 0)
                                }
                            }
                        }
                        .padding()
                    }
                    .padding(.top, 8)
                }
                .navigationTitle("")
                .navigationBarHidden(true)
                .toolbarBackground(
                    themeManager.backgroundGradient,
                    for: .tabBar
                )
                .toolbarBackground(
                    themeManager.backgroundGradient,
                    for: .navigationBar
                )
                .onChange(of: viewModel.searchQuery) { _ in
                    viewModel.filterTVShows()
                }
                .onAppear {
                    viewModel.fetchTVShows()
                }
                .background(themeManager.backgroundGradient)
            }
        }
    }

    func songsViewController(tvShow: TVShow) -> some View {
        Wrapper(tvShow: tvShow, userViewModel: userViewModel)
            .background(themeManager.backgroundGradient)
    }
}

