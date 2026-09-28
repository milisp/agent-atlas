<h1 align="center">Agent Atlas</h1>

<p align="center"><strong>以原生 macOS 圖表，查看 AI 寫程式 token 用在何處。</strong></p>

Agent Atlas 將本機 AI 寫程式工作階段資料整理成依工作區與模型分組的矩形樹圖。每個矩形的面積代表 token 用量，讓你快速看出哪些專案與模型占用較多用量。資料在 Mac 本機讀取並呈現。

首個版本聚焦於專案用量圖，並提供全部資料、Claude Code 與 Codex 三種來源篩選。這是一款仍在早期開發的本機優先工具，支援的資料來源與呈現方式會持續擴充。

## 建置

需要 Apple Silicon Mac、macOS 14 或以上版本、Xcode 27 與 Rust 工具鏈。

```sh
./scripts/bundle-agent-atlas.sh
open "dist/Agent Atlas.app"
```

應用程式使用 ad-hoc 簽署供本機執行，尚未經過 Apple 公證。

## 資料與隱私

Agent Atlas 使用上游用量引擎支援的本機工作階段資料，依工作區與模型彙整 token 數量。它不需要 Agent Atlas 帳號或託管服務。

## 上游與授權

Agent Atlas 是以 [Syrtis](https://github.com/Nanako0129/syrtis) 為基礎開發的獨立衍生專案；工作區樹圖與獨立應用程式模式由本專案開發。Syrtis 採用 MIT 授權。本儲存庫保留上游著作權與授權聲明；其他元件的來源請見 [LICENSE](LICENSE) 與原始碼致謝。

Agent Atlas 與 Syrtis 維護者沒有隸屬或背書關係；本應用程式採用獨立名稱與品牌。
