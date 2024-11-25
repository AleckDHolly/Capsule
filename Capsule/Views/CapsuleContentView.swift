//
//  CapsuleContentView.swift
//  Capsule
//
//  Created by Aleck David Holly on 2024-11-12.
//

import SwiftUI
import FirebaseAuth

struct CapsuleContentView: View {
    let capsule: Capsule
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Circle()
                    .fill(capsule.estOuverte ? .green : .red)
                    .frame(width: 15, height: 15)
                
                Text(capsule.estOuverte ? "Ouverte" : "Fermee")
            }
            Text("A ouvrir le \(capsule.dateOuverture)")
            Text(capsule.creator)
        }
    }
}
