import Foundation
import SwiftUI

class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    
    @Published var currentLanguage: String = "ja" {
        didSet {
            UserDefaults.standard.set(currentLanguage, forKey: "selectedLanguage")
        }
    }
    
    let supportedLanguages = [
        ("ja", "日本語"),
        ("en", "English"),
        ("zh", "中文"),
        ("ko", "한국어")
    ]
    
    private init() {
        if let savedLanguage = UserDefaults.standard.string(forKey: "selectedLanguage") {
            currentLanguage = savedLanguage
        } else {
            currentLanguage = "ja"
        }
    }
    
    func localizedString(_ key: String) -> String {
        return LocalizedStrings.getString(key, language: currentLanguage)
    }
}

struct LocalizedStrings {
    static func getString(_ key: String, language: String) -> String {
        switch language {
        case "ja":
            return jaStrings[key] ?? key
        case "en":
            return enStrings[key] ?? key
        case "zh":
            return zhStrings[key] ?? key
        case "ko":
            return koStrings[key] ?? key
        default:
            return jaStrings[key] ?? key
        }
    }
    
    static let jaStrings: [String: String] = [
        // メインUI
        "app_name": "音声コーディング",
        "voice_input": "音声入力",
        "terminal_output": "ターミナル出力",
        "start_recording": "録音開始",
        "recording": "録音中...",
        "send_to_claude": "Claudeに送信",
        "start_speaking": "話し始めると文字が表示されます...",
        "terminal_placeholder": "ターミナル出力がここに表示されます...",
        
        // 設定画面
        "settings": "設定",
        "open_settings": "設定を開く",
        "reset_to_defaults": "デフォルトに戻す",
        "done": "完了",
        "voice": "音声",
        "recording_settings": "録音",
        "appearance": "外観",
        "language": "言語",
        "about": "情報",
        
        // 音声設定
        "voice_settings": "音声設定",
        "voice_selection": "音声",
        "speed": "速度",
        "volume": "音量",
        "pitch": "ピッチ",
        "test_voice": "音声テスト",
        
        // 録音設定
        "recording_settings_title": "録音設定",
        "silence_threshold": "無音しきい値",
        "auto_send": "自動送信",
        "auto_send_delay": "自動送信の遅延",
        "advanced": "詳細設定",
        "show_debug_info": "デバッグ情報を表示",
        "haptic_feedback": "触覚フィードバック",
        
        // 外観設定
        "appearance_settings": "外観設定",
        "theme": "テーマ",
        "system": "システム",
        "light": "ライト",
        "dark": "ダーク",
        "terminal_font": "ターミナルフォント",
        "font_size": "フォントサイズ",
        "preview": "プレビュー",
        
        // 言語設定
        "language_settings": "言語設定",
        "select_language": "表示言語を選択",
        
        // アプリ情報
        "version": "バージョン",
        "build": "ビルド",
        "view_on_github": "GitHubで見る",
        "report_issue": "問題を報告",
        "license": "ライセンス",
        "made_with_love": "SwiftUIで作られました",
        
        // アラート
        "reset_settings": "設定をリセット",
        "reset_settings_message": "すべての設定をデフォルト値にリセットしてもよろしいですか？この操作は取り消せません。",
        "cancel": "キャンセル",
        "reset": "リセット",
        
        // デバッグ情報
        "debug_info": "デバッグ情報",
        "voice_info": "音声",
        "auto_send_status": "自動送信",
        "on": "オン",
        "off": "オフ",
        
        // 処理状態
        "thinking": "Claude が考え中..."
    ]
    
    static let enStrings: [String: String] = [
        // Main UI
        "app_name": "VoiceCoding",
        "voice_input": "Voice Input",
        "terminal_output": "Terminal Output",
        "start_recording": "Start Recording",
        "recording": "Recording...",
        "send_to_claude": "Send to Claude",
        "start_speaking": "Start speaking to see transcription...",
        "terminal_placeholder": "Terminal output will appear here...",
        
        // Settings
        "settings": "Settings",
        "open_settings": "Open Settings",
        "reset_to_defaults": "Reset to Defaults",
        "done": "Done",
        "voice": "Voice",
        "recording_settings": "Recording",
        "appearance": "Appearance",
        "language": "Language",
        "about": "About",
        
        // Voice Settings
        "voice_settings": "Voice Settings",
        "voice_selection": "Voice",
        "speed": "Speed",
        "volume": "Volume",
        "pitch": "Pitch",
        "test_voice": "Test Voice",
        
        // Recording Settings
        "recording_settings_title": "Recording Settings",
        "silence_threshold": "Silence Threshold",
        "auto_send": "Auto-send",
        "auto_send_delay": "Auto-send Delay",
        "advanced": "Advanced",
        "show_debug_info": "Show Debug Info",
        "haptic_feedback": "Haptic Feedback",
        
        // Appearance Settings
        "appearance_settings": "Appearance Settings",
        "theme": "Theme",
        "system": "System",
        "light": "Light",
        "dark": "Dark",
        "terminal_font": "Terminal Font",
        "font_size": "Font Size",
        "preview": "Preview",
        
        // Language Settings
        "language_settings": "Language Settings",
        "select_language": "Select Display Language",
        
        // About
        "version": "Version",
        "build": "Build",
        "view_on_github": "View on GitHub",
        "report_issue": "Report an Issue",
        "license": "License",
        "made_with_love": "Made with SwiftUI",
        
        // Alerts
        "reset_settings": "Reset Settings",
        "reset_settings_message": "Are you sure you want to reset all settings to their default values? This action cannot be undone.",
        "cancel": "Cancel",
        "reset": "Reset",
        
        // Debug Info
        "debug_info": "Debug Info",
        "voice_info": "Voice",
        "auto_send_status": "Auto-send",
        "on": "On",
        "off": "Off",
        
        // Processing State
        "thinking": "Claude is thinking..."
    ]
    
