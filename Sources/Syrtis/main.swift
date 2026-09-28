import AppKit
import SwiftUI

// Entry point. `--smoke` keeps the Phase 1 CLI bridge check available for CI,
// `--selftest` runs the TokenBarCore logic checks; anything else boots the
// menu-bar app (no storyboard, no .app bundle yet).

AppLanguage.prepareDirectRunResources()

if CommandLine.arguments.contains("--smoke") {
    exit(Smoke.run())
}
// Measurement lane, not a prototype: prints the current quota window's
// attributed totals and the scan timings the feature's performance comments
// quote. See `WindowProbe`.
if CommandLine.arguments.contains("--window-probe") {
    WindowProbe.run()
}
// Same kind of lane: times the synchronous quota refresh a window switch
// runs on the main actor. See `RefreshTimingProbe`.
if CommandLine.arguments.contains("--refresh-timing") {
    RefreshTimingProbe.start()
}
// Same kind of lane: when each part of the dashboard becomes drawable after
// a cold start, with the popover's tasks contending. See `LaunchTimelineProbe`.
if CommandLine.arguments.contains("--launch-timeline") {
    LaunchTimelineProbe.start()
}
if CommandLine.arguments.contains("--selftest") {
    // Some assertions compare against English UI copy, so on a non-English Mac
    // they would fail for the wrong reason. Say so instead of looking broken.
    if Bundle.main.preferredLocalizations.first != "en" {
        FileHandle.standardError.write(
            Data("warning: re-run with -AppleLanguages \"(en)\" (or `make selftest`) — string assertions expect English\n".utf8))
    }
    SelfTest.run()
}

// Open the token treemap as a regular, resizable Mac window instead of the
// menu-bar shell. It uses the same Rust report and SwiftUI view as the lens.
if CommandLine.arguments.contains("--treemap")
    || (Bundle.main.object(forInfoDictionaryKey: "AgentAtlasStandalone") as? Bool == true) {
    final class WindowLifecycle: NSObject, NSApplicationDelegate {
        func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { true }
    }
    let app = NSApplication.shared
    let lifecycle = WindowLifecycle()
    app.delegate = lifecycle
    app.setActivationPolicy(.regular)
    let window = NSWindow(
        contentRect: NSRect(x: 0, y: 0, width: 1120, height: 750),
        styleMask: [.titled, .closable, .miniaturizable, .resizable],
        backing: .buffered, defer: false)
    window.title = "Agent Atlas"
    window.minSize = NSSize(width: 700, height: 600)
    window.contentView = NSHostingView(rootView:
        WorkspaceTreemapView(year: nil, clientIds: nil, expanded: true)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(red: 0.08, green: 0.09, blue: 0.11))
            .preferredColorScheme(.dark))
    window.center()
    window.makeKeyAndOrderFront(nil)
    app.activate(ignoringOtherApps: true)
    app.run()
    exit(0)
}

if DemoData.ignoresLocalVisibility {
    DemoData.ignoreLocalVisibility()
}

// First launch after the Syrtis rename: move TokenBar.app to Syrtis.app and
// relaunch from there (exits on success). Before NSApplication, so nothing has
// loaded a resource through the old path yet.
BundleRename.runIfNeeded()

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
