//
//  ProfileHeader.swift
//  YourTune
//
//  Created by Beka on 31.01.25.
//

import SwiftUI

struct ProfileHeaderView: View {
    var profileImageURL: String?
    @Binding var showImagePicker: Bool

    var body: some View {
        VStack {
            ZStack(alignment: .bottomTrailing) {
                if let profileURL = profileImageURL, let url = URL(string: profileURL) {
                    AsyncImage(url: url) { image in
                        image.resizable()
                    } placeholder: {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .foregroundColor(.gray)
                    }
                    .frame(width: 110, height: 110)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 4))
                    .shadow(radius: 10)
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 110, height: 110)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 4))
                        .shadow(radius: 10)
                }

                Button(action: { showImagePicker = true }) {
                    Image(systemName: "pencil.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.white)
                        .background(Color.black.opacity(0.7))
                        .clipShape(Circle())
                }
                .offset(x: 10, y: 10)
            }
        }
        .padding(.bottom, 5)
    }
}
