//
//  RoomOptionsView.swift
//  Wanderlust
//
//  Created by Arun Kulkarni on 03/03/24.
//

import SwiftUI

struct RoomOptionsView: View {
    
    @StateObject var viewModel: HotelViewModel

    @State private var selectedRoomID = 0
    
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace    
    var body: some View {
        HStack(spacing: 20) {
                VStack {
                    Picker("Types of Vehicles - Segmented", selection: $selectedRoomID) {
                        ForEach(viewModel.rooms) { room in
                            Text(room.title)
                       }
                    }
                    .pickerStyle(.segmented)
                    .padding().hoverEffect()
                }
            }
        .padding(.bottom, 8)
        .padding(.horizontal, 8)
    }
}

struct Room: Identifiable {
    var id: Int
    var title: String
    var sceneName: String
}


