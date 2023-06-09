import SwiftUI

extension View {
    func stacked(at position: Card, in total: [Card]) -> some View {
        let totalIndex = total.count
        if let positionIndex = try? total.firstIndex(of: position){
            let offset = Double(totalIndex - positionIndex)
            return self.offset(x: 0, y: offset * 10)
        }
        return self.offset(x: 0,y: 0)
    }
}

struct ContentView: View {
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    @Environment(\.accessibilityVoiceOverEnabled) var voiceOverEnabled
    @State private var cards = [Card]()
    let safeUrl = "Cards"

    @State private var timeRemaining = 100
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    @Environment(\.scenePhase) var scenePhase
    @State private var isActive = true
    @State private var score = 0

    @State private var showingEditScreen = false

    var body: some View {
        ZStack {
            Image("background")
                .resizable()
                .ignoresSafeArea()

            VStack {
                HStack{
                    Text("Time: \(timeRemaining)")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 5)
                        .background(.black.opacity(0.75))
                        .clipShape(Capsule())
                
                    Text("Score: \(score)")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 5)
                        .background(.blue.opacity(0.75))
                        .clipShape(Capsule())
                        .padding()
                }

                ZStack {
                    ForEach(cards) { card in
                        CardView(card: card) { result in
                            withAnimation {
                                removeCard(card: card,result: result)
                                if result{
                                    score += 1
                                }else{
                                    score -= 1
                                }
                            }
                        }
                        .stacked(at: card, in: cards)
                        .allowsHitTesting(cards.firstIndex(of: card) == cards.count - 1)
                        .accessibilityHidden(cards.firstIndex(of: card)! < cards.count - 1)
                    }
                }
                .allowsHitTesting(timeRemaining > 0)

                if cards.isEmpty {
                    Button("Start Again", action: resetCards)
                        .padding()
                        .background(.white)
                        .foregroundColor(.black)
                        .clipShape(Capsule())
                }
            }

            VStack {
                HStack {
                    Spacer()

                    Button {
                        showingEditScreen = true
                    } label: {
                        Image(systemName: "plus.circle")
                            .padding()
                            .background(.black.opacity(0.7))
                            .clipShape(Circle())
                    }
                }

                Spacer()
            }
            .foregroundColor(.white)
            .font(.largeTitle)
            .padding()

            if differentiateWithoutColor || voiceOverEnabled {
                VStack {
                    Spacer()

                    HStack {
                        Button {
                            withAnimation {
                               
                            }
                        } label: {
                            Image(systemName: "xmark.circle")
                                .padding()
                                .background(.black.opacity(0.7))
                                .clipShape(Circle())
                        }
                        .accessibilityLabel("Wrong")
                        .accessibilityHint("Mark your answer as being incorrect")

                        Spacer()

                        Button {
                            withAnimation {
                                
                            }
                        } label: {
                            Image(systemName: "checkmark.circle")
                                .padding()
                                .background(.black.opacity(0.7))
                                .clipShape(Circle())
                        }
                        .accessibilityLabel("Correct")
                        .accessibilityHint("Mark your answer is being correct.")
                    }
                    .foregroundColor(.white)
                    .font(.largeTitle)
                    .padding()
                }
            }
        }
        .onReceive(timer) { time in
            guard isActive else { return }

            if timeRemaining > 0 {
                timeRemaining -= 1
            }
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                if cards.isEmpty == false {
                    isActive = true
                }
            } else {
                isActive = false
            }
        }
        .sheet(isPresented: $showingEditScreen, onDismiss: resetCards, content: EditCards.init)
        .onAppear(perform: resetCards)
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
    func removeCard(card :Card,result:Bool) {
        if let index  = try? cards.firstIndex(of: card){
            guard index  >= 0 else { return }
            if result{
                withAnimation {
                    cards.remove(at: index)
                }
               
            }else{
                withAnimation {
                    withAnimation {
                    
                    let wrongCard =  cards.remove(at: index)
                    let newCard = Card(prompt: wrongCard.prompt, answer: wrongCard.answer)
                    
                        cards.insert(newCard, at: 0)
                    
                    }
                       
                    
                }
                
            }
        }

        if cards.isEmpty {
            isActive = false
        }
    }

    func resetCards() {
        timeRemaining = 100
        isActive = true
        score = 0
        loadCards()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
