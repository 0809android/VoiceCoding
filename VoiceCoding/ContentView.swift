import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var showingSettings = false
    @StateObject private var settings = Settings.shared
    @StateObject private var localization = LocalizationManager.shared
    @StateObject private var speechRecognizer = SpeechRecognizer()
    @StateObject private var terminalController = TerminalController()
    @StateObject private var voiceSettings = VoiceSettings()
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with Voice Settings Button
            HStack {
                Text(localization.localizedString("app_name"))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                // Settings Button
                Button(action: {
                    showingSettings.toggle()
                }) {
                    Image(systemName: "gearshape.fill")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .padding(8)
                        .background(Circle().fill(Color.secondary.opacity(0.1)))
                }
                .buttonStyle(PlainButtonStyle())
                .help(localization.localizedString("open_settings"))
                .keyboardShortcut(",", modifiers: .command)
            }
            .padding()
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(NSColor.windowBackgroundColor),
                        Color(NSColor.windowBackgroundColor).opacity(0.95)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            
            Divider()
            
            // Main Content Area
            HStack(spacing: 0) {
                // Left Panel - Voice Input
                VStack(spacing: 20) {
                    HStack {
                        Image(systemName: "mic.fill")
                            .font(.title3)
                            .foregroundColor(.accentColor)
                        Text(localization.localizedString("voice_input"))
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    
                    // Transcription Area
                    ScrollView {
                        Text(speechRecognizer.recognizedText.isEmpty ? localization.localizedString("start_speaking") : speechRecognizer.recognizedText)
                            .font(.system(size: CGFloat(settings.terminalFontSize), weight: .regular, design: .rounded))
                            .foregroundColor(speechRecognizer.recognizedText.isEmpty ? .secondary : .primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .animation(.easeInOut(duration: 0.2), value: speechRecognizer.recognizedText)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(NSColor.textBackgroundColor))
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.secondary.opacity(0.1), lineWidth: 1)
                    )
                    .padding(.horizontal)
                    
                    // Recording Button
                    Button(action: {
                        toggleRecording()
                    }) {
                        VStack(spacing: 8) {
                            Image(systemName: speechRecognizer.isRecording ? "mic.circle.fill" : "mic.circle")
                                .font(.system(size: 60))
                                .foregroundColor(speechRecognizer.isRecording ? .red : .accentColor)
                            
                            Text(localization.localizedString(speechRecognizer.isRecording ? "recording" : "start_recording"))
                                .font(.headline)
                                .fontWeight(.semibold)
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
                            HStack {
                                Image(systemName: "paperplane.fill")
                                    .font(.system(size: 16))
                                Text(localization.localizedString("send_to_claude"))
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.accentColor)
                                    .shadow(color: Color.accentColor.opacity(0.3), radius: 5, x: 0, y: 3)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
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
                            Text(localization.localizedString("debug_info"))
                                .font(.caption)
                                .fontWeight(.semibold)
                            Text("\(localization.localizedString("voice_info")): \(settings.selectedVoice.components(separatedBy: ".").last ?? "Unknown")")
                                .font(.caption2)
                            Text("\(localization.localizedString("auto_send_status")): \(localization.localizedString(settings.autoSendEnabled ? "on" : "off"))")
                                .font(.caption2)
                        }
                        .padding(10)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.secondary.opacity(0.1))
                        )
                        .padding(.horizontal)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                Divider()
                
                // Right Panel - Terminal Output
                VStack(spacing: 20) {
                    HStack {
                        Image(systemName: "terminal.fill")
                            .font(.title3)
                            .foregroundColor(.green)
                        Text(localization.localizedString("terminal_output"))
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    
                    // Processing indicator
                    if terminalController.isProcessing {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8)
                                .progressViewStyle(CircularProgressViewStyle())
                            Text(localization.localizedString("thinking"))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    }
                    
                    ScrollView {
                        Text(terminalController.output.isEmpty ? localization.localizedString("terminal_placeholder") : terminalController.output)
                            .font(.custom(settings.terminalFontFamily, size: CGFloat(settings.terminalFontSize)))
                            .foregroundColor(terminalController.output.isEmpty ? .secondary : .primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(NSColor.textBackgroundColor))
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.secondary.opacity(0.1), lineWidth: 1)
                    )
                    .padding(.horizontal)
                    .padding(.bottom)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .background(
                Color(NSColor.controlBackgroundColor)
                    .opacity(0.98)
            )
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