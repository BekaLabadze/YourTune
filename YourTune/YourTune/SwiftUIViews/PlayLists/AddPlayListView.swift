//
//  AddPlayListView.swift
//  YourTune
//
//  Created by Beka on 29.01.25.
//

import SwiftUI

struct AddPlayListView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Binding var isPresented: Bool
    @State var playListName: String = ""
    @ObservedObject var viewModel: PlaylistViewModelSwiftUI

    var body: some View {
        ZStack {
            themeManager.backgroundGradient
                .ignoresSafeArea()

            VStack(spacing: 20) {
                TextField("Enter Playlist Name", text: $playListName)
                    .padding()
                    .foregroundColor(themeManager.textColor)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(themeManager.isDarkMode ? Color.black.opacity(0.1) : Color.white.opacity(0.1))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(themeManager.buttonGradient, lineWidth: 1)
                    )
                    .padding(.horizontal)

                Button {
                    if !playListName.isEmpty {
                        viewModel.createPlaylist(playListName: playListName) { success in
                            DispatchQueue.main.async {
                                if success {
                                    isPresented = false
                                }
                            }
                        }
                    }
                } label: {
                    Text("Save")
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(themeManager.buttonGradient.cornerRadius(10))
                }
                .disabled(viewModel.isSaving)
                .padding(.horizontal)

                Button {
                    isPresented = false
                } label: {
                    Text("Cancel")
                        .font(.headline)
                        .foregroundColor(themeManager.textColor)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(themeManager.buttonGradient.cornerRadius(10))
                }
                .padding(.horizontal)
            }
            .padding()
        }
    }
}

