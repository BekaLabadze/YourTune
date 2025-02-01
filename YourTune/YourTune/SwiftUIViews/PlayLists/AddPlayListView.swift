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
                TextField("", text: $playListName, prompt: Text("Enter Playlist Name")
                    .foregroundColor(themeManager.isDarkMode ? .white : .gray))
                    .padding()
                    .foregroundColor(themeManager.isDarkMode ? .white : .black)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(themeManager.isDarkMode ? Color(red: 0.15, green: 0.15, blue: 0.15) : Color.white.opacity(0.9))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(themeManager.isDarkMode ? Color.green : Color.gray.opacity(0.5), lineWidth: 1)
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
                        .foregroundColor(themeManager.textColor)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(themeManager.isDarkMode ? Color(red: 0.15, green: 0.15, blue: 0.15) : Color.white.opacity(0.9))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(themeManager.isDarkMode ? Color.green : Color.gray.opacity(0.5), lineWidth: 1)
                        )
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
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(themeManager.isDarkMode ? Color(red: 0.15, green: 0.15, blue: 0.15) : Color.white.opacity(0.9))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(themeManager.isDarkMode ? Color.green : Color.gray.opacity(0.5), lineWidth: 1)
                        )
                }
                .padding(.horizontal)
            }
            .padding()
        }
    }
}

