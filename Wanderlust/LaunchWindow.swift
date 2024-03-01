//
//  LaunchWindow.swift
//  Wanderlust
//
//  Created by Kishor L D on 01/03/24.
//

import Foundation
import SwiftUI

struct LaunchWindow: Scene {
    
    var body: some Scene {
        WindowGroup(id: "ConverseView") {
            ConversationView()
        }.windowStyle(.plain).defaultSize(width: 0.80, height:0.75, depth: 1, in: .meters)
    }
}
