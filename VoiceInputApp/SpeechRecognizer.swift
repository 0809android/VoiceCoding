import Foundation
import Speech
import AVFoundation

@MainActor
class SpeechRecognizer: ObservableObject {
    @Published var recognizedText = ""
    @Published var isRecording = false
    @Published var errorMessage = ""
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private let speechRecognizer: SFSpeechRecognizer?
    private var silenceTimer: Timer?
    private var lastTranscriptionTime = Date()
    private let silenceThreshold: TimeInterval = 2.0  // 2秒の無音で自動送信
    
    var onSilenceDetected: (() -> Void)?
    
    func clearAndContinueRecording() {
        // 送信済みの位置を更新
        lastSentIndex = accumulatedText.count
        recognizedText = ""
        lastTranscriptionTime = Date()
        
        // タイマーをリセット
        silenceTimer?.invalidate()
        silenceTimer = nil
    }
    
    // 累積テキストを保持するプロパティ
    private var accumulatedText = ""
    private var lastSentIndex = 0
    
    init() {
        // Try Japanese first, fall back to default if not available
        if let jaRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ja-JP")) {
            self.speechRecognizer = jaRecognizer
            print("Using Japanese speech recognizer")
        } else {
            self.speechRecognizer = SFSpeechRecognizer()
            print("Japanese not available, using default speech recognizer")
        }
    }
    
    func requestAuthorization() async {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { authStatus in
                switch authStatus {
                case .authorized:
                    print("Speech recognition authorized")
                case .denied:
                    print("Speech recognition denied")
                case .restricted:
                    print("Speech recognition restricted")
                case .notDetermined:
                    print("Speech recognition not determined")
                @unknown default:
                    print("Speech recognition unknown status")
                }
                continuation.resume()
            }
        }
    }
    
    func startRecording() {
        // Reset the audio engine if it's already running
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        
        // Cancel any existing recognition task
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = nil
        
        guard let speechRecognizer = speechRecognizer,
              speechRecognizer.isAvailable else {
            errorMessage = "Speech recognizer not available"
            print("Speech recognizer not available")
            return
        }
        
        recognizedText = ""
        accumulatedText = ""
        lastSentIndex = 0
        errorMessage = ""
        isRecording = true
        
        do {
            // Create and configure the speech recognition request
            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            
            let inputNode = audioEngine.inputNode
            
            guard let recognitionRequest = recognitionRequest else {
                print("Unable to create recognition request")
                return
            }
            
            recognitionRequest.shouldReportPartialResults = true
            // Don't force on-device recognition for Japanese
            recognitionRequest.requiresOnDeviceRecognition = false
            
            // Create recognition task
            recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
                var isFinal = false
                
                if let result = result {
                    self.accumulatedText = result.bestTranscription.formattedString
                    
                    // 最後に送信した位置以降の新しいテキストを取得
                    if self.accumulatedText.count > self.lastSentIndex {
                        let startIndex = self.accumulatedText.index(self.accumulatedText.startIndex, offsetBy: self.lastSentIndex)
                        self.recognizedText = String(self.accumulatedText[startIndex...])
                        
                        if !self.recognizedText.isEmpty {
                            self.lastTranscriptionTime = Date()
                            print("New text: \(self.recognizedText)")
                            
                            // 既存のタイマーをキャンセル
                            self.silenceTimer?.invalidate()
                            
                            // 新しいタイマーを開始
                            self.silenceTimer = Timer.scheduledTimer(withTimeInterval: self.silenceThreshold, repeats: false) { _ in
                                print("Silence detected, auto-sending...")
                                Task { @MainActor in
                                    self.onSilenceDetected?()
                                }
                            }
                        }
                    }
                    
                    isFinal = result.isFinal
                }
                
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    print("Recognition error: \(error.localizedDescription)")
                }
                
                if error != nil || isFinal {
                    self.audioEngine.stop()
                    inputNode.removeTap(onBus: 0)
                    
                    self.recognitionRequest = nil
                    self.recognitionTask = nil
                    self.isRecording = false
                    self.silenceTimer?.invalidate()
                }
            }
            
            // Get the native audio format of the input node
            let nativeFormat = inputNode.inputFormat(forBus: 0)
            print("Native format: \(nativeFormat)")
            
            // For speech recognition on macOS, we'll use the native format
            // The system will handle any necessary conversion
            let recordingFormat = nativeFormat
            
            // Install tap with the native format
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, when in
                self.recognitionRequest?.append(buffer)
            }
            
            // Prepare and start the audio engine
            audioEngine.prepare()
            try audioEngine.start()
            
            print("Recording started with format: \(recordingFormat)")
            
        } catch {
            errorMessage = error.localizedDescription
            print("Recording failed: \(error.localizedDescription)")
            // Clean up on error
            audioEngine.stop()
            recognitionRequest = nil
            recognitionTask = nil
            isRecording = false
        }
    }
    
    func stopRecording() {
        if audioEngine.isRunning {
            audioEngine.stop()
        }
        
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        
        // Clean up
        recognitionRequest = nil
        recognitionTask = nil
        
        // Remove tap if it exists
        audioEngine.inputNode.removeTap(onBus: 0)
        
        // Cancel silence timer
        silenceTimer?.invalidate()
        silenceTimer = nil
        
        isRecording = false
        print("Recording stopped")
    }
}