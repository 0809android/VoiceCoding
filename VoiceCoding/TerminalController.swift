import Foundation
import AppKit
import AVFoundation

@MainActor
class TerminalController: ObservableObject {
    @Published var output = ""
    @Published var isProcessing = false
    
    private var process: Process?
    private let speechSynthesizer = AVSpeechSynthesizer()
    var lastSpokenLength = 0
    var voiceSettings: VoiceSettings?
    
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
                task.arguments = ["-c", "echo '\(text.replacingOccurrences(of: "'", with: "'\"'\"'"))' | /Users/kinocode/.npm-global/bin/claude --print"]
                
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
        
        speechSynthesizer.speak(utterance)
    }
    
    func stopSpeaking() {
        if speechSynthesizer.isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
        }
    }
    
    deinit {
        process?.terminate()
        speechSynthesizer.stopSpeaking(at: .immediate)
    }
}