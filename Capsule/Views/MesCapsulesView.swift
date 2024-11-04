//
//  MyCapsules.swift
//  Capsule
//
//  Created by Aleck David Holly on 2024-10-30.
//

import SwiftUI
import SwiftData

struct MesCapsulesView: View {
    @Query private var capsules: [Capsule]
    
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(capsules, id: \.id) { capsule in
                    VStack(alignment: .leading) {
                        NavigationLink {
                            SingleCapsule(capsule: capsule)
                        } label: {
                            HStack {
                                Circle()
                                    .fill(capsule.estOuverte ? .green : .red)
                                    .frame(width: 15, height: 15)
                                
                                Text(capsule.estOuverte ? "Ouverte" : "Fermee")
                            }
                            
                            Text("A ouvrir le \(capsule.dateOuverture)")
                        }
                    }
                }
            }
            .navigationTitle("Mes Capsules")
        }
    }
}

#Preview {
    MesCapsulesView()
}