    static let zhStrings: [String: String] = [
        // 主界面
        "app_name": "语音编码",
        "voice_input": "语音输入",
        "terminal_output": "终端输出",
        "start_recording": "开始录音",
        "recording": "录音中...",
        "send_to_claude": "发送到Claude",
        "start_speaking": "开始说话以查看转录...",
        "terminal_placeholder": "终端输出将显示在这里...",
        
        // 设置
        "settings": "设置",
        "open_settings": "打开设置",
        "reset_to_defaults": "恢复默认值",
        "done": "完成",
        "voice": "语音",
        "recording_settings": "录音",
        "appearance": "外观",
        "language": "语言",
        "about": "关于",
        
        // 语音设置
        "voice_settings": "语音设置",
        "voice_selection": "语音",
        "speed": "速度",
        "volume": "音量",
        "pitch": "音调",
        "test_voice": "测试语音",
        
        // 录音设置
        "recording_settings_title": "录音设置",
        "silence_threshold": "静音阈值",
        "auto_send": "自动发送",
        "auto_send_delay": "自动发送延迟",
        "advanced": "高级",
        "show_debug_info": "显示调试信息",
        "haptic_feedback": "触觉反馈",
        
        // 外观设置
        "appearance_settings": "外观设置",
        "theme": "主题",
        "system": "系统",
        "light": "浅色",
        "dark": "深色",
        "terminal_font": "终端字体",
        "font_size": "字体大小",
        "preview": "预览",
        
        // 语言设置
        "language_settings": "语言设置",
        "select_language": "选择显示语言",
        
        // 关于
        "version": "版本",
        "build": "构建",
        "view_on_github": "在GitHub上查看",
        "report_issue": "报告问题",
        "license": "许可证",
        "made_with_love": "使用SwiftUI制作",
        
        // 警告
        "reset_settings": "重置设置",
        "reset_settings_message": "您确定要将所有设置重置为默认值吗？此操作无法撤消。",
        "cancel": "取消",
        "reset": "重置",
        
        // 调试信息
        "debug_info": "调试信息",
        "voice_info": "语音",
        "auto_send_status": "自动发送",
        "on": "开",
        "off": "关",
        
        // 处理状态
        "thinking": "Claude 正在思考中..."
    ]
    
    static let koStrings: [String: String] = [
        // 메인 UI
        "app_name": "음성 코딩",
        "voice_input": "음성 입력",
        "terminal_output": "터미널 출력",
        "start_recording": "녹음 시작",
        "recording": "녹음 중...",
        "send_to_claude": "Claude로 전송",
        "start_speaking": "말하기 시작하면 텍스트가 표시됩니다...",
        "terminal_placeholder": "터미널 출력이 여기에 표시됩니다...",
        
        // 설정
        "settings": "설정",
        "open_settings": "설정 열기",
        "reset_to_defaults": "기본값으로 재설정",
        "done": "완료",
        "voice": "음성",
        "recording_settings": "녹음",
        "appearance": "외관",
        "language": "언어",
        "about": "정보",
        
        // 음성 설정
        "voice_settings": "음성 설정",
        "voice_selection": "음성",
        "speed": "속도",
        "volume": "볼륨",
        "pitch": "피치",
        "test_voice": "음성 테스트",
        
        // 녹음 설정
        "recording_settings_title": "녹음 설정",
        "silence_threshold": "무음 임계값",
        "auto_send": "자동 전송",
        "auto_send_delay": "자동 전송 지연",
        "advanced": "고급",
        "show_debug_info": "디버그 정보 표시",
        "haptic_feedback": "햅틱 피드백",
        
        // 외관 설정
        "appearance_settings": "외관 설정",
        "theme": "테마",
        "system": "시스템",
        "light": "라이트",
        "dark": "다크",
        "terminal_font": "터미널 글꼴",
        "font_size": "글꼴 크기",
        "preview": "미리보기",
        
        // 언어 설정
        "language_settings": "언어 설정",
        "select_language": "표시 언어 선택",
        
        // 정보
        "version": "버전",
        "build": "빌드",
        "view_on_github": "GitHub에서 보기",
        "report_issue": "문제 신고",
        "license": "라이선스",
        "made_with_love": "SwiftUI로 제작",
        
        // 알림
        "reset_settings": "설정 재설정",
        "reset_settings_message": "모든 설정을 기본값으로 재설정하시겠습니까? 이 작업은 되돌릴 수 없습니다.",
        "cancel": "취소",
        "reset": "재설정",
        
        // 디버그 정보
        "debug_info": "디버그 정보",
        "voice_info": "음성",
        "auto_send_status": "자동 전송",
        "on": "켜짐",
        "off": "꺼짐",
        
        // 처리 상태
        "thinking": "Claude가 생각 중..."
    ]
}