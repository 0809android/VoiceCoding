import Foundation
import AppKit
import AVFoundation

@MainActor
class TerminalController: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    @Published var output = ""
    @Published var isProcessing = false
    @Published var isSpeaking = false
    
    private var process: Process?
    private let speechSynthesizer = AVSpeechSynthesizer()
    var lastSpokenLength = 0
    var voiceSettings: VoiceSettings?
    
    override init() {
        super.init()
        speechSynthesizer.delegate = self
    }
    
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.isSpeaking = true
        }
    }
    
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.isSpeaking = false
        }
    }
    
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.isSpeaking = false
        }
    }
    
    func startClaudeCode() async {
        output = "Claude Code ready. Send your voice input!\n"
    }
    
    func sendToClaude(_ text: String) async {
        output += "\n>>> Sending to Claude: \(text)\n"
        // 送信前の出力長を記録（自分の音声は読み上げない）
        lastSpokenLength = output.count
        isProcessing = true
        
        await Task.detached {
            do {
                let task = Process()
                let outputPipe = Pipe()
                let inputPipe = Pipe()
                
                task.standardOutput = outputPipe
                task.standardError = outputPipe
                task.standardInput = inputPipe
                
                task.executableURL = URL(fileURLWithPath: "/bin/bash")
                
                // Get initial directory from settings
                let settings = Settings.shared
                let initialDir = settings.initialDirectory.isEmpty ? NSHomeDirectory() : settings.initialDirectory
                
                // Change to initial directory before running claude
                task.arguments = ["-c", "cd '\(initialDir)' && echo '\(text.replacingOccurrences(of: "'", with: "'\"'\"'"))' | /Users/kinocode/.npm-global/bin/claude --print"]
                
                task.environment = ProcessInfo.processInfo.environment
                task.environment?["PATH"] = "/Users/kinocode/.npm-global/bin:/usr/local/bin:/usr/bin:/bin"
                
                // リアルタイムでの出力読み取り
                outputPipe.fileHandleForReading.readabilityHandler = { handle in
                    let data = handle.availableData
                    if !data.isEmpty, let string = String(data: data, encoding: .utf8) {
                        Task { @MainActor in
                            self.output += string
                            self.speakNewContent()
                        }
                    }
                }
                
                try task.run()
                task.waitUntilExit()
                
                // ハンドラーをクリーンアップ
                outputPipe.fileHandleForReading.readabilityHandler = nil
                
                Task { @MainActor in
                    self.isProcessing = false
                }
                
            } catch {
                Task { @MainActor in
                    self.output += "Error: \(error.localizedDescription)\n"
                    self.isProcessing = false
                }
            }
        }.value
    }
    
    private func speakNewContent() {
        // 新しく追加されたテキストのみを取得
        guard output.count > lastSpokenLength else { return }
        
        let startIndex = output.index(output.startIndex, offsetBy: lastSpokenLength)
        let newText = String(output[startIndex...])
        
        // ">>> Sending to Claude:" 行はスキップ
        let linesToSpeak = newText
            .components(separatedBy: .newlines)
            .filter { line in
                !line.isEmpty && 
                !line.contains(">>> Sending to Claude:") &&
                !line.contains("Claude Code ready.")
            }
            .joined(separator: " ")
        
        if !linesToSpeak.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            speak(linesToSpeak)
        }
        
        lastSpokenLength = output.count
    }
    
    private func speak(_ text: String) {
        // Ensure isSpeaking is set immediately to prevent race conditions
        isSpeaking = true
        
        // 音声合成の設定
        let utterance = AVSpeechUtterance(string: text)
        
        // Use voice settings if available
        if let settings = voiceSettings {
            if !settings.selectedVoiceIdentifier.isEmpty {
                utterance.voice = AVSpeechSynthesisVoice(identifier: settings.selectedVoiceIdentifier)
            }
            utterance.rate = settings.speechRate
            utterance.pitchMultiplier = settings.pitchMultiplier
            utterance.volume = settings.volume
        } else {
            // Default settings
            utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
            utterance.rate = 0.5
            utterance.pitchMultiplier = 1.0
            utterance.volume = 0.8
        }
        
        // 既存の読み上げを停止
        if speechSynthesizer.isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
        }
        
        // Small delay to ensure audio system is ready
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.speechSynthesizer.speak(utterance)
        }
    }
    
    func stopSpeaking() {
        speechSynthesizer.stopSpeaking(at: .immediate)
        isSpeaking = false
    }
    
    deinit {
        process?.terminate()
        speechSynthesizer.stopSpeaking(at: .immediate)
    }
}