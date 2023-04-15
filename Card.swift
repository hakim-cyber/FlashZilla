//
//  Card.swift
//  FlashZilla
//
//  Created by aplle on 4/9/23.
//

import Foundation
import SwiftUI

struct Card :Codable,Hashable,Identifiable{
    var id = UUID()
    let prompt :String
    let answer : String
    
    static var isFalse = false
 
    
    static let exampe = Card(prompt: "who played 13 th doctor in doctor who", answer: "Jodie Whitakker")
}
