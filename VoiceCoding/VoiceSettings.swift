import Foundation
import AVFoundation

@MainActor
class VoiceSettings: ObservableObject {
    @Published var selectedVoiceIdentifier: String = AVSpeechSynthesisVoice(language: "ja-JP")?.identifier ?? ""
    @Published var speechRate: Float = 0.5
    @Published var volume: Float = 0.8
    @Published var pitchMultiplier: Float = 1.0
    
    var availableVoices: [AVSpeechSynthesisVoice] {
        AVSpeechSynthesisVoice.speechVoices().filter { $0.language.hasPrefix("ja") }
    }
    
    func voiceName(for identifier: String) -> String {
        guard let voice = AVSpeechSynthesisVoice(identifier: identifier) else { return "デフォルト" }
        let name = voice.name
        let gender = voice.gender == .male ? "男性" : "女性"
        return "\(name) (\(gender))"
    }
}