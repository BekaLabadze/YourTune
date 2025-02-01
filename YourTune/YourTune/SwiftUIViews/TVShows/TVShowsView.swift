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
        NavigationView {
            ZStack(alignment: .top) {
                themeManager.backgroundGradient
                    .ignoresSafeArea()
                
                VStack(spacing: 16) {
                    Text("TV Shows")
                        .font(.largeTitle)
                        .foregroundColor(themeManager.textColor)

                    searchField()

                    ScrollView {
                        LazyVGrid(columns: gridLayout, spacing: 20) {
                            ForEach(viewModel.filteredTVShows, id: \.id) { tvShow in
                                NavigationLink(destination: songsViewController(tvShow: tvShow)) {
                                    tvShowCard(tvShow: tvShow)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.top, 5)
                    Spacer()
                }
                .navigationBarHidden(true)
                .hiddenNavigationBarStyle()
                .onAppear {
                    viewModel.fetchTVShows()
                }
            }
        }
    }

    func searchField() -> some View {
        TextField("", text: $searchText, prompt: Text("Search TV Shows")
            .foregroundColor(themeManager.isDarkMode ? Color.white : Color.black))
            .padding()
            .foregroundColor(themeManager.textColor)
            .background(RoundedRectangle(cornerRadius: 10)
                .fill(themeManager.isDarkMode ? Color.black.opacity(0.2) : Color.white.opacity(0.1)))
            .overlay(RoundedRectangle(cornerRadius: 10)
                .stroke(themeManager.isDarkMode ? Color.green : Color.black.opacity(0.1), lineWidth: 1))
            .padding(.horizontal, 16)
            .onChange(of: searchText) { newValue in
                viewModel.searchQuery = newValue
                viewModel.filterTVShows()
            }
    }

    func tvShowCard(tvShow: TVShow) -> some View {
        VStack(spacing: 6) {
            AsyncImage(url: URL(string: tvShow.image)) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 160, height: 190)
                        .clipped()
                        .cornerRadius(12)
                        .shadow(color: themeManager.isDarkMode ? Color.white.opacity(0.2) : Color.black.opacity(0.2), radius: 6)
                } else if phase.error != nil {
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 160, height: 190)
                        .foregroundColor(.gray)
                } else {
                    ProgressView()
                        .frame(width: 160, height: 190)
                }
            }

            Text(tvShow.title)
                .font(.headline)
                .foregroundColor(themeManager.textColor)
                .lineLimit(1)
                .frame(width: 160)
        }
    }


    func songsViewController(tvShow: TVShow) -> some View {
        Wrapper(tvShow: tvShow)
            .background(themeManager.backgroundGradient)
    }
}

struct HiddenNavigationBar: ViewModifier {
    func body(content: Content) -> some View {
        content
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarHidden(true)
    }
}

extension View {
    func hiddenNavigationBarStyle() -> some View {
        modifier( HiddenNavigationBar() )
    }
}
