//
//  TVShowsView.swift
//  YourTune
//
//  Created by Beka on 29.01.25.
//

import SwiftUI

struct TVShowsView: View {
    @StateObject var viewModel = TvShowsViewModel()
    @EnvironmentObject var themeManager: ThemeManager
    @State var searchText = ""
    let gridLayout = [GridItem(.flexible(), spacing: 20), GridItem(.flexible(), spacing: 20)]

    var body: some View {
        ZStack {
            themeManager.backgroundGradient
            .ignoresSafeArea()

            VStack(spacing: 16) {
                Text("TV Shows")
                    .font(.largeTitle)
                    .foregroundColor(themeManager.isDarkMode ? Color.white : Color(red: 0.10, green: 0.10, blue: 0.10))
                    .padding(.top, 16)

                TextField("", text: $viewModel.searchQuery, prompt: Text("Search TV Shows").foregroundColor(themeManager.isDarkMode ? Color(red: 0.70, green: 0.70, blue: 0.70) : Color(red: 0.33, green: 0.33, blue: 0.33)))
                    .padding()
                    .foregroundColor(themeManager.textColor)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(themeManager.isDarkMode ? Color(red: 0.22, green: 0.22, blue: 0.22) : Color.black.opacity(0.05))
                    )
                    .padding(.horizontal, 20)
                    .onChange(of: viewModel.searchQuery) { _ in
                        viewModel.filterTVShows()
                    }

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

                Spacer()
            }
        }
        .onAppear {
            viewModel.fetchTVShows()
        }
    }

    func songsViewController(tvShow: TVShow) -> some View {
        Wrapper(tvShow: tvShow, userViewModel: .init())
            .background(themeManager.backgroundGradient)
    }
}
