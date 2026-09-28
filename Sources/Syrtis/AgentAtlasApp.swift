import SwiftUI

/// The standalone Agent Atlas window. A SwiftUI `App` rather than a hand-built
/// `NSWindow` so the system supplies the standard, localized menu bar. A lone
/// `Window` scene also quits the app when that window closes.
///
/// Launched from `main.swift` (not `@main`), which routes the other modes.
struct AgentAtlasApp: App {
    var body: some Scene {
        Window("Agent Atlas", id: "atlas") {
            WorkspaceTreemapView(year: nil, clientIds: nil, expanded: true)
                .frame(minWidth: 700, maxWidth: .infinity, minHeight: 600, maxHeight: .infinity)
                .background(Color(red: 0.08, green: 0.09, blue: 0.11))
                .preferredColorScheme(.dark)
        }
        .defaultSize(width: 1120, height: 750)
        .windowResizability(.contentMinSize)
    }
}
