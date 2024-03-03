//
//  ContentView.swift
//  HotelView
//
//  Created by Shamanth R on 23/02/24.
//
import SwiftUI
import RealityKit
import MapKit

struct HotelListView: View {
    @StateObject var viewModel: HotelViewModel
    @State private var showImmersiveSpace = false
    @State private var buttonTitle = "Navigate to HotelRoom"
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow

    @State var isLoading = true

    // Dictionary to map place names to background images
    let backgroundImages: [String: String] = [
        "The Peninsula  New York": "The Peninsula New York",
        "Conrad New York Downtown": "Conrad New York Downtown",
        "Gansevoort Meatpacking": "Gansevoort Meatpacking NYC",
        "The Marmara Park Avenue": "The Marmara Park Avenue"
        // Add more mappings as needed
    ]

    var body: some View {
        VStack {
            if !showImmersiveSpace {
                ScrollView(.horizontal) {
                    HStack(spacing: 20) {
                        ForEach(viewModel.placeInfoList, id: \.self) { placeInfo in
                            if let backgroundImageName = backgroundImages[placeInfo.name] {
                                Button(action: {
                                    viewModel.selectedPlaceInfo = placeInfo
                                    let camera = MapCamera(centerCoordinate: placeInfo.locationCoordinate, distance:  400, heading: 0, pitch: 60)
                                    showImmersiveSpace.toggle()
                                    isLoading = true
                                    
                                }) {
                                    VStack {
                                        Image(backgroundImageName)
                                            .resizable()
                                            .cornerRadius(50)
                                            .frame(width: 400, height: 250)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 50)
                                                    .inset(by: 2)
                                                    .stroke(.white, lineWidth: 1.5))
                                            .padding(.trailing,69)
                                            

                                        Text(placeInfo.name)
                                            .font(.largeTitle) // Changed to .title for readability
                                            .foregroundColor(.white)
                                            .fontWeight(.bold)
                                            .padding(.top, 10)
                                            .padding(.bottom, 30) // Adjusted bottom padding
                                    }
                                    
                                }
                                .buttonStyle(PlainButtonStyle()) // Remove button style
                            } else {
                                Text("No background image found for \(placeInfo.name)")
                                    .foregroundColor(.red)
                                    .padding()
                            }
                        }
                    }
                }
                .padding(.bottom, 20)
            }

            if showImmersiveSpace { 
                SuggestionsView()
                HStack {
                    
                    Toggle(isOn: $showImmersiveSpace) {
                        Text(showImmersiveSpace ? "Hide ImmersiveSpace" : "Show ImmersiveSpace").padding()
                    }
                    .toggleStyle(.button)
                    .padding()
                    if isLoading {
                        ProgressView("Loading...")
                            .progressViewStyle(CircularProgressViewStyle())
                            .padding()
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 5.9) {
                                    isLoading = false // Dismiss the loading indicator after 5 seconds
                                }
                            }
                    }
                    
                    Button {
                        Task {
                            // Perform task based on the current title
                            if buttonTitle == "Navigate to HotelRoom" {
                                // Perform task for the initial title
                                await dismissImmersiveSpace()
                                await openImmersiveSpace(id: "HotelImmersiveSpace")
                            } else if buttonTitle == "Navigate to StreetView" {
                                // Perform task for the new title
                                await dismissImmersiveSpace()
                                isLoading = true
                                await openImmersiveSpace(id: "ImmersiveSpace")
                            }
                            
                            // Change the title
                            buttonTitle = (buttonTitle == "Navigate to HotelRoom") ? "Navigate to StreetView" : "Navigate to HotelRoom"
                        }
                    } label: {
                        Text(buttonTitle).padding(16)
                        
                    }.buttonStyle(PlainButtonStyle()) // Use PlainButtonStyle
                        .background(Color.white)
                        .foregroundColor(Color.black)
                        .cornerRadius(40)
                        .padding()
                        
                    
                    
                }
            }
          
        }
        .onChange(of: showImmersiveSpace) { newValue in
            Task {
                if newValue {
                    await openImmersiveSpace(id: "ImmersiveSpace")
                } else {
                    await dismissImmersiveSpace()
                }
            }
        }
        .padding()
    }
}

struct HotelistImmersiveView: View {
    var viewModel: HotelViewModel
    var body: some View {
        ZStack {
            RealityView { content in
                content.add(viewModel.setupContentEntity())

            }
            .task {
                try? await viewModel.setSnapshot()
               
            }
        }
    }
}

// Previews
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HotelListView(viewModel: HotelViewModel())
    }
}