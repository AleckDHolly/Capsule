//
//  MyCapsules.swift
//  Capsule
//
//  Created by Aleck David Holly on 2024-10-30.
//

import SwiftUI

struct MesCapsulesView: View {
    @Bindable private var dbController = DbController.shared
    private var notificationManager = NotificationManager.shared
    private var authController = AuthController.shared
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var showMessage: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(dbController.capsules, id: \.id) { capsule in
                    if dbController.isDatePassed(capsule.dateOuverture) {
                        NavigationLink(destination: SingleCapsule(capsule: capsule)) {
                            CapsuleContentView(capsule: capsule)
                        }
                    } else {
                        CapsuleContentView(capsule: capsule)
                            .opacity(0.5)
                    }
                }
                .onDelete { indexSet in
                    handleDelete(indexSet)
                }
            }
            .alert("You cannot delete the capsule since you are not the owner", isPresented: $showMessage) {
                Button("OK", role: .cancel) {}
            }
            .navigationTitle("Mes Capsules")
            .onReceive(timer) { _ in
                dbController.fetchItems()
            }
        }
    }
    
    private func handleDelete(_ indexSet: IndexSet) {
        for index in indexSet {
            let capsule = dbController.capsules[index]
            dbController.deleteItem(capsule: capsule)
        }
    }
}

#Preview {
    MesCapsulesView()
}
