//
//  AddPlayListView.swift
//  YourTune
//
//  Created by Beka on 29.01.25.
//

import SwiftUI

struct AddPlayListView: View {
    @EnvironmentObject var themeManager: ThemeManager
    var playListManager = PlayListManager.shared
    @Binding var playListArray: [Playlist]
    @Binding var isPresented: Bool
    @State var playListName: String = ""

    var body: some View {
        ZStack {
            themeManager.backgroundGradient
                .ignoresSafeArea(.all)

            VStack {
                TextField("", text: $playListName, prompt: Text("Enter Playlist Name").foregroundColor(themeManager.textColor))
                    .padding()
                    .foregroundColor(themeManager.textColor)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(themeManager.isDarkMode ? Color.white.opacity(0.1) : Color.black.opacity(0.1))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                themeManager.buttonGradient,
                                lineWidth: 1
                            )
                    )

                Spacer().frame(height: 50)

                Button {
                    if !playListName.isEmpty && !playListArray.contains(where: { $0.name == playListName }) {
                        let newPlayList = Playlist(name: playListName)
                        playListArray.append(newPlayList)
                    }
                    playListName = ""
                } label: {
                    Text("Save")
                        .font(.headline)
                        .foregroundColor(themeManager.textColor)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            themeManager.buttonGradient
                                .cornerRadius(10)
                                .shadow(color: .black.opacity(0.4), radius: 5, x: 0, y: 5)
                        )
                }

                Spacer().frame(height: 50)

                Button {
                    isPresented = false
                } label: {
                    Text("Cancel")
                        .font(.headline)
                        .foregroundColor(themeManager.textColor)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            themeManager.buttonGradient
                                .cornerRadius(10)
                                .shadow(color: .black.opacity(0.4), radius: 5, x: 0, y: 5)
                        )
                }
            }
            .padding()
        }
    }
}
