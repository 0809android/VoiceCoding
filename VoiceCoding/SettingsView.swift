import SwiftUI
import AVFoundation

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var settings = Settings.shared
    @State private var selectedTab = "voice"
    @State private var showingResetAlert = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView
            
            Divider()
            
            // Tab Selection
            tabSelectionView
            
            Divider()
            
            // Content
            ScrollView {
                VStack(spacing: 20) {
                    switch selectedTab {
                    case "voice":
                        VoiceSettingsSection()
                    case "recording":
                        RecordingSettingsSection()
                    case "appearance":
                        AppearanceSettingsSection()
                    case "about":
                        AboutSection()
                    default:
                        EmptyView()
                    }
                }
                .padding()
            }
        }
        .frame(width: 700, height: 500)
        .background(Color(NSColor.windowBackgroundColor))
        .alert("Reset Settings", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                settings.resetToDefaults()
            }
        } message: {
            Text("Are you sure you want to reset all settings to their default values? This action cannot be undone.")
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        HStack {
            Text("Settings")
                .font(.title2)
                .fontWeight(.semibold)
            
            Spacer()
            
            HStack(spacing: 12) {
                Button("Reset to Defaults") {
                    showingResetAlert = true
                }
                .buttonStyle(BorderedButtonStyle())
                
                Button("Done") {
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding()
    }
    
    // MARK: - Tab Selection View
    private var tabSelectionView: some View {
        HStack(spacing: 0) {
            SettingsTab(
                title: "Voice",
                icon: "mic.fill",
                isSelected: selectedTab == "voice",
                action: { selectedTab = "voice" }
            )
            
            SettingsTab(
                title: "Recording",
                icon: "record.circle",
                isSelected: selectedTab == "recording",
                action: { selectedTab = "recording" }
            )
            
            SettingsTab(
                title: "Appearance",
                icon: "paintbrush.fill",
                isSelected: selectedTab == "appearance",
                action: { selectedTab = "appearance" }
            )
            
            SettingsTab(
                title: "About",
                icon: "info.circle.fill",
                isSelected: selectedTab == "about",
                action: { selectedTab = "about" }
            )
        }
        .padding(.horizontal)
    }
}

// MARK: - Settings Tab
struct SettingsTab: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
            .foregroundColor(isSelected ? .accentColor : .secondary)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Voice Settings Section
struct VoiceSettingsSection: View {
    @ObservedObject var settings = Settings.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            sectionHeader("Voice Settings")
            
            // Voice Selection
            settingRow("Voice") {
                Picker("", selection: $settings.selectedVoice) {
                    ForEach(settings.availableVoices, id: \.identifier) { voice in
                        Text(voiceDisplayName(voice))
                            .tag(voice.identifier)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .frame(width: 250)
            }
            
            // Voice Speed
            settingRow("Speed") {
                HStack {
                    Slider(value: $settings.voiceSpeed, in: 0.5...2.0)
                        .frame(width: 200)
                    Text(String(format: "%.1fx", settings.voiceSpeed))
                        .frame(width: 50, alignment: .trailing)
                        .foregroundColor(.secondary)
                }
            }
            
            // Voice Volume
            settingRow("Volume") {
                HStack {
                    Slider(value: $settings.voiceVolume, in: 0.0...1.0)
                        .frame(width: 200)
                    Text(String(format: "%.0f%%", settings.voiceVolume * 100))
                        .frame(width: 50, alignment: .trailing)
                        .foregroundColor(.secondary)
                }
            }
            
            // Voice Pitch
            settingRow("Pitch") {
                HStack {
                    Slider(value: $settings.voicePitch, in: 0.5...2.0)
                        .frame(width: 200)
                    Text(String(format: "%.1fx", settings.voicePitch))
                        .frame(width: 50, alignment: .trailing)
                        .foregroundColor(.secondary)
                }
            }
            
            // Test Voice Button
            HStack {
                Spacer()
                Button("Test Voice") {
                    testVoice()
                }
                .buttonStyle(BorderedButtonStyle())
            }
        }
    }
    
    private func voiceDisplayName(_ voice: AVSpeechSynthesisVoice) -> String {
        let language = Locale.current.localizedString(forLanguageCode: voice.language) ?? voice.language
        return "\(voice.name) (\(language))"
    }
    
    private func testVoice() {
        let synthesizer = AVSpeechSynthesizer()
        let utterance = AVSpeechUtterance(string: "Hello! This is a test of the selected voice settings.")
        
        if let voice = AVSpeechSynthesisVoice(identifier: settings.selectedVoice) {
            utterance.voice = voice
        }
        
        utterance.rate = Float(settings.voiceSpeed) * 0.5
        utterance.volume = Float(settings.voiceVolume)
        utterance.pitchMultiplier = Float(settings.voicePitch)
        
        synthesizer.speak(utterance)
    }
}

// MARK: - Recording Settings Section
struct RecordingSettingsSection: View {
    @ObservedObject var settings = Settings.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            sectionHeader("Recording Settings")
            
            // Silence Threshold
            settingRow("Silence Threshold") {
                HStack {
                    Slider(value: $settings.silenceThreshold, in: -60...0)
                        .frame(width: 200)
                    Text(String(format: "%.0f dB", settings.silenceThreshold))
                        .frame(width: 60, alignment: .trailing)
                        .foregroundColor(.secondary)
                }
            }
            
            // Auto Send
            settingRow("Auto-send") {
                Toggle("", isOn: $settings.autoSendEnabled)
                    .toggleStyle(SwitchToggleStyle())
            }
            
            // Auto Send Delay
            if settings.autoSendEnabled {
                settingRow("Auto-send Delay") {
                    HStack {
                        Slider(value: $settings.autoSendDelay, in: 0.5...5.0, step: 0.5)
                            .frame(width: 200)
                        Text(String(format: "%.1f sec", settings.autoSendDelay))
                            .frame(width: 60, alignment: .trailing)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Advanced Settings
            Divider()
                .padding(.vertical)
            
            sectionHeader("Advanced")
            
            settingRow("Show Debug Info") {
                Toggle("", isOn: $settings.showDebugInfo)
                    .toggleStyle(SwitchToggleStyle())
            }
            
            settingRow("Haptic Feedback") {
                Toggle("", isOn: $settings.enableHapticFeedback)
                    .toggleStyle(SwitchToggleStyle())
            }
        }
    }
}

// MARK: - Appearance Settings Section
struct AppearanceSettingsSection: View {
    @ObservedObject var settings = Settings.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            sectionHeader("Appearance Settings")
            
            // Theme Selection
            settingRow("Theme") {
                Picker("", selection: $settings.selectedTheme) {
                    Text("System").tag("system")
                    Text("Light").tag("light")
                    Text("Dark").tag("dark")
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(width: 250)
            }
            
            // Terminal Font Family
            settingRow("Terminal Font") {
                Picker("", selection: $settings.terminalFontFamily) {
                    ForEach(settings.fontFamilies, id: \.self) { font in
                        Text(font)
                            .font(.custom(font, size: 14))
                            .tag(font)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .frame(width: 250)
            }
            
            // Terminal Font Size
            settingRow("Font Size") {
                HStack {
                    Slider(value: $settings.terminalFontSize, in: 10...24, step: 1)
                        .frame(width: 200)
                    Text(String(format: "%.0f pt", settings.terminalFontSize))
                        .frame(width: 50, alignment: .trailing)
                        .foregroundColor(.secondary)
                }
            }
            
            // Preview
            Divider()
                .padding(.vertical)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Preview")
                    .font(.headline)
                
                Text("$ echo \"Hello, VoiceCoding!\"")
                    .font(.custom(settings.terminalFontFamily, size: CGFloat(settings.terminalFontSize)))
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(NSColor.textBackgroundColor))
                    .cornerRadius(8)
            }
        }
    }
}

// MARK: - About Section
struct AboutSection: View {
    @ObservedObject var settings = Settings.shared
    
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            // App Icon
            Image(systemName: "mic.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.accentColor)
            
            Text("VoiceCoding")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Version \(settings.appVersion) (Build \(settings.buildNumber))")
                .foregroundColor(.secondary)
            
            Divider()
                .frame(width: 200)
                .padding(.vertical)
            
            VStack(spacing: 16) {
                Link(destination: URL(string: settings.githubURL)!) {
                    HStack {
                        Image(systemName: "link")
                        Text("View on GitHub")
                    }
                }
                .buttonStyle(LinkButtonStyle())
                
                Link(destination: URL(string: "https://github.com/yourusername/VoiceCoding/issues")!) {
                    HStack {
                        Image(systemName: "exclamationmark.bubble")
                        Text("Report an Issue")
                    }
                }
                .buttonStyle(LinkButtonStyle())
                
                Link(destination: URL(string: "https://github.com/yourusername/VoiceCoding/blob/main/LICENSE")!) {
                    HStack {
                        Image(systemName: "doc.text")
                        Text("License")
                    }
                }
                .buttonStyle(LinkButtonStyle())
            }
            
            Spacer()
            
            Text("Made with ❤️ using SwiftUI")
                .foregroundColor(.secondary)
                .font(.caption)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Helper Views
private func sectionHeader(_ title: String) -> some View {
    Text(title)
        .font(.headline)
        .foregroundColor(.primary)
}

private func settingRow<Content: View>(_ label: String, @ViewBuilder content: () -> Content) -> some View {
    HStack {
        Text(label)
            .frame(width: 150, alignment: .trailing)
            .foregroundColor(.secondary)
        
        content()
        
        Spacer()
    }
}

// MARK: - Custom Button Style
struct LinkButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.accentColor)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.accentColor.opacity(configuration.isPressed ? 0.2 : 0.1))
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

// MARK: - Preview
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}