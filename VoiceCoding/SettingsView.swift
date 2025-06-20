import SwiftUI
import AVFoundation

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var settings = Settings.shared
    @ObservedObject var localization = LocalizationManager.shared
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
                    case "language":
                        LanguageSettingsSection()
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
        .alert(localization.localizedString("reset_settings"), isPresented: $showingResetAlert) {
            Button(localization.localizedString("cancel"), role: .cancel) { }
            Button(localization.localizedString("reset"), role: .destructive) {
                settings.resetToDefaults()
            }
        } message: {
            Text(localization.localizedString("reset_settings_message"))
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        HStack {
            Text(localization.localizedString("settings"))
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Spacer()
            
            HStack(spacing: 12) {
                Button(action: {
                    showingResetAlert = true
                }) {
                    Text(localization.localizedString("reset_to_defaults"))
                        .fontWeight(.medium)
                }
                .buttonStyle(BorderedButtonStyle())
                
                Button(action: {
                    dismiss()
                }) {
                    Text(localization.localizedString("done"))
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.accentColor)
                        )
                }
                .buttonStyle(PlainButtonStyle())
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding()
    }
    
    // MARK: - Tab Selection View
    private var tabSelectionView: some View {
        HStack(spacing: 0) {
            SettingsTab(
                title: localization.localizedString("voice"),
                icon: "mic.fill",
                isSelected: selectedTab == "voice",
                action: { selectedTab = "voice" }
            )
            
            SettingsTab(
                title: localization.localizedString("recording_settings"),
                icon: "record.circle",
                isSelected: selectedTab == "recording",
                action: { selectedTab = "recording" }
            )
            
            SettingsTab(
                title: localization.localizedString("appearance"),
                icon: "paintbrush.fill",
                isSelected: selectedTab == "appearance",
                action: { selectedTab = "appearance" }
            )
            
            SettingsTab(
                title: localization.localizedString("language"),
                icon: "globe",
                isSelected: selectedTab == "language",
                action: { selectedTab = "language" }
            )
            
            SettingsTab(
                title: localization.localizedString("about"),
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
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.accentColor.opacity(0.15) : Color.clear)
            )
            .foregroundColor(isSelected ? .accentColor : .secondary)
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Voice Settings Section
struct VoiceSettingsSection: View {
    @ObservedObject var settings = Settings.shared
    @ObservedObject var localization = LocalizationManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            sectionHeader(localization.localizedString("voice_settings"))
            
            // Voice Selection
            settingRow(localization.localizedString("voice_selection")) {
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
            settingRow(localization.localizedString("speed")) {
                HStack {
                    Slider(value: $settings.voiceSpeed, in: 0.5...2.0)
                        .frame(width: 200)
                    Text(String(format: "%.1fx", settings.voiceSpeed))
                        .frame(width: 50, alignment: .trailing)
                        .foregroundColor(.secondary)
                }
            }
            
            // Voice Volume
            settingRow(localization.localizedString("volume")) {
                HStack {
                    Slider(value: $settings.voiceVolume, in: 0.0...1.0)
                        .frame(width: 200)
                    Text(String(format: "%.0f%%", settings.voiceVolume * 100))
                        .frame(width: 50, alignment: .trailing)
                        .foregroundColor(.secondary)
                }
            }
            
            // Voice Pitch
            settingRow(localization.localizedString("pitch")) {
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
                Button(action: {
                    testVoice()
                }) {
                    HStack {
                        Image(systemName: "speaker.wave.3.fill")
                        Text(localization.localizedString("test_voice"))
                    }
                    .fontWeight(.medium)
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
    @ObservedObject var localization = LocalizationManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            sectionHeader(localization.localizedString("recording_settings_title"))
            
            // Silence Threshold
            settingRow(localization.localizedString("silence_threshold")) {
                HStack {
                    Slider(value: $settings.silenceThreshold, in: -60...0)
                        .frame(width: 200)
                    Text(String(format: "%.0f dB", settings.silenceThreshold))
                        .frame(width: 60, alignment: .trailing)
                        .foregroundColor(.secondary)
                }
            }
            
            // Auto Send
            settingRow(localization.localizedString("auto_send")) {
                Toggle("", isOn: $settings.autoSendEnabled)
                    .toggleStyle(SwitchToggleStyle())
            }
            
            // Auto Send Delay
            if settings.autoSendEnabled {
                settingRow(localization.localizedString("auto_send_delay")) {
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
            
            sectionHeader(localization.localizedString("advanced"))
            
            settingRow(localization.localizedString("show_debug_info")) {
                Toggle("", isOn: $settings.showDebugInfo)
                    .toggleStyle(SwitchToggleStyle())
            }
            
            settingRow(localization.localizedString("haptic_feedback")) {
                Toggle("", isOn: $settings.enableHapticFeedback)
                    .toggleStyle(SwitchToggleStyle())
            }
            
            settingRow(localization.localizedString("initial_directory")) {
                HStack {
                    TextField(localization.localizedString("initial_directory_placeholder"), text: $settings.initialDirectory)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 250)
                    
                    Button(action: selectDirectory) {
                        Image(systemName: "folder")
                    }
                    .buttonStyle(BorderedButtonStyle())
                }
            }
        }
    }
    
    private func selectDirectory() {
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        openPanel.allowsMultipleSelection = false
        openPanel.title = localization.localizedString("select_initial_directory")
        
        if openPanel.runModal() == .OK {
            if let url = openPanel.url {
                settings.initialDirectory = url.path
            }
        }
    }
}

// MARK: - Appearance Settings Section
struct AppearanceSettingsSection: View {
    @ObservedObject var settings = Settings.shared
    @ObservedObject var localization = LocalizationManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            sectionHeader(localization.localizedString("appearance_settings"))
            
            // Theme Selection
            settingRow(localization.localizedString("theme")) {
                Picker("", selection: $settings.selectedTheme) {
                    Text(localization.localizedString("system")).tag("system")
                    Text(localization.localizedString("light")).tag("light")
                    Text(localization.localizedString("dark")).tag("dark")
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(width: 250)
            }
            
            // Terminal Font Family
            settingRow(localization.localizedString("terminal_font")) {
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
            settingRow(localization.localizedString("font_size")) {
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
                Text(localization.localizedString("preview"))
                    .font(.headline)
                    .fontWeight(.semibold)
                
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

// MARK: - Language Settings Section
struct LanguageSettingsSection: View {
    @ObservedObject var settings = Settings.shared
    @ObservedObject var localization = LocalizationManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            sectionHeader(localization.localizedString("language_settings"))
            
            settingRow(localization.localizedString("select_language")) {
                Picker("", selection: $localization.currentLanguage) {
                    ForEach(localization.supportedLanguages, id: \.0) { language in
                        Text(language.1)
                            .tag(language.0)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .frame(width: 250)
            }
            
            // Language preview
            VStack(alignment: .leading, spacing: 8) {
                Text(localization.localizedString("preview"))
                    .font(.headline)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(localization.localizedString("app_name"))
                        .font(.title3)
                        .fontWeight(.bold)
                    Text(localization.localizedString("start_speaking"))
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(NSColor.textBackgroundColor))
                )
            }
        }
    }
}

// MARK: - About Section
struct AboutSection: View {
    @ObservedObject var settings = Settings.shared
    @ObservedObject var localization = LocalizationManager.shared
    
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            // App Icon
            Image(systemName: "mic.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.accentColor)
            
            Text(localization.localizedString("app_name"))
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("\(localization.localizedString("version")) \(settings.appVersion) (\(localization.localizedString("build")) \(settings.buildNumber))")
                .foregroundColor(.secondary)
            
            Divider()
                .frame(width: 200)
                .padding(.vertical)
            
            VStack(spacing: 16) {
                Link(destination: URL(string: settings.githubURL)!) {
                    HStack {
                        Image(systemName: "link")
                        Text(localization.localizedString("view_on_github"))
                    }
                }
                .buttonStyle(LinkButtonStyle())
                
                Link(destination: URL(string: "https://github.com/yourusername/VoiceCoding/issues")!) {
                    HStack {
                        Image(systemName: "exclamationmark.bubble")
                        Text(localization.localizedString("report_issue"))
                    }
                }
                .buttonStyle(LinkButtonStyle())
                
                Link(destination: URL(string: "https://github.com/yourusername/VoiceCoding/blob/main/LICENSE")!) {
                    HStack {
                        Image(systemName: "doc.text")
                        Text(localization.localizedString("license"))
                    }
                }
                .buttonStyle(LinkButtonStyle())
            }
            
            Spacer()
            
            Text(localization.localizedString("made_with_love"))
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