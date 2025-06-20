# VoiceCoding

macOS用の音声入力アプリケーション。音声認識した内容を自動的にClaude Codeに送信します。

## 主な機能

### コア機能
- 🎤 **リアルタイム音声認識**: 日本語対応の高精度音声認識
- 🤖 **Claude Code連携**: 音声コマンドを直接Claude Codeに送信
- ✏️ **双方向テキスト編集**: 音声入力とターミナル出力の両方を直接編集可能
- ⏱️ **自動送信モード**: 2秒の無音検知で自動的に送信
- 🔇 **スマートな音声制御**: Claude応答中は自動的に録音を一時停止

### ユーザーインターフェース
- 🎨 **ミニマルデザイン**: ヘッダーレスのクリーンなインターフェース
- 🔘 **コンパクトな録音ボタン**: 邪魔にならない小さなコントロール
- ⌨️ **キーボードショートカット**: 
  - Space: 録音開始/停止、話し中の停止
  - Cmd+,: 設定画面を開く
- 📊 **リアルタイムステータス**: 録音中、話し中、処理中の状態を表示

### 設定とカスタマイズ
- 🗣️ **音声設定**: 音声の選択、速度、音量、ピッチの調整
- 🎙️ **録音設定**: 無音しきい値、自動送信遅延の設定
- 🌓 **外観設定**: ライト/ダーク/システムテーマ対応
- 🖥️ **ターミナルカスタマイズ**: フォントファミリーとサイズの選択
- 📁 **初期ディレクトリ**: Claude Codeの実行ディレクトリを設定可能
- 🌏 **多言語対応**: 日本語、英語、中国語、韓国語

## 必要要件

- macOS 13.0以上
- Swift 5.9以上
- [Claude Code CLI](https://github.com/anthropics/claude-code)がインストール済み
  ```bash
  npm install -g @anthropic/claude-cli
  ```
- マイクへのアクセス許可
- 音声認識の許可

## インストール

1. リポジトリをクローン
   ```bash
   git clone https://github.com/yourusername/VoiceCoding.git
   cd VoiceCoding
   ```

2. アプリをビルド
   ```bash
   ./build_app.sh
   ```

3. ビルド完了後、アプリが自動的に起動します

## 使い方

### 基本的な使い方
1. **録音を開始**:
   - 録音ボタンをクリックまたはSpaceキーを押す
   - コマンドや質問を話す
   - リアルタイムで文字起こしされます

2. **Claudeに送信**:
   - 自動送信ON: 2秒間話さないと自動送信
   - 自動送信OFF: 送信ボタンをクリック

3. **Claude応答中**:
   - 自動的に録音が一時停止
   - Spaceキーで音声出力を停止可能
   - 話し終わると自動的に録音再開

4. **手動編集**:
   - テキストエリアをクリックして直接編集
   - 修正や詳細の追加に便利

### 便利な機能
- **連続入力**: 送信後も録音が継続されるため、続けて話すことが可能
- **エコーキャンセル**: アプリ自身の音声出力に反応しない
- **初期ディレクトリ設定**: 設定画面でClaude Codeの作業ディレクトリを指定

## 開発

### プロジェクト構成
```
VoiceCoding/
├── Package.swift                    # Swift Package Manager設定
├── VoiceCoding/
│   ├── VoiceCoding.swift           # アプリのエントリーポイント
│   ├── ContentView.swift           # メインUI
│   ├── SpeechRecognizer.swift      # 音声認識ロジック
│   ├── TerminalController.swift    # Claude Code連携
│   ├── Settings.swift              # ユーザー設定管理
│   ├── SettingsView.swift          # 設定画面UI
│   ├── LocalizationManager.swift   # 多言語対応
│   └── VoiceSettings.swift         # 音声設定
├── build_app.sh                    # ビルドスクリプト（自動pkill付き）
└── build_and_run_spm.sh           # SPM直接実行スクリプト
```

### 開発用ビルド
```bash
# Swift Package Managerでビルド
swift build

# 直接実行
swift run

# リリースビルド
swift build -c release
```

### 注意事項
- 開発中は`build_app.sh`を使用することで、古いインスタンスが自動的に終了されます
- macOSのアプリケーションキャッシュにより、手動でpkillが必要な場合があります

## トラブルシューティング

### アプリが更新されない場合
```bash
pkill -f VoiceCoding
./build_app.sh
```

### Claude Codeが見つからない場合
1. Claude Code CLIがインストールされているか確認
2. PATHが正しく設定されているか確認
3. 設定画面で初期ディレクトリを設定

## ライセンス

MIT License