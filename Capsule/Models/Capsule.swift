//
//  Capsule.swift
//  Capsule
//
//  Created by Aleck David Holly on 2024-10-30.
//

import Foundation
import Observation
import SwiftData

@Model
class Capsule {
    var id = UUID()
    var message: String
    var dateOuverture: String
    var estOuverte: Bool
    
    init(message: String, dateOuverture: String, estOuverte: Bool) {
        self.message = message
        self.dateOuverture = dateOuverture
        self.estOuverte = estOuverte
    }
}
