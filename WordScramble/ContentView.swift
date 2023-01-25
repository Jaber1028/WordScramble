//
//  ContentView.swift
//  WordScramble
//
//  Created by jacob aberasturi on 1/23/23.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    // Score will be counted based on total letter used
    @State private var scoreCount = 0
    
    var body: some View {
        NavigationStack {
            List {
                Section("Input a word!") {
                    TextField("enter your word", text: $newWord)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                }
                
                Section("Your Score:") {
                    Text("\(scoreCount) points!")
                        .font(.title)
                }
                
                Section("Used Words") {
                    ForEach(usedWords, id: \.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
            }
            .navigationTitle(rootWord)
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showingError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
            .toolbar {
                ToolbarItem {
                    Button("Start new Game!", action: startGame)
                }
            }
            Spacer()
        }
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 0 else { return }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Cant make this word", message: "you cant spell that from \(rootWord)!")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Unrecognized word!", message: "Use real words!")
            return
        }
        
        guard isSizeable(word: answer) else {
            wordError(title: "Answer is wrong size!", message: "It is either less than 3 words or the start word!")
            return
        }
        
        withAnimation {
            usedWords.insert(answer, at: 0)
        }
        
        scoreCount += answer.count
        newWord = ""
    }
    
    func startGame() {
        if let wordDocument = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: wordDocument) {
                let allwords = startWords.components(separatedBy: "\n")
                rootWord = allwords.randomElement() ?? "silkworm"
                usedWords = [String]()
                scoreCount = 0
                return
            }
        }
        
        // If code gets here, we could not get the words or word file
        fatalError("Could not load start.txt from bundle")
    }
    
    // Checks if we used this word or not for this root word
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    // Checks if inputted word is possible
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    
    // OBJ C Spaggeti Code
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    func wordError(title: String, message: String) {
        errorTitle = message
        errorTitle = title
        showingError = true
    }
    
    func isSizeable(word: String) -> Bool {
        word.count > 2 && word.count < rootWord.count
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
