//
//  Greetings.swift
//  Respawn Fitness
//
//  Created by Aleck Holly on 2024-09-19.
//

import SwiftUI

struct Greetings: View {
    var signInGreeting: String?
    
    var body: some View {
        HStack {
            VStack {
                Group {
                    Text("Welcome to")
                    
                    Text("Capsule")
                        .bold()
                        .italic()
                }
                .font(.title)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(maxHeight: 75)
    }
}

#Preview {
    Greetings()
}
