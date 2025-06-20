import SwiftUI
import AVFoundation

// MARK: - Settings Model
class Settings: ObservableObject {
    static let shared = Settings()
    
    // Voice Settings
    @AppStorage("selectedVoice") var selectedVoice: String = "com.apple.voice.compact.en-US.Samantha"
    @AppStorage("voiceSpeed") var voiceSpeed: Double = 1.0
    @AppStorage("voiceVolume") var voiceVolume: Double = 0.8
    @AppStorage("voicePitch") var voicePitch: Double = 1.0
    
    // Recording Settings
    @AppStorage("silenceThreshold") var silenceThreshold: Double = -40.0
    @AppStorage("autoSendEnabled") var autoSendEnabled: Bool = true
    @AppStorage("autoSendDelay") var autoSendDelay: Double = 1.5
    
    // Appearance Settings
    @AppStorage("selectedTheme") var selectedTheme: String = "system"
    @AppStorage("terminalFontSize") var terminalFontSize: Double = 14.0
    @AppStorage("terminalFontFamily") var terminalFontFamily: String = "SF Mono"
    
    // Advanced Settings
    @AppStorage("showDebugInfo") var showDebugInfo: Bool = false
    @AppStorage("enableHapticFeedback") var enableHapticFeedback: Bool = true
    @AppStorage("initialDirectory") var initialDirectory: String = ""
    
    // App Info
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    let githubURL = "https://github.com/yourusername/VoiceCoding"
    
    // Available voices
    var availableVoices: [AVSpeechSynthesisVoice] {
        AVSpeechSynthesisVoice.speechVoices()
    }
    
    // Theme options
    let themeOptions = ["system", "light", "dark"]
    
    // Font options
    let fontFamilies = ["SF Mono", "Menlo", "Monaco", "Courier", "Courier New", "Andale Mono"]
    
    private init() {}
}

// MARK: - Theme Extension
extension Settings {
    var currentColorScheme: ColorScheme? {
        switch selectedTheme {
        case "light":
            return .light
        case "dark":
            return .dark
        default:
            return nil
        }
    }
    
    // Reset all settings to defaults
    func resetToDefaults() {
        selectedVoice = "com.apple.voice.compact.en-US.Samantha"
        voiceSpeed = 1.0
        voiceVolume = 0.8
        voicePitch = 1.0
        silenceThreshold = -40.0
        autoSendEnabled = true
        autoSendDelay = 1.5
        selectedTheme = "system"
        terminalFontSize = 14.0
        terminalFontFamily = "SF Mono"
        showDebugInfo = false
        enableHapticFeedback = true
        initialDirectory = ""
    }
}