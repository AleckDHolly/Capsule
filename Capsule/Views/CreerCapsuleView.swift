//
//  Create.swift
//  Capsule
//
//  Created by Aleck David Holly on 2024-10-30.
//

import SwiftUI
import NaturalLanguage
import SwiftData

struct CreerCapsuleView: View {
    @State private var textEditor: String = ""
    @State var sentiment: String = String(localized: "inconnu-string")
    @State private var date: Date = Date.now
    @State private var capsule: Capsule?
    @Environment(\.modelContext) private var modelContext
    @FocusState private var focusedField: Field?
    
    enum Field: Hashable {
        case textEdit
    }
    
    var body: some View {
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
            
            Text("Sentiment Detecte: \(sentiment)")
                .onChange(of: textEditor) {
                    analyserSentiment()
                }
                
            
            DatePicker("Date d'ouverture:", selection: $date)
            
            
            Button {
                modelContext.insert(Capsule(message: textEditor, dateOuverture: date.formatted(.dateTime.month().day().year()), estOuverte: false))
                textEditor = ""
                sentiment = ""
            } label: {
                Text("Enregistrer la capsule")
                    .foregroundStyle(.background)
                    .padding()
                    .background(.blue)
                    .cornerRadius(10)
            }
        }
        .padding()
        .onTapGesture {
            focusedField = nil
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
