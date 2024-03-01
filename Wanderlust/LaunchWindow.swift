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
        }.windowStyle(.plain).defaultSize(width: 0.7, height: 0.7, depth: -0.15, in: .meters)
    }
}
