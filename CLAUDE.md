# VoiceCoding Development Notes

## プロジェクト概要
VoiceCodingは、音声入力をClaude Codeに直接送信するmacOSアプリです。2025年6月20日に大幅な機能追加とUI改善を実施しました。

## 最近の主な変更点（2025-06-20）

### 1. 音声フィードバック防止機能
- **問題**: アプリが自分自身の音声出力（Claude応答の読み上げ）に反応してしまう
- **解決策**:
  - `TerminalController`に`AVSpeechSynthesizerDelegate`を実装
  - 音声合成中は自動的に録音を一時停止
  - 話し終わったら0.5秒後に自動的に録音再開
  - Spaceキーで音声を即座に停止可能

### 2. UI/UXの大幅改善
- **ヘッダー削除**: 「音声コーディング」タイトルバーを削除してミニマルなデザインに
- **録音ボタンの小型化**: 60ptから20ptに縮小、横長のコンパクトなデザイン
- **Spaceキーヒント表示**: 録音ボタンの下に「Space」キーのヒントを表示
- **設定ボタン移動**: 右上の小さなアイコンとして配置

### 3. テキスト編集機能
- **双方向編集**: 音声入力エリアとターミナル出力の両方をTextEditorに変更
- **手動入力対応**: キーボードから直接テキストを入力・編集可能
- **プレースホルダー表示**: 空のときにヒントテキストを表示

### 4. 初期ディレクトリ設定
- **設定画面に追加**: 詳細設定セクションに「初期ディレクトリ」設定を追加
- **フォルダー選択UI**: NSOpenPanelを使用したディレクトリ選択
- **自動適用**: Claude Code実行時に指定ディレクトリに自動移動

### 5. ビルドスクリプトの改善
- **自動pkill機能**: `build_app.sh`に既存インスタンスの自動終了を追加
- **問題の解決**: macOSのアプリキャッシュによる古いバージョン起動問題を解決

## 技術的な実装詳細

### キーボードイベント処理
```swift
NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
    if event.keyCode == 49 { // Space key
        // 処理ロジック
    }
}
```
- TextEditorにフォーカスがない場合のみSpaceキーで録音制御
- 話し中は常にSpaceキーで停止可能

### 音声合成の状態管理
```swift
class TerminalController: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    @Published var isSpeaking = false
    // デリゲートメソッドで状態を追跡
}
```

### ローカライゼーション
- 4言語対応: 日本語、英語、中国語、韓国語
- `LocalizationManager`による動的な言語切り替え

## 既知の問題と対策

### 1. アプリが更新されない問題
- **原因**: macOSのアプリケーションキャッシュ
- **対策**: `build_app.sh`に自動pkill機能を追加

### 2. KAFAssistantErrorDomain エラー
- **原因**: 音声認識と音声合成の競合
- **対策**: 音声合成前に小さな遅延を追加、即座にisSpeakingフラグを設定

## 開発時の注意事項

### ビルド方法
1. **推奨**: `./build_app.sh` - 自動的に古いインスタンスを終了
2. **代替**: `swift build` + 手動でpkill

### デバッグ時のTips
- 音声認識の状態は`SpeechRecognizer`の`isRecording`で確認
- 音声合成の状態は`TerminalController`の`isSpeaking`で確認
- ログ出力でタイミングの問題を調査

## 今後の改善案
1. 音声認識の精度向上（ノイズキャンセリング）
2. より高度なコマンド解析
3. ショートカットキーのカスタマイズ機能
4. 履歴機能の追加

## リリース前のチェックリスト
- [ ] すべての言語でUIテキストが正しく表示されるか
- [ ] 音声フィードバック防止が正常に動作するか
- [ ] キーボードショートカットが期待通りに動作するか
- [ ] 設定の保存と読み込みが正常か
- [ ] Claude Code CLIとの連携が正常か

## 重要なファイル
- `ContentView.swift`: メインUIとキーボードイベント処理
- `TerminalController.swift`: Claude Code連携と音声合成
- `SpeechRecognizer.swift`: 音声認識ロジック
- `build_app.sh`: ビルドスクリプト（pkill機能付き）