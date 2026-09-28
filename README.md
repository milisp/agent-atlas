<h1 align="center">Agent Atlas</h1>

<p align="center"><strong>A native macOS map of where your AI coding tokens go.</strong></p>

Agent Atlas turns local AI coding session data into a treemap grouped by workspace and model. Each rectangle's area represents token usage, so you can quickly see which projects and models account for the most activity. The app reads local usage data and renders it on your Mac.

The first build focuses on the project map, with source filters for all data, Claude Code, and Codex. It is an early, local-first utility; provider coverage and presentation will evolve as the app is developed.

## Build

Requirements: an Apple Silicon Mac, macOS 14 or later, Xcode 27, and the Rust toolchain.

```sh
./scripts/bundle-agent-atlas.sh
open "dist/Agent Atlas.app"
```

The bundle is ad-hoc signed for local use. It is not notarized.

## Data and privacy

Agent Atlas builds on local session data supported by its upstream usage engine. The project map groups token counts by workspace and model; it does not need an Agent Atlas account or a hosted service.

## Upstream and license

Agent Atlas is an independent derivative project based on [Syrtis](https://github.com/Nanako0129/syrtis), with the workspace treemap and standalone app mode developed here. Syrtis is licensed under MIT. This repository retains upstream copyright and license notices; see [LICENSE](LICENSE) and the source credits for the other components used by the project.

Agent Atlas is not affiliated with or endorsed by the Syrtis maintainers. The name and branding of this app are independent.
