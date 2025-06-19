import SwiftUI

struct ContentView: View {
    @StateObject private var speechRecognizer = SpeechRecognizer()
    @StateObject private var terminalController = TerminalController()
    @State private var statusMessage = "準備完了"
    
    var body: some View {
        VStack(spacing: 20) {
            Text("音声入力 → Claude Code")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text(statusMessage)
                .font(.headline)
                .foregroundColor(.secondary)
            
            if !speechRecognizer.errorMessage.isEmpty {
                Text("Error: \(speechRecognizer.errorMessage)")
                    .font(.caption)
                    .foregroundColor(.red)
            }
            
            Text(speechRecognizer.recognizedText)
                .frame(maxWidth: .infinity, minHeight: 100)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            
            HStack(spacing: 20) {
                Button(action: toggleRecording) {
                    Image(systemName: speechRecognizer.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .foregroundColor(speechRecognizer.isRecording ? .red : .blue)
                }
                .help(speechRecognizer.isRecording ? "停止して送信" : "録音開始")
                
                Text("2秒の無音で自動送信")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Terminal Output:")
                    .font(.headline)
                
                ScrollView {
                    Text(terminalController.output)
                        .font(.system(.body, design: .monospaced))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(height: 150)
                .padding()
                .background(Color.black.opacity(0.9))
                .foregroundColor(.green)
                .cornerRadius(8)
            }
        }
        .padding()
        .frame(width: 600, height: 500)
        .onAppear {
            Task {
                await speechRecognizer.requestAuthorization()
                await terminalController.startClaudeCode()
            }
            
            // 無音検出時の自動送信設定
            speechRecognizer.onSilenceDetected = {
                guard !speechRecognizer.recognizedText.isEmpty else { return }
                sendToClaudeWithoutStopping()
            }
        }
    }
    
    private func toggleRecording() {
        if speechRecognizer.isRecording {
            speechRecognizer.stopRecording()
            statusMessage = "録音停止"
            // 録音停止時に自動送信
            if !speechRecognizer.recognizedText.isEmpty {
                sendToClaude()
            }
        } else {
            speechRecognizer.startRecording()
            statusMessage = "録音中..."
        }
    }
    
    private func sendToClaude() {
        Task {
            statusMessage = "送信中..."
            let textToSend = speechRecognizer.recognizedText
            speechRecognizer.recognizedText = ""
            await terminalController.sendToClaude(textToSend)
            statusMessage = "送信完了"
        }
    }
    
    private func sendToClaudeWithoutStopping() {
        Task {
            statusMessage = "送信中..."
            let textToSend = speechRecognizer.recognizedText
            speechRecognizer.clearAndContinueRecording()
            await terminalController.sendToClaude(textToSend)
            statusMessage = "録音継続中..."
        }
    }
}