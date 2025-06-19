import Foundation
import AppKit

@MainActor
class TerminalController: ObservableObject {
    @Published var output = ""
    
    private var process: Process?
    
    func startClaudeCode() async {
        output = "Claude Code ready. Send your voice input!\n"
    }
    
    func sendToClaude(_ text: String) async {
        output += "\n>>> Sending to Claude: \(text)\n"
        
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
                        }
                    }
                }
                
                try task.run()
                task.waitUntilExit()
                
                // ハンドラーをクリーンアップ
                outputPipe.fileHandleForReading.readabilityHandler = nil
                
            } catch {
                Task { @MainActor in
                    self.output += "Error: \(error.localizedDescription)\n"
                }
            }
        }.value
    }
    
    deinit {
        process?.terminate()
    }
}