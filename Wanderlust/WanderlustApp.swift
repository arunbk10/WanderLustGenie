//
//  WanderlustApp.swift
//  Wanderlust
//
//  Created by Arun Kulkarni on 22/02/24.
//

import SwiftUI

@main
struct WanderlustApp: App {
    
    @State private var viewModel = ChatViewModel()
    
    var body: some Scene {
        WindowGroup {
            ConversationView()           
        }.windowStyle(.plain)

        ImmersiveSpace(id: "Chatbot") {
            ImmersiveView().environment(viewModel)
        }
    }
}
