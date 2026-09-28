# Contributing to Agent Atlas

Agent Atlas is an early macOS app for exploring local AI coding usage by workspace and model. Focus contributions on the standalone treemap, accurate workspace attribution, and clear source coverage.

## Build locally

Use an Apple Silicon Mac with macOS 14 or later, Xcode 27, and the Rust toolchain.

```sh
./scripts/bundle-agent-atlas.sh
open "dist/Agent Atlas.app"
```

The package currently uses the inherited Syrtis Swift and Rust build. The project knowledge under `docs/knowledge/` documents upstream architecture and verification details; treat references to Syrtis as upstream context unless a document has been adapted for Agent Atlas.

## Change guidelines

- Keep documentation and code comments in English, except localized content.
- Preserve the `LICENSE` file and upstream copyright notices when changing or distributing inherited code.
- Keep workspace and model totals consistent with the Rust report and the Swift treemap.
- Do not add network upload or collection of prompts and source code to the local report flow.
- Keep local pricing notes out of public changes.

## Attribution

Agent Atlas is an independent derivative of [Syrtis](https://github.com/Nanako0129/syrtis). Contributions should preserve clear attribution and should not imply endorsement by the Syrtis maintainers.
