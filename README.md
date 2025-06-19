# VoiceCoding

macOS用の音声入力アプリケーション。音声認識した内容を自動的にClaude Codeに送信します。

## 機能

- 🎤 リアルタイム音声認識（日本語対応）
- 🤖 Claude Codeとの自動連携
- ⏱️ 2秒の無音で自動送信
- 🔄 連続音声入力対応

## 必要要件

- macOS 13.0以上
- Swift 5.9以上
- [Claude Code CLI](https://github.com/anthropics/claude-code)がインストール済み

## ビルド方法

```bash
# リポジトリをクローン
git clone https://github.com/yourusername/VoiceCoding.git
cd VoiceCoding

# アプリをビルド
./build_app.sh
```

## 使い方

1. アプリを起動
2. マイクボタンをクリックして録音開始
3. 話す
4. 2秒間の無音で自動的にClaude Codeに送信
5. 録音は継続されるので、続けて話すことが可能

## プロジェクト構成

```
VoiceCoding/
├── Package.swift              # Swift Package Manager設定
├── VoiceInputApp/
│   ├── VoiceInputApp.swift   # アプリのエントリーポイント
│   ├── ContentView.swift     # メインUI
│   ├── SpeechRecognizer.swift # 音声認識機能
│   └── TerminalController.swift # Claude Code連携
└── build_app.sh             # ビルドスクリプト
```

## ライセンス

MIT License