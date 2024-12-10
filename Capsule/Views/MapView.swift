//
//  MapView.swift
//  Capsule
//
//  Created by Aleck David Holly on 2024-11-24.
//

import SwiftUI
import MapKit

struct MapView: View {
    private var locationManager = LocationManager.shared
    private let authController = AuthController.shared
    @State private var coorRegion: MKCoordinateRegion
    @State private var selectedUser: FirebaseUser?
    
    init() {
        coorRegion = MKCoordinateRegion(center: locationManager.location ?? CLLocationCoordinate2D(), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Map(coordinateRegion: $coorRegion, annotationItems: authController.users) { user in
                    MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: user.latitude, longitude: user.longitude)) {
                        VStack{
                            Image(systemName: user.avatar)
                            Text(user.name)
                                .font(.caption)
                        }.onTapGesture {
                            selectedUser = user
                        }
                    }
                }
                .ignoresSafeArea()
                
                List(authController.users) { user in
                    NavigationLink(destination: UserDetailView(user: user)){
                        HStack{
                            Image(systemName: user.avatar)
                            VStack(alignment: .leading){
                                Text(user.name)
                                    .font(.headline)
                                
                            }
                        }.onTapGesture {
                            coorRegion.center = CLLocationCoordinate2D(latitude: user.latitude, longitude: user.longitude)
                        }
                    }
                }
                
            }
            .onAppear {
                authController.fetchUsers()
            }
        }
    }
}

#Preview {
    MapView()
}
