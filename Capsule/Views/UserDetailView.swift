//
//  UserDetailView.swift
//  Cours_13_Map_GPS
//
//  Created by prof005 on 2024-11-22.
//

import SwiftUI
import CoreLocation

struct UserDetailView: View {
    
    let user: FirebaseUser
    private let dbController = DbController.shared
    
    var body: some View {
        VStack{
            Image(systemName: user.avatar)
                .resizable()
                .frame(width: 100, height: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/)
                .padding()
            Text(user.name)
                .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
            
            Text("Send a Capsule: ")
            List {
                ForEach(dbController.capsules, id: \.id) { capsule in
                    CapsuleContentView(capsule: capsule)
                        .onTapGesture {
                            dbController.sendCapsule(userId: user.id, capsule: capsule)
                        }
                }
            }
            .listStyle(.plain)
        }
        .padding()
        .navigationTitle("User Details")
    }
}

#Preview {
    let authController = AuthController.shared
    UserDetailView(user: authController.users[0])
}
