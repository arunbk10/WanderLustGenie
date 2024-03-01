//
//  ContentView.swift
//  Recommendation
//
//  Created by Shamanth R on 01/03/24.
//
import SwiftUI

struct SuggestionsView: View {
    @State private var isShowingPopup = false
    @State private var buttonFrame: CGRect = .zero
    @State private var isButtonVisible = true

    var body: some View {
        ZStack {
            VStack {
                Spacer()
                
                if isButtonVisible {
                    Button(action: {
                        withAnimation {
                            isShowingPopup.toggle()
                        }
                        isButtonVisible = false
                    }, label: {
                        Text("See Recommendations")
                            .foregroundColor(.black)
                            .background(Color.clear)
                            .padding()
                            
                            .shadow(color: .gray, radius: 3, x: 2, y: 2)
                    })
                    .background(Color.white)
                    .cornerRadius(25)
                    .padding()

                }

                Spacer()
            }

            if isShowingPopup {
                RecommendationsPopupView(buttonFrame: buttonFrame, isShowingPopup: $isShowingPopup, isButtonVisible: $isButtonVisible)
                    .transition(.move(edge: .leading)) // Add transition for smoother appearance
            }
        }
        .frame(minWidth: 600, idealWidth: 800, maxWidth: .infinity, minHeight: 300, idealHeight: 400, maxHeight: .infinity)
    }
}

struct RecommendationsPopupView: View {
    var buttonFrame: CGRect
    @Binding var isShowingPopup: Bool
    @Binding var isButtonVisible: Bool

    var body: some View {
        ZStack {
            Color.clear // Set the background color to clear
            
            VStack {
                Text("📍Discovering Surroundings: Peninsula Hotel's Nearby Attractions")
                    .padding(.leading,20)
                    .padding(.trailing,20)
                    .padding(.top,10)
                    .padding(.bottom,10)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.black).opacity(0.9)
//                    .background(Color(.black).opacity(0.35))
//                    .cornerRadius(15)

                ScrollView(.horizontal, showsIndicators: true) {
                    HStack(spacing: 20) {
                        ForEach(recommendations) { recommendation in
                            VStack {
                                Image(recommendation.imageName)
                                    .resizable()
                                    .frame(width: 200, height: 150)
                                    .cornerRadius(30)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 30)
                                            .inset(by: 0.1)
                                            .stroke(.white, lineWidth: 1)
                                    )
                                    

                                Text(recommendation.title)
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.black)
                                    .multilineTextAlignment(.center)
                                   

                                Text(recommendation.description)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.black)
                                    .multilineTextAlignment(.center)
                                    .frame(width: 200, height: 100, alignment: .center)
                                 
                            }
                           
                        }
                    }
                    .padding(.bottom, 8)
                    .padding(.horizontal, 8)
                }.padding(.top,10)

                
                Button(action: {
                    withAnimation {
                        isShowingPopup.toggle()
                    }
                    isButtonVisible = true
                }, label: {
                    Text("Close")
                        .foregroundColor(.black)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 20)
                        .background(Color .clear)
                        .cornerRadius(10)
                })
                .background(Color.white)
                .cornerRadius(25)
                .padding(.bottom)
            }
            .padding(.leading,40)
            .frame(width: 1020, height: 500)
            .background(Color(red: 255/255, green: 255/255, blue: 255/255).opacity(0.35)) // Added background color for the content area
//            .cornerRadius(20)
            .shadow(radius: 5)
//            .position(x: buttonFrame.midX, y: buttonFrame.minY - 220)
        }
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        SuggestionsView()
//    }
//}

struct Recommendation: Identifiable {
    var id = UUID()
    var imageName: String
    var title: String
    var description: String
}


let recommendations: [Recommendation] = [
    Recommendation(imageName: "fifth-avenue", title: "5th Avenue - 1 min walk", description: "Fifth Avenue is a 6.2-mile (10 km) long street in New York City's Manhattan borough. It runs from Washington Square Park in Greenwich Village to West 143rd Street in Harlem."),
    Recommendation(imageName: "RockefellerCenter", title: "Rockefeller Center - 8 min walk", description: "Rockefeller Center is the symbol of midtown Manhattan and easily one of the best and most widely popular attractions in New York City. A complex of 19 buildings and plazas, located btwn 5th and 7th Avenues."),
    Recommendation(imageName: "RadioCity", title: "Radio City Music Hall - 8 min walk", description: "Radio City Music Hall is the largest indoor theatre in the world. Its marquee is a full city-block long. Its auditorium measures 160 feet from back to stage and the ceiling reaches a height of 84 feet."),
    Recommendation(imageName: "times_square", title: "Times Square - 14 min walk", description: "Times Square offers a wide range of things to see, do, eat, and shop. You can enjoy street performances, explore museums and galleries, as well as catch award-winning Broadway shows.")
]
