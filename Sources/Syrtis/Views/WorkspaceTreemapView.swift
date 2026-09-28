import SwiftUI
import TokenBarCore

/// Token area by project, with each project subdivided by model.
struct WorkspaceTreemapView: View {
    let year: String?
    /// nil selects every source; an empty array selects none.
    let clientIds: [String]?
    var expanded = false

    @State private var report: WorkspaceReport?
    @State private var error: String?
    @State private var selectedKey: String?
    @State private var selectedSource: Source = .all

    private enum Source: String, CaseIterable, Identifiable {
        case all = "All"
        case claude = "Claude Code"
        case codex = "Codex"

        var id: String { rawValue }
        var clientIds: [String]? {
            switch self {
            case .all: nil
            case .claude: ["claude"]
            case .codex: ["codex"]
            }
        }
    }

    private var activeClientIds: [String]? { expanded ? selectedSource.clientIds : clientIds }

    private let colors: [Color] = [
        Color(red: 0.12, green: 0.52, blue: 0.77),
        Color(red: 0.13, green: 0.61, blue: 0.51),
        Color(red: 0.81, green: 0.46, blue: 0.21),
        Color(red: 0.57, green: 0.38, blue: 0.76),
        Color(red: 0.76, green: 0.32, blue: 0.42),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Where did your tokens go?")
                        .font(.headline)
                    Text("Rectangle area represents token usage · grouped by project and model")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if expanded {
                    Picker("Source", selection: $selectedSource) {
                        ForEach(Source.allCases) { source in
                            Text(source.rawValue).tag(source)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 290)
                }
                if let report {
                    Text(Format.compactTokens(report.totalTokens))
                        .font(.headline.monospacedDigit())
                }
            }

            if let report, !report.workspaces.isEmpty {
                HStack(spacing: 8) {
                    projectList(report)
                        .frame(width: expanded ? 210 : 145)
                    GeometryReader { geometry in
                        let rows = report.workspaces
                        let frames = TokenTreemapLayout.frames(
                            weights: rows.map(\.tokens), in: CGRect(origin: .zero, size: geometry.size))
                        ZStack(alignment: .topLeading) {
                            ForEach(rows.indices, id: \.self) { index in
                                projectTile(rows[index], color: colors[index % colors.count],
                                            frame: frames[index])
                            }
                        }
                    }
                    .background(Color.black.opacity(0.18))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                // The window grows with its frame; the popover keeps a fixed height.
                .frame(minHeight: expanded ? 360 : 390, maxHeight: expanded ? .infinity : 390)
                if let selected = report.workspaces.first(where: { $0.key == selectedKey }) {
                    Text("\(displayName(selected)) · \(Format.compactTokens(selected.tokens)) · \(selected.models.count) models")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text("Select a rectangle to inspect a project")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            } else if let error {
                Text(error).font(.caption).foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 180)
            } else if report != nil {
                Text("No project usage in this range")
                    .font(.caption).foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 180)
            } else {
                ProgressView().frame(maxWidth: .infinity, minHeight: 180)
            }
        }
        .padding(expanded ? 20 : 12)
        .frame(maxHeight: expanded ? .infinity : nil, alignment: .top)
        .glassCard()
        .task(id: "\(year ?? "all")|\(activeClientIds?.joined(separator: ",") ?? "all")") {
            report = nil
            error = nil
            guard activeClientIds?.isEmpty != true else {
                report = .empty
                return
            }
            let requestedYear = year
            let requestedClients = activeClientIds
            do {
                let loaded = try await Task.detached(priority: .userInitiated) {
                    try TBCore.workspaceReport(year: requestedYear, clients: requestedClients)
                }.value
                guard !Task.isCancelled else { return }
                report = loaded
            } catch {
                guard !Task.isCancelled else { return }
                self.error = "Project usage is unavailable: \(error.localizedDescription)"
            }
        }
    }

    private func projectList(_ report: WorkspaceReport) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 3) {
                ForEach(report.workspaces.indices, id: \.self) { index in
                    let row = report.workspaces[index]
                    Button {
                        selectedKey = row.key
                    } label: {
                        HStack(spacing: 5) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(colors[index % colors.count])
                                .frame(width: 7, height: 7)
                            Text(displayName(row)).lineLimit(1)
                            Spacer(minLength: 2)
                            Text(Format.compactTokens(row.tokens))
                                .monospacedDigit().foregroundStyle(.secondary)
                        }
                        .font(.caption2)
                        .padding(.horizontal, 5).padding(.vertical, 6)
                        .background(selectedKey == row.key ? Color.primary.opacity(0.1) : .clear)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                    .buttonStyle(.plain)
                    .help(row.key)
                }
            }
        }
    }

    private func projectTile(_ row: WorkspaceReport.Workspace, color: Color, frame: CGRect) -> some View {
        ZStack(alignment: .topLeading) {
            color.opacity(selectedKey == row.key ? 0.95 : 0.78)
            if frame.width > 84 && frame.height > 45 {
                let inset = CGRect(x: 3, y: 22, width: max(0, frame.width - 6),
                                   height: max(0, frame.height - 25))
                let modelFrames = TokenTreemapLayout.frames(
                    weights: row.models.map(\.tokens), in: inset)
                ForEach(row.models.indices, id: \.self) { index in
                    let tile = modelFrames[index]
                    ZStack(alignment: .topLeading) {
                        color.opacity(index.isMultiple(of: 2) ? 0.75 : 0.48)
                        if tile.width > 65 && tile.height > 31 {
                            Text(row.models[index].name)
                                .font(.system(size: 9, weight: .medium))
                                .lineLimit(2)
                                .padding(4)
                        }
                    }
                    .frame(width: tile.width, height: tile.height)
                    .position(x: tile.midX, y: tile.midY)
                    .help("\(row.models[index].name): \(Format.compactTokens(row.models[index].tokens))")
                }
                Text("\(displayName(row)) · \(Format.compactTokens(row.tokens))")
                    .font(.system(size: 10, weight: .semibold))
                    .lineLimit(1)
                    .padding(.horizontal, 5).padding(.top, 4)
            } else if frame.width > 48 && frame.height > 24 {
                Text(displayName(row)).font(.system(size: 9, weight: .semibold))
                    .lineLimit(1).padding(4)
            }
        }
        .foregroundStyle(.white)
        .frame(width: frame.width, height: frame.height)
        .overlay(Rectangle().stroke(Color.black.opacity(0.55), lineWidth: 2))
        .position(x: frame.midX, y: frame.midY)
        .contentShape(Rectangle())
        .onTapGesture { selectedKey = row.key }
        .help("\(displayName(row)): \(Format.compactTokens(row.tokens))")
    }

    private func displayName(_ row: WorkspaceReport.Workspace) -> String {
        let label = row.label
        if label.hasPrefix("/") { return URL(fileURLWithPath: label).lastPathComponent }
        let encodedHome = FileManager.default.homeDirectoryForCurrentUser.path
            .replacingOccurrences(of: "/", with: "-") + "-"
        if label.hasPrefix(encodedHome) {
            var remainder = String(label.dropFirst(encodedHome.count))
            if remainder.hasPrefix("projects-") {
                let parts = remainder.split(separator: "-", maxSplits: 2)
                if parts.count == 3 { remainder = String(parts[2]) }
            } else {
                for folder in ["finance", "Desktop", "Documents", "Movies", "Developer", "Library"] {
                    if remainder.hasPrefix(folder + "-") {
                        remainder = String(remainder.dropFirst(folder.count + 1))
                        break
                    }
                }
            }
            return remainder.isEmpty ? label : remainder
        }
        if label.hasPrefix("-private-tmp-") { return String(label.dropFirst("-private-tmp-".count)) }
        return label
    }
}

/// Balanced binary treemap: each leaf gets area proportional to its token count.
enum TokenTreemapLayout {
    static func frames(weights: [Int64], in rect: CGRect) -> [CGRect] {
        guard !weights.isEmpty else { return [] }
        var output = Array(repeating: CGRect.zero, count: weights.count)
        place(Array(weights.indices), weights: weights, rect: rect, output: &output)
        return output
    }

    private static func place(_ indices: [Int], weights: [Int64], rect: CGRect,
                              output: inout [CGRect]) {
        guard indices.count > 1 else {
            if let index = indices.first { output[index] = rect }
            return
        }
        let total = indices.reduce(0.0) { $0 + Double(max(0, weights[$1])) }
        let target = total / 2
        var split = 0
        var first = 0.0
        repeat {
            first += Double(max(0, weights[indices[split]]))
            split += 1
        } while split < indices.count - 1 && first < target
        let fraction = total > 0 ? first / total : Double(split) / Double(indices.count)
        let leading: CGRect
        let trailing: CGRect
        if rect.width >= rect.height {
            let width = rect.width * fraction
            leading = CGRect(x: rect.minX, y: rect.minY, width: width, height: rect.height)
            trailing = CGRect(x: rect.minX + width, y: rect.minY,
                              width: rect.width - width, height: rect.height)
        } else {
            let height = rect.height * fraction
            leading = CGRect(x: rect.minX, y: rect.minY, width: rect.width, height: height)
            trailing = CGRect(x: rect.minX, y: rect.minY + height,
                              width: rect.width, height: rect.height - height)
        }
        place(Array(indices[..<split]), weights: weights, rect: leading, output: &output)
        place(Array(indices[split...]), weights: weights, rect: trailing, output: &output)
    }
}
