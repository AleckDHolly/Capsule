//
//  Create.swift
//  Capsule
//
//  Created by Aleck David Holly on 2024-10-30.
//

import SwiftUI
import NaturalLanguage
import SwiftData
import FirebaseAuth

struct CreerCapsuleView: View {
    @State private var textEditor: String = ""
    @State var sentiment: String = String(localized: "inconnu-string")
    @State private var date: Date = Date.now
    @FocusState private var focusedField: Field?
    private let dbController = DbController.shared
    private let notificationManager = NotificationManager.shared
    private let authController = AuthController.shared
    @State private var image: UIImage?
    @State private var showCamera: Bool = false
    @State private var showGallery: Bool = false
    
    enum Field: Hashable {
        case textEdit
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Ecrire un message pour votre futur vous.")
                        .font(.title2)
                        .italic()
                    
                    TextEditor(text: $textEditor)
                        .focused($focusedField, equals: .textEdit)
                        .autocorrectionDisabled(true)
                        .overlay(
                            RoundedRectangle(cornerRadius: 7)
                                .stroke(.secondary, lineWidth: 2)
                        )
                        .frame(height: 400)
                    
                    if let image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 200)
                            .frame(maxWidth: .infinity)
                            .cornerRadius(10)
                            .padding()
                    }
                    
                    Text("Sentiment Detecte: \(sentiment)")
                        .onChange(of: textEditor) {
                            analyserSentiment()
                        }
                    
                    
                    DatePicker("Date d'ouverture:", selection: $date)
                    
                    
                    HStack(spacing: 1) {
                        Button {
                            showCamera = true
                        } label: {
                            Text("Prendre une photo")
                                .foregroundStyle(Color("backgroundColor"))
                                .padding()
                                .background(.blue)
                                .cornerRadius(10)
                        }
                        
                        Spacer()
                        
                        Button {
                            showGallery = true
                        } label: {
                            Text("Choisir une photo")
                                .foregroundStyle(Color("backgroundColor"))
                                .padding()
                                .background(.blue)
                                .cornerRadius(10)
                        }
                    }
                }
            }
            .padding()
            .sheet(isPresented: $showCamera) {
                CameraView(capturedImage: $image)
            }
            .sheet(isPresented: $showGallery) {
                ImagePicker(selectedImage: $image)
            }
            .onTapGesture {
                focusedField = nil
            }
            .toolbar {
                ToolbarItem {
                    Button {
                        
                        if image != nil || !textEditor.isEmpty {
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "MMM. d yyyy 'at' h:mm a"
                            let formattedDate = dateFormatter.string(from: date)
                            
                            // Add the item to the database with the formatted date
                            dbController.addItem(message: textEditor, dateOuverture: formattedDate, estOuverte: false, read: false, image: image)
                            textEditor = ""
                            image = nil
                        }
                    } label: {
                        Text("Add Capsule")
                    }
                }
            }
        }
    }
    
    func analyserSentiment() {
        let tagger = NLTagger(tagSchemes: [.sentimentScore])
        tagger.string = textEditor
        
        let (sentimentScore, _) = tagger.tag(at: textEditor.startIndex, unit: .paragraph, scheme: .sentimentScore)
        
        if let sentimentValue = sentimentScore?.rawValue, let value = Double(sentimentValue) {
            if value > 0 {
                sentiment = String(localized: "positif-string")
            } else if value < 0 {
                sentiment = String(localized: "negatif-string")
            } else {
                sentiment = String(localized: "neutre-string")
            }
        } else {
            sentiment = String(localized: "inconnu-string")
        }
    }
}

#Preview {
    CreerCapsuleView()
}
