<h1 align="center">Agent Atlas</h1>

<p align="center"><strong>用原生 macOS 图表，查看 AI 编程 token 都花在了哪里。</strong></p>

Agent Atlas 将本机 AI 编程会话数据整理成按工作区和模型分组的矩形树图。每个矩形的面积代表 token 用量，帮助你快速看出哪些项目和模型占用了更多用量。数据在 Mac 本机读取和呈现。

首个版本聚焦于项目用量图，并提供全部数据、Claude Code 和 Codex 三种来源筛选。这是一款仍在早期开发的本地优先工具，支持的数据来源和呈现方式会继续完善。

## 构建

需要 Apple Silicon Mac、macOS 14 或更高版本、Xcode 27 和 Rust 工具链。

```sh
./scripts/bundle-agent-atlas.sh
open "dist/Agent Atlas.app"
```

应用包使用 ad-hoc 签名供本机运行，尚未经过 Apple 公证。

## 数据与隐私

Agent Atlas 基于上游用量引擎支持的本机会话数据，将 token 数按工作区和模型汇总。它不需要 Agent Atlas 账户或托管服务。

## 上游与许可证

Agent Atlas 是基于 [Syrtis](https://github.com/Nanako0129/syrtis) 开发的独立衍生项目；工作区树图和独立应用模式由本项目开发。Syrtis 使用 MIT 许可证。本仓库保留上游版权和许可证声明；其他组件的来源见 [LICENSE](LICENSE) 和源代码致谢。

Agent Atlas 与 Syrtis 维护者没有隶属或背书关系；本应用使用独立名称与品牌。
