import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var showingSettings = false
    @StateObject private var settings = Settings.shared
    @StateObject private var speechRecognizer = SpeechRecognizer()
    @StateObject private var terminalController = TerminalController()
    @StateObject private var voiceSettings = VoiceSettings()
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with Voice Settings Button
            HStack {
                Text("VoiceCoding")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                // Settings Button
                Button(action: {
                    showingSettings.toggle()
                }) {
                    Image(systemName: "gearshape.fill")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(PlainButtonStyle())
                .help("Open Settings")
                .keyboardShortcut(",", modifiers: .command)
            }
            .padding()
            .background(Color(NSColor.windowBackgroundColor))
            
            Divider()
            
            // Main Content Area
            HStack(spacing: 0) {
                // Left Panel - Voice Input
                VStack(spacing: 20) {
                    Text("Voice Input")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    
                    // Transcription Area
                    ScrollView {
                        Text(speechRecognizer.recognizedText.isEmpty ? "Start speaking to see transcription..." : speechRecognizer.recognizedText)
                            .font(.system(size: CGFloat(settings.terminalFontSize)))
                            .foregroundColor(speechRecognizer.recognizedText.isEmpty ? .secondary : .primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(NSColor.textBackgroundColor))
                    .cornerRadius(8)
                    .padding(.horizontal)
                    
                    // Recording Button
                    Button(action: {
                        toggleRecording()
                    }) {
                        VStack(spacing: 8) {
                            Image(systemName: speechRecognizer.isRecording ? "mic.circle.fill" : "mic.circle")
                                .font(.system(size: 60))
                                .foregroundColor(speechRecognizer.isRecording ? .red : .accentColor)
                            
                            Text(speechRecognizer.isRecording ? "Recording..." : "Start Recording")
                                .font(.headline)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .scaleEffect(speechRecognizer.isRecording ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: speechRecognizer.isRecording)
                    .padding(.bottom)
                    .keyboardShortcut(.space, modifiers: [])
                    
                    // Manual Send Button (when auto-send is off)
                    if !settings.autoSendEnabled && !speechRecognizer.recognizedText.isEmpty {
                        Button(action: sendToTerminal) {
                            Label("Send to Claude", systemImage: "paperplane.fill")
                                .font(.headline)
                        }
                        .buttonStyle(.borderedProminent)
                        .keyboardShortcut(.return, modifiers: [])
                        .padding(.bottom)
                    }
                    
                    // Error message
                    if !speechRecognizer.errorMessage.isEmpty {
                        Text(speechRecognizer.errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.horizontal)
                    }
                    
                    // Debug Info
                    if settings.showDebugInfo {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Debug Info")
                                .font(.caption)
                                .fontWeight(.semibold)
                            Text("Voice: \(settings.selectedVoice.components(separatedBy: ".").last ?? "Unknown")")
                                .font(.caption2)
                            Text("Auto-send: \(settings.autoSendEnabled ? "On" : "Off")")
                                .font(.caption2)
                        }
                        .padding(8)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(6)
                        .padding(.horizontal)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                Divider()
                
                // Right Panel - Terminal Output
                VStack(spacing: 20) {
                    Text("Terminal Output")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    
                    ScrollView {
                        Text(terminalController.output.isEmpty ? "Terminal output will appear here..." : terminalController.output)
                            .font(.custom(settings.terminalFontFamily, size: CGFloat(settings.terminalFontSize)))
                            .foregroundColor(terminalController.output.isEmpty ? .secondary : .primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(NSColor.textBackgroundColor))
                    .cornerRadius(8)
                    .padding(.horizontal)
                    .padding(.bottom)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .background(Color(NSColor.controlBackgroundColor))
        }
        .frame(minWidth: 900, minHeight: 600)
        .preferredColorScheme(settings.currentColorScheme)
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .onAppear {
            // Set up voice settings for terminal controller
            terminalController.voiceSettings = voiceSettings
            
            // Set up auto-send callback
            speechRecognizer.onSilenceDetected = {
                if settings.autoSendEnabled {
                    sendToTerminal()
                }
            }
            
            // Start Claude Code
            Task {
                await terminalController.startClaudeCode()
            }
        }
    }
    
    private func toggleRecording() {
        if settings.enableHapticFeedback {
            NSHapticFeedbackManager.defaultPerformer.perform(.generic, performanceTime: .now)
        }
        
        if speechRecognizer.isRecording {
            speechRecognizer.stopRecording()
        } else {
            Task {
                await speechRecognizer.requestAuthorization()
                speechRecognizer.startRecording()
            }
        }
    }
    
    private func sendToTerminal() {
        guard !speechRecognizer.recognizedText.isEmpty else { return }
        
        Task {
            await terminalController.sendToClaude(speechRecognizer.recognizedText)
            speechRecognizer.clearAndContinueRecording()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}