//
//  ContentView.swift
//  YourTune
//
//  Created by Beka on 11.01.25.
//

import SwiftUI

struct TVShowView: View {
    @StateObject var viewModel = ViewModel()
    @EnvironmentObject var userViewModel: UserViewModel
    @State var searchText = ""
    let gridLayout = [GridItem(.flexible(), spacing: 20), GridItem(.flexible(), spacing: 20)]
    
    var body: some View {
        ZStack {
            LinearGradient.shinyDarkGradient.edgesIgnoringSafeArea(.all)
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

                    TextField("", text: $viewModel.searchQuery, prompt: Text("Search TV Shows").foregroundColor(.white))
                        .padding(12)
                        .foregroundColor(.white)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.1))
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
                            ForEach(viewModel.filteredTVShows, id: \.id) { tvShows in
                                NavigationLink(destination: Wrapper(tvShow: tvShows, userViewModel: userViewModel)) {
                                    Image(tvShows.image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 170, height: 200)
                                        .clipped()
                                        .opacity(0.85)
                                        .cornerRadius(10)
                                        .shadow(color: Color.white.opacity(0.4), radius: 10, x: 0, y: 0)
                                }
                            }
                        }
                        .padding()
                    }
                    .padding(.top, 8)
                }
                .navigationTitle("")
                .navigationBarHidden(true)
                .toolbarBackground(LinearGradient.shinyDarkGradient, for: .tabBar)
                .toolbarBackground(LinearGradient.shinyDarkGradient, for: .navigationBar)
                .onChange(of: viewModel.searchQuery) { _ in
                    viewModel.filterTVShows()
                }
                .onAppear {
                    viewModel.fetchTVShows()
                }
                .background(LinearGradient.shinyDarkGradient.edgesIgnoringSafeArea(.all))
            }
        }
    }
}

#Preview {
    TVShowView()
}
