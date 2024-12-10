//
//  SingleCapsule.swift
//  Capsule
//
//  Created by Aleck David Holly on 2024-11-02.
//

import SwiftUI

struct SingleCapsule: View {
    var capsule: Capsule
    private let dbController = DbController.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            if let message = capsule.message {
                Text(message)
            }
            
            if let imageURL = capsule.uploadedImage {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .empty:
                        ProgressView("Loading...")
                            .frame(maxWidth: .infinity)
                            .frame(height: 200)
                    case .success(let image):
                        Rectangle()
                            .opacity(0)
                            .overlay {
                                image
                                    .resizable()
                                    .scaledToFill()
                            }
                            .frame(width: 350, height: 350)
                            .cornerRadius(10)
                            .clipped()
                            .padding()
                    case .failure(_):
                        Image(systemName: "photo.on.rectangle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 350, height: 350)
                            .padding()
                            .clipped()
                    @unknown default:
                        EmptyView()
                    }
                }
            }
            
            Button {
                dbController.markAsRead(capsule: capsule)
            } label: {
                Text(capsule.read ? "Marquer comme non lu" : "Marquer comme lu")
            }
        }
        .navigationTitle("Details de la capsule")
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .onAppear {
            dbController.markAsOpened(capsule: capsule)
        }
        .padding()
    }
}

//#Preview {
//    SingleCapsule(capsule: Capsule(id: "1", message: "", dateOuverture: "", estOuverte: false, read: false, canOpen: false, creator: ""))
//}
