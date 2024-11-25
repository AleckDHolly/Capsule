//
//  FirebaseUser.swift
//  Capsule
//
//  Created by Aleck David Holly on 2024-11-24.
//

import Foundation

struct FirebaseUser: Equatable, Identifiable {
    let id: String
    let name: String
    let avatar: String
    let latitude: Double
    let longitude: Double
}
