//
//  ContentView.swift
//  VoiceAssistent
//
//  Created by Kishor L D on 22/02/24.
//

import SwiftUI
import SiriWaveView
import AVFoundation
struct ConversationView: View {
    let synthesizer = AVSpeechSynthesizer()
    @State var vm = ViewModel()
    @State var isSymbolAnimating = false
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack {
                ScrollView {
                    ForEach(vm.messages) { message in
                        VStack() {
                            if message.isUser {
                                HStack {
                                    Spacer()
                                    MessageView(message: message)
                                        .frame(width: 621)
                                }.padding(.bottom, 30)
                            } else {
                                HStack {
                                    MessageView(message: message)
                                        .frame(width: 621)
                                    Spacer()
                                }.padding(.bottom, 30)
                            }
                        }
                    }
                }
                VStack(alignment: .trailing, spacing: 10) {
                    SiriWaveView()
                        .power(power: vm.audioPower)
                        .opacity(vm.siriWaveFormOpacity)
                        .frame(height: 256)
                        .overlay { overlayView }
                }
            }
            startCaptureButton // Place the startCaptureButton outside VStack
                 // Add padding to maintain 10 points distance from the trailing edge
        }.onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                let utterance = AVSpeechUtterance(string:"good morning! how can I assist You today?" )
                
                utterance.rate = 0.4
                utterance.volume = 0.9
                utterance.voice = AVSpeechSynthesisVoice(language: "en-au")
                synthesizer.speak(utterance)
            }
        }
    }
        
    
    @ViewBuilder
    var overlayView: some View {
        switch vm.state {
        case .idle, .error:
            
            HStack{
//                startCaptureButton
//                    .frame(alignment:.trailing)
            }
        case .processingSpeech:
            Image(systemName: "brain")
                .symbolEffect(.bounce.up.byLayer, options: .repeating, value: isSymbolAnimating)
                .font(.system(size: 128))
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
                    .font(.system(size: 44))
            
                    
//            } else if vm.state == .processingSpeech || vm.state == .playingSpeech {
//                Image("Siri")
//                    .symbolRenderingMode(.monochrome)
//                    .foregroundStyle(.red)
//                    .font(.system(size: 44))
//
            } else {
                Image("Siri")
                    .symbolRenderingMode(.multicolor)
                    .font(.system(size: 128))
                   
            }
        }
        .buttonStyle(.borderless)
    }
}

#Preview("Idle") {
    ContentView()
}

#Preview("Recording Speech") {
    let vm = ViewModel()
    vm.state = .recordingSpeech
    vm.audioPower = 0.2
    return ConversationView(vm: vm)
}

#Preview("Processing Speech") {
    let vm = ViewModel()
    vm.state = .processingSpeech
    return ConversationView(vm: vm)
}

#Preview("Playing Speech") {
    let vm = ViewModel()
    vm.state = .playingSpeech
    vm.audioPower = 0.3
    return ConversationView(vm: vm)
}

#Preview("Error") {
    let vm = ViewModel()
    vm.state = .error("An error has occured")
    return ConversationView(vm: vm)
}




