//
//  ConversationView.swift
//  VoiceAssistent
//
//  Created by Kishor L D on 22/02/24.
//

import SwiftUI
import SiriWaveView
import AVFoundation
struct ConversationView: View {
    @StateObject var hotelViewModel: HotelViewModel

    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    let synthesizer = AVSpeechSynthesizer()
    @State var vm = ViewModel()
    @State var isSymbolAnimating = false
    @State var isMapButtonShow = false
    @State var isConvoCompleted = false
    @State var isshowChatWindow = true
  
    
    var body: some View {
        GeometryReader3D { proxy3D in
            NavigationStack {
                NavigationLink {
                    MapView(hotelViewModel: hotelViewModel)
                } label: {
                    Text("goto..").opacity(isConvoCompleted ? 1 : 0).labelsHidden()
                }
                ZStack(alignment: .bottomTrailing) {
                    VStack {
                        ScrollView {
                            ForEach(Constants.messages) { message in
                                VStack() {
                                    if message.isUser {
                                        HStack {
                                            Spacer()
                                            MessageView(message: message)
                                                .frame(width: proxy3D.size.width/2)
                                        }.padding(.bottom, 30)
                                    } else {
                                        HStack {
                                            MessageView(message: message)
                                                .frame(width: proxy3D.size.width/2)
                                            Spacer()
                                        }.padding(.bottom, 30)
                                    }
                                }
                            }
                        }.frame(height: 700)
                            .padding(.bottom, 20)
                        
                        VStack(alignment: .trailing, spacing: 10) {
                            SiriWaveView()
                                .power(power: vm.audioPower)
                                .opacity(vm.siriWaveFormOpacity)
                                .frame(height: 256)
                                .overlay { overlayView }
                        }
                        startCaptureButton
                    }
                }.onAppear {
                    if isshowChatWindow {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            let utterance = AVSpeechUtterance(string:"Hi there, how can I assist You today?" )
                         
                            utterance.rate = 0.4
                            utterance.volume = 0.9
                            utterance.voice = AVSpeechSynthesisVoice(language: "en-au")
                            synthesizer.speak(utterance)
                            isshowChatWindow = false
                            vm.resetValues()
                        }
                    }
                }
                .onChange(of: vm.currentIndex) { newValue in
                   
                    if newValue >= Constants.botresponse.count {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            isMapButtonShow = true
                            isConvoCompleted = true
                        }
                    }
                }.padding(15)
            }
        }
    }
    
    
    @ViewBuilder
    var overlayView: some View {
        switch vm.state {
        case .idle, .error:
            
            HStack{
            }
        case .processingSpeech:
            Image(systemName: "brain")
                .symbolEffect(.bounce.up.byLayer, options: .repeating, value: isSymbolAnimating)
                .font(.system(size: 90))
                .onAppear { isSymbolAnimating = true }
                .onDisappear { isSymbolAnimating = false }
        default: EmptyView()
        }
    }
    var startCaptureButton: some View {
        Button {
            if vm.state == .recordingSpeech {
                vm.cancelRecording()
            } else if vm.state == .processingSpeech || vm.state == .playingSpeech {
                vm.startCaptureAudio()
            } else {
                vm.startCaptureAudio()
            }
        } label: {
            if vm.state == .recordingSpeech {
                Image("Siri")
                    .symbolRenderingMode(.multicolor)
                    .font(.system(size: 30))
            } else {
                Image("Siri")
                    .symbolRenderingMode(.multicolor)
                    .font(.system(size: 100))
                
            }
        }
        .buttonStyle(.plain)
        .frame(width: 30, height: 30)
    }
}






