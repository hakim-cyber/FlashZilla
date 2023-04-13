//
//  EditCards.swift
//  FlashZilla
//
//  Created by aplle on 4/12/23.
//

import SwiftUI

struct EditCards: View {
    @State  private var cards = [Card]()
@State private var answer = ""
    @State private var prompt = ""
  
    @Environment(\.dismiss) var dismiss
    let safeUrl = "Cards"
    var body: some View {
        NavigationView{
            Form{
                Section("Prompt"){
                    TextEditor(text: $prompt)
                }
                TextField("Answer", text: $answer)
                HStack{
                    Spacer()
                    Button("Add",action: addCard)
                    Spacer()
                }
                .disabled(answer.isEmpty || prompt.isEmpty)
                
                Section("Recently Added"){
                    List{
                        
                        
                        ForEach(cards,id: \.self) { card in
                            VStack{
                                Text(card.prompt)
                                    .padding(1)
                               
                                Text(card.answer)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .onDelete(perform: remove)
                    }
                   
                }
                
            }
            .listStyle(.grouped)
            .toolbar{
                Button("Done",action: done)
            }
            .onAppear(perform: loadCards)
        }
    }
    func remove(at offset:IndexSet){
        cards.remove(atOffsets:  offset)
       save()
    }
    func addCard(){
        let newCard = Card(prompt: prompt.trimmingCharacters(in: .whitespaces), answer: answer.trimmingCharacters(in: .whitespaces))
        cards.insert(newCard, at: 0)
        save()
        
    }
    func done(){
        dismiss()
    }
    func save(){
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = documentsDirectory.appendingPathComponent(safeUrl)
        let encoder = JSONEncoder()
        do{
            let encodedCards = try encoder.encode(cards)
            try encodedCards.write(to: url,options: [.atomic,.completeFileProtection])
            
        }catch{
            print("Saving Error")
        }
    answer = ""
        prompt = ""
    }
    func loadCards(){
        let decoder = JSONDecoder()
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = documentsDirectory.appendingPathComponent(safeUrl)
        
        if let data = try? Data(contentsOf: url){
            if let decodedCards = try? decoder.decode([Card].self, from: data){
                cards = decodedCards
            }
        }
    }
}

struct EditCards_Previews: PreviewProvider {
    static var previews: some View {
        EditCards()
    }
}
