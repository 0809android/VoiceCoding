# VoiceCoding Project Structure

## Overview
VoiceCoding is a macOS application that enables voice-controlled interaction with Claude AI. The app features real-time speech recognition, automatic text-to-speech responses, and a modern, multilingual user interface.

## Project Layout

```
VoiceCoding/
├── Package.swift                 # Swift Package Manager configuration
├── build_app.sh                 # Build script for creating the app bundle
├── build_and_run_spm.sh        # Alternative build script using SPM
├── VoiceCoding.app/            # Built application bundle
└── VoiceCoding/                # Source code directory
    ├── Info.plist              # App metadata
    ├── VoiceCoding.entitlements # App permissions
    └── Swift source files      # Main application code
```

## Core Components

### 1. **VoiceCoding.swift**
- Entry point of the application
- Defines the `@main` App structure
- Simple SwiftUI app wrapper

### 2. **ContentView.swift**
- Main user interface
- Split view with voice input on left, terminal output on right
- Handles recording button, text display, and settings sheet
- Key features:
  - Modern UI with gradients and shadows
  - Multilingual support via LocalizationManager
  - Real-time transcription display
  - Auto-send functionality with manual override
  - Debug info display option

### 3. **SpeechRecognizer.swift**
- Manages speech recognition using Apple's Speech framework
- Features:
  - Japanese language support with fallback
  - Real-time transcription
  - Silence detection for auto-send
  - Continuous recording with text accumulation
  - Clear and continue recording functionality

### 4. **TerminalController.swift**
- Manages interaction with Claude CLI
- Features:
  - Sends voice input to Claude via command line
  - Real-time output streaming
  - Text-to-speech for Claude's responses
  - Processing state management
  - Custom voice settings support

### 5. **Settings.swift**
- Centralized settings management using UserDefaults
- Manages:
  - Voice selection and parameters (speed, volume, pitch)
  - Recording settings (silence threshold, auto-send)
  - Appearance settings (theme, fonts)
  - Debug options

### 6. **SettingsView.swift**
- Comprehensive settings interface
- Tab-based navigation:
  - Voice: Speech synthesis settings
  - Recording: Input configuration
  - Appearance: UI customization
  - Language: Locale selection
  - About: App information
- Live preview for settings changes

### 7. **LocalizationManager.swift**
- Multilingual support system
- Supported languages:
  - Japanese (default)
  - English
  - Chinese
  - Korean
- Dynamic language switching
- Comprehensive UI string translations

### 8. **VoiceSettings.swift**
- Voice synthesis configuration
- Manages AVSpeechSynthesizer parameters
- Shared between components for consistent voice output

## Key Features

### Voice Input
- Real-time speech recognition
- Automatic silence detection
- Continuous recording mode
- Text accumulation and clearing

### Claude Integration
- Direct CLI integration
- Real-time response streaming
- Processing state indicators
- Error handling

### User Interface
- Modern, card-based design
- Gradient backgrounds and shadows
- Smooth animations
- Responsive layout

### Multilingual Support
- Four language options
- Runtime language switching
- Localized UI elements
- Persistent language preference

### Text-to-Speech
- Automatic response reading
- Customizable voice parameters
- Multiple voice options
- Skip self-input reading

## Build System

### Requirements
- macOS 13.0+
- Xcode Command Line Tools
- Swift 5.x
- Claude CLI installed at `/Users/kinocode/.npm-global/bin/claude`

### Build Process
1. `Package.swift` defines dependencies and targets
2. `build_app.sh` script:
   - Builds the Swift package
   - Creates app bundle structure
   - Signs with entitlements
   - Optionally launches the app

### Entitlements
- `com.apple.security.device.audio-input`: Microphone access
- `com.apple.security.speech-recognition`: Speech recognition
- Additional security permissions for file access

## Usage Flow

1. **Launch**: App starts with Claude ready message
2. **Recording**: User clicks record button or presses spacebar
3. **Transcription**: Real-time display of recognized speech
4. **Sending**: Auto-send after silence or manual send button
5. **Processing**: Shows "thinking" indicator during Claude processing
6. **Response**: Claude's response appears and is spoken aloud
7. **Repeat**: Text clears automatically for next input

## Development Notes

### State Management
- `@StateObject` for view-owned objects
- `@ObservedObject` for shared state
- `@Published` properties for UI updates

### Async/Await
- Used for speech authorization
- Terminal command execution
- Non-blocking UI operations

### Error Handling
- Graceful fallbacks for missing languages
- Process error capturing
- User-friendly error messages

### Performance Considerations
- Efficient text accumulation
- Real-time streaming without blocking
- Minimal UI redraws