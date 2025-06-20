import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var showingSettings = false
    @StateObject private var settings = Settings.shared
    @StateObject private var localization = LocalizationManager.shared
    @StateObject private var speechRecognizer = SpeechRecognizer()
    @StateObject private var terminalController = TerminalController()
    @StateObject private var voiceSettings = VoiceSettings()
    @State private var voiceInputText = ""
    @State private var terminalText = ""
    @FocusState private var isVoiceInputFocused: Bool
    @FocusState private var isTerminalFocused: Bool
    
    var body: some View {
        ZStack {
            // Main Content Area
            HStack(spacing: 0) {
                // Left Panel - Voice Input
                VStack(spacing: 20) {
                    HStack {
                        Image(systemName: "mic.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.accentColor)
                        Text(localization.localizedString("voice_input"))
                            .font(.system(size: 14))
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    // Transcription Area
                    ZStack(alignment: .topLeading) {
                        if voiceInputText.isEmpty {
                            Text(localization.localizedString("start_speaking"))
                                .font(.system(size: CGFloat(settings.terminalFontSize), weight: .regular, design: .rounded))
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 12)
                                .allowsHitTesting(false)
                        }
                        
                        TextEditor(text: $voiceInputText)
                            .font(.system(size: CGFloat(settings.terminalFontSize), weight: .regular, design: .rounded))
                            .scrollContentBackground(.hidden)
                            .padding(8)
                            .focused($isVoiceInputFocused)
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
                    
                    // Recording Button with Space Key Hint
                    VStack(spacing: 8) {
                        Button(action: {
                            toggleRecording()
                        }) {
                            HStack(spacing: 8) {
                                if terminalController.isSpeaking {
                                    Image(systemName: "speaker.wave.3.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(.orange)
                                } else {
                                    Image(systemName: speechRecognizer.isRecording ? "mic.circle.fill" : "mic.circle")
                                        .font(.system(size: 20))
                                        .foregroundColor(speechRecognizer.isRecording ? .red : .accentColor)
                                }
                                
                                Text(localization.localizedString(terminalController.isSpeaking ? "speaking" : (speechRecognizer.isRecording ? "recording" : "start_recording")))
                                    .font(.system(size: 14))
                                    .fontWeight(.medium)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(speechRecognizer.isRecording ? Color.red.opacity(0.1) : Color.accentColor.opacity(0.1))
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Space key hint
                        Text("Space")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                            )
                    }
                    .padding(.bottom)
                    
                    // Manual Send Button (when auto-send is off)
                    if !settings.autoSendEnabled && !voiceInputText.isEmpty {
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
                            .font(.system(size: 14))
                            .foregroundColor(.green)
                        Text(localization.localizedString("terminal_output"))
                            .font(.system(size: 14))
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    ZStack(alignment: .topLeading) {
                        if terminalText.isEmpty {
                            Text(localization.localizedString("terminal_placeholder"))
                                .font(.custom(settings.terminalFontFamily, size: CGFloat(settings.terminalFontSize)))
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 12)
                                .allowsHitTesting(false)
                        }
                        
                        TextEditor(text: $terminalText)
                            .font(.custom(settings.terminalFontFamily, size: CGFloat(settings.terminalFontSize)))
                            .scrollContentBackground(.hidden)
                            .padding(8)
                            .focused($isTerminalFocused)
                        
                        // Processing indicator inside console
                        if terminalController.isProcessing {
                            VStack {
                                Spacer()
                                HStack(spacing: 4) {
                                    ProgressView()
                                        .scaleEffect(0.6)
                                        .progressViewStyle(CircularProgressViewStyle())
                                    Text(localization.localizedString("thinking"))
                                        .font(.custom(settings.terminalFontFamily, size: CGFloat(settings.terminalFontSize - 2)))
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                            }
                        }
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
            
            // Settings Button - Top Right
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        showingSettings.toggle()
                    }) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                            .padding(6)
                            .background(Circle().fill(Color.secondary.opacity(0.1)))
                    }
                    .buttonStyle(PlainButtonStyle())
                    .help(localization.localizedString("open_settings"))
                    .keyboardShortcut(",", modifiers: .command)
                }
                .padding()
                Spacer()
            }
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
        .onChange(of: speechRecognizer.recognizedText) { newText in
            voiceInputText = newText
        }
        .onChange(of: terminalController.output) { newOutput in
            terminalText = newOutput
        }
        .onChange(of: terminalController.isSpeaking) { isSpeaking in
            if isSpeaking {
                // Pause recording when the app starts speaking
                if speechRecognizer.isRecording {
                    speechRecognizer.stopRecording()
                }
            } else {
                // Resume recording when the app stops speaking
                // Add a small delay to avoid immediate recording of the end of speech
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if !speechRecognizer.isRecording && !terminalController.isSpeaking {
                        Task {
                            await speechRecognizer.requestAuthorization()
                            speechRecognizer.startRecording()
                        }
                    }
                }
            }
        }
        .background(
            // Invisible view to handle keyboard events
            Color.clear
                .onAppear {
                    NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                        if event.keyCode == 49 { // Space key
                            if terminalController.isSpeaking {
                                terminalController.stopSpeaking()
                                return nil
                            } else if !isVoiceInputFocused && !isTerminalFocused {
                                toggleRecording()
                                return nil
                            }
                        }
                        return event
                    }
                }
        )
    }
    
    private func toggleRecording() {
        if settings.enableHapticFeedback {
            NSHapticFeedbackManager.defaultPerformer.perform(.generic, performanceTime: .now)
        }
        
        // If app is speaking, stop speaking
        if terminalController.isSpeaking {
            terminalController.stopSpeaking()
            return
        }
        
        // Otherwise toggle recording
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
        guard !voiceInputText.isEmpty else { return }
        
        Task {
            await terminalController.sendToClaude(voiceInputText)
            speechRecognizer.clearAndContinueRecording()
            voiceInputText = ""
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}