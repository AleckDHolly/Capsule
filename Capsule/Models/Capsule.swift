//
//  Capsule.swift
//  Capsule
//
//  Created by Aleck David Holly on 2024-10-30.
//

import Foundation
import Observation

class Capsule: Equatable, Identifiable {
    static func == (lhs: Capsule, rhs: Capsule) -> Bool {
        return lhs.id == rhs.id &&
        lhs.message == rhs.message &&
        lhs.dateOuverture == rhs.dateOuverture &&
        lhs.estOuverte == rhs.estOuverte &&
        lhs.read == rhs.read &&
        lhs.creator == rhs.creator &&
        lhs.uploadedImage == rhs.uploadedImage
    }
    
    var id: String
    var message: String?
    var dateOuverture: String
    var estOuverte: Bool
    var read: Bool
    var creator: String
    var uploadedImage: URL?
    
    init(id: String, message: String?, dateOuverture: String, estOuverte: Bool, read: Bool, creator: String, uploadedImage: URL?) {
        self.id = id
        self.message = message
        self.dateOuverture = dateOuverture
        self.estOuverte = estOuverte
        self.read = read
        self.creator = creator
        self.uploadedImage = uploadedImage
    }
}
