//
//  ExploreView.swift
//  YourTune
//
//  Created by Beka on 16.01.25.
//

import SwiftUI

struct Explore: View {
    @State private var selectedSong: Song?
    @State private var showPlayer: Bool = false
    @ObservedObject var viewModel: ExploreViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        NavigationView {
            ZStack {
                themeManager.backgroundGradient
                    .ignoresSafeArea()

                VStack {
                    searchBar
                    filterBar

                    if viewModel.filteredSongs.isEmpty {
                        Text("No Songs Found")
                            .foregroundColor(themeManager.textColor)
                            .font(.headline)
                            .padding()
                    } else {
                        List(viewModel.filteredSongs, id: \.id) { song in
                            HStack {
                                if let url = userViewModel.getCoverURL(song: song) {
                                    AsyncImage(url: url) { result in
                                        switch result {
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 60, height: 60)
                                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                        case .failure:
                                            Image(systemName: "music.note.list")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 60, height: 60)
                                                .foregroundColor(themeManager.isDarkMode ? .gray : .black)
                                        default:
                                            ProgressView()
                                                .frame(width: 60, height: 60)
                                        }
                                    }
                                } else {
                                    Image(systemName: "music.note.list")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 60, height: 60)
                                        .foregroundColor(themeManager.isDarkMode ? .gray : .black)
                                }

                                VStack(alignment: .leading, spacing: 5) {
                                    Text(song.title)
                                        .font(.headline)
                                        .foregroundColor(themeManager.textColor)
                                    Text("Artist: \(song.artist)")
                                        .font(.subheadline)
                                        .foregroundColor(themeManager.secondaryTextColor)
                                    if viewModel.filterOption == .mostViewed {
                                        Text("Views: \(song.viewCount)")
                                            .font(.caption)
                                            .foregroundColor(themeManager.secondaryTextColor)
                                    }
                                    if viewModel.filterOption == .mostLiked {
                                        Text("Likes: \(song.likeCount)")
                                            .font(.caption)
                                            .foregroundColor(themeManager.secondaryTextColor)
                                    }
                                }
                                .onTapGesture {
                                    selectedSong = song
                                    showPlayer = true
                                }
                            }
                            .listRowBackground(Color.clear)
                        }
                        .listStyle(PlainListStyle())
                    }
                }
                .padding()
            }
            .task {
                
                viewModel.fetchAndMapSongs()
            }
            .toolbar (){
                ToolbarItem(placement: .topBarLeading) {
                    Text("Explore")
                        .foregroundStyle(themeManager.textColor)
                }
            }
            .toolbarBackground(themeManager.backgroundGradient, for: .navigationBar)
            .sheet(isPresented: $showPlayer) {
                if let selectedSong = selectedSong {
                    PlayerWrapper(selectedSong: selectedSong, songArray: viewModel.filteredSongs)
                }
            }
            .onChange(of: viewModel.searchText) { _ in
                viewModel.filterAndSortSongs()
            }
        }
    }

    private var searchBar: some View {
        TextField("Search Songs", text: $viewModel.searchText)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding()
            .foregroundColor(themeManager.textColor)
            .background(themeManager.isDarkMode ? Color.white.opacity(0.1) : Color.gray.opacity(0.1))
            .cornerRadius(10)
    }

    private var filterBar: some View {
        HStack {
            Spacer()
            filterButton(title: "Most Viewed", option: .mostViewed)
            filterButton(title: "Most Liked", option: .mostLiked)
            Spacer()
        }
        .padding(.bottom, 10)
    }

    private func filterButton(title: String, option: FilterOption) -> some View {
        Button(action: {
            viewModel.filterOption = option
        }) {
            Text(title)
                .font(.footnote)
                .padding(8)
                .background(
                    viewModel.filterOption == option ? AnyView(themeManager.buttonGradient) : AnyView(Color.gray.opacity(0.5))
                )
                .foregroundColor(.white)
                .cornerRadius(10)
        }
    }
}

enum FilterOption {
    case mostViewed
    case mostLiked
}

