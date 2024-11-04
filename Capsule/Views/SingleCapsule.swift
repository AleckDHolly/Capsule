//
//  SingleCapsule.swift
//  Capsule
//
//  Created by Aleck David Holly on 2024-11-02.
//

import SwiftUI

struct SingleCapsule: View {
    var capsule: Capsule
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(capsule.message)
            
            Button {
                
            } label: {
                Text("Marquer comme lu")
            }
        }
        .navigationTitle("Details de la capsule")
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .onAppear {
            capsule.estOuverte = true
        }
        .padding()
    }
}

#Preview {
    SingleCapsule(capsule: Capsule(message: "", dateOuverture: "", estOuverte: false))
}
