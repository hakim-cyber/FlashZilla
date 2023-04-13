import SwiftUI

extension View {
    func stacked(at position: Int, in total: Int) -> some View {
        let offset = Double(total - position)
        return self.offset(x: 0, y: offset * 10)
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
                    ForEach(0..<cards.count, id: \.self) { index in
                        CardView(card: cards[index]) { result in
                            withAnimation {
                                removeCard(at: index,result: result)
                                if result{
                                    score += 1
                                }else{
                                    score -= 1
                                }
                            }
                        }
                        .stacked(at: index, in: cards.count)
                        .allowsHitTesting(index == cards.count - 1)
                        .accessibilityHidden(index < cards.count - 1)
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
                        .accessibilityHint("Mark your answer as being incorrec")

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
    func removeCard(at index: Int,result:Bool) {
        guard index >= 0 else { return }
        if result{
            cards.remove(at: index)
        }else{
            withAnimation {
                
                
                let wrongCard =  cards.remove(at: index)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                    cards.insert(wrongCard, at: 0)
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
