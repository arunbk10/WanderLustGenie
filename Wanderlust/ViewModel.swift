//
//  ViewModel.swift
//  VoiceAssistent
//
//  Created by Kishor L D on 22/02/24.
//

import Foundation
import AVFoundation
import Observation
import XCAOpenAIClient

struct ChatMessage:  Identifiable  {
    var id: UUID
    let text: String
    let isUser: Bool
}

@Observable
class ViewModel: NSObject, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
     var currentIndex = 0
    var botresponse: [ChatMessage] = [.init(id: UUID(), text: "Sounds exciting! Would you prefer a beach destination, a mountain retreat, or a city escape?", isUser: false)
                                   ,.init(id: UUID(), text: "sure.... . select the option below ", isUser: false)]
     var messages: [ChatMessage] = [.init(id: UUID(), text: "Good morning! How can I assist you today? ", isUser: false)]
    var finalResponses : [ChatMessage] = []
    
    let client = OpenAIClient(apiKey: "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")
    var audioPlayer: AVAudioPlayer!
    var audioRecorder: AVAudioRecorder!
    let voiceType: VoiceType = .alloy
    let synthesizer = AVSpeechSynthesizer()

    #if !os(macOS)
    var recordingSession = AVAudioSession.sharedInstance()
    #endif
    var animationTimer: Timer?
    var recordingTimer: Timer?
    var audioPower = 0.0
    var prevAudioPower: Double?
    var processingSpeechTask: Task<Void, Never>?
    
    var selectedVoice = VoiceType.alloy
    
    var captureURL: URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
            .first!.appendingPathComponent("recording.m4a")
    }
    
    var state = VoiceChatState.idle {
        didSet { print(state) }
    }
    var isIdle: Bool {
        if case .idle = state {
            return true
        }
        return false
    }
    
    var siriWaveFormOpacity: CGFloat {
        switch state {
        case .recordingSpeech, .playingSpeech: return 1
        default: return 0
        }
    }
    
    override init() {
        super.init()
        #if !os(macOS)
        do {
            #if os(iOS)
            try recordingSession.setCategory(.playAndRecord, options: .defaultToSpeaker)
            #else
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            #endif
            try recordingSession.setActive(true)
            
            AVAudioApplication.requestRecordPermission { [unowned self] allowed in
                if !allowed {
                    self.state = .error("Recording not allowed by the user")
                }
            }
        } catch {
            state = .error(error)
        }
        #endif
    }
    
    func startCaptureAudio() {
        resetValues()
        state = .recordingSpeech
        do {
            audioRecorder = try AVAudioRecorder(url: captureURL,
                                                settings: [
                                                    AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                                                    AVSampleRateKey: 12000,
                                                    AVNumberOfChannelsKey: 1,
                                                    AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
                                                ])
            audioRecorder.isMeteringEnabled = true
            audioRecorder.delegate = self
            audioRecorder.record()
            
            animationTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true, block: { [unowned self]_ in
                guard self.audioRecorder != nil else { return }
                self.audioRecorder.updateMeters()
                let power = min(1, max(0, 1 - abs(Double(self.audioRecorder.averagePower(forChannel: 0)) / 50) ))
                self.audioPower = power
            })
            
            recordingTimer = Timer.scheduledTimer(withTimeInterval: 1.6, repeats: true, block: { [unowned self]_ in
                guard self.audioRecorder != nil else { return }
                self.audioRecorder.updateMeters()
                let power = min(1, max(0, 1 - abs(Double(self.audioRecorder.averagePower(forChannel: 0)) / 50) ))
                if self.prevAudioPower == nil {
                    self.prevAudioPower = power
                    return
                }
                if let prevAudioPower = self.prevAudioPower, prevAudioPower < 0.25 && power < 0.175 {
                    self.finishCaptureAudio()
                    return
                }
                self.prevAudioPower = power
            })
            
        } catch {
            resetValues()
            state = .error(error)
        }
    }
    
    func finishCaptureAudio() {
        resetValues()
        do {
            let data = try Data(contentsOf: captureURL)
            processingSpeechTask = processSpeechTask(audioData: data)
        } catch {
            state = .error(error)
            resetValues()
        }
    }
    
    func processSpeechTask(audioData: Data) -> Task<Void, Never> {
        Task { @MainActor [unowned self] in
            do {
                self.state = .processingSpeech
                let prompt = try await client.generateAudioTransciptions(audioData: audioData)
                messages.append(ChatMessage(id: UUID(), text: prompt, isUser: true))
                try Task.checkCancellation()
               
                if currentIndex < botresponse.count {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        do {
                            try self.playAudio(data: self.botresponse[self.currentIndex].text)
                            self.messages.append(ChatMessage(id: UUID(), text: self.botresponse[self.currentIndex].text, isUser: false))
                            self.currentIndex += 1
                        } catch {
                            print("Error playing audio: \(error)")
                            // Handle the error as needed, e.g., show an alert to the user
                        }
                    }
                }

            } catch {
                if Task.isCancelled { return }
                state = .error(error)
                resetValues()
            }
        }
    }

    func playAudio(data: String) throws {
        print(data)
        self.state = .playingSpeech
        audioPlayer = try AVAudioPlayer()
        let utterance = AVSpeechUtterance(string:data )
        
        utterance.rate = 0.4
        utterance.volume = 0.9
        utterance.voice = AVSpeechSynthesisVoice(language: "en-au")
        synthesizer.speak(utterance)
//        audioPlayer.isMeteringEnabled = true
//        audioPlayer.delegate = self
//        audioPlayer.play()
        
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true, block: { [unowned self]_ in
            guard self.audioPlayer != nil else { return }
            self.audioPlayer.updateMeters()
            let power = min(1, max(0, 1 - abs(Double(self.audioPlayer.averagePower(forChannel: 0)) / 160) ))
            self.audioPower = power
        })
    }
    
    func cancelRecording() {
        resetValues()
        state = .idle
    }
    
    func cancelProcessingTask() {
        processingSpeechTask?.cancel()
        processingSpeechTask = nil
        resetValues()
        state = .idle
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            resetValues()
            state = .idle
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        resetValues()
        state = .idle
    }
    
    func resetValues() {
        audioPower = 0
        prevAudioPower = nil
        audioRecorder?.stop()
        audioRecorder = nil
        audioPlayer?.stop()
        audioPlayer = nil
        recordingTimer?.invalidate()
        recordingTimer = nil
        animationTimer?.invalidate()
        animationTimer = nil
    }
    
}
