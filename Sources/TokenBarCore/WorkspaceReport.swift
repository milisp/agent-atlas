import Foundation

public struct WorkspaceReport: Decodable, Sendable {
    public struct Workspace: Decodable, Sendable, Identifiable {
        public struct Model: Decodable, Sendable, Identifiable {
            public let name: String
            public let tokens: Int64
            public var id: String { name }
        }

        public let key: String
        public let label: String
        public let tokens: Int64
        public let models: [Model]
        public var id: String { key }
    }

    public let totalTokens: Int64
    public let workspaces: [Workspace]

    public static let empty = WorkspaceReport(totalTokens: 0, workspaces: [])

    public init(totalTokens: Int64, workspaces: [Workspace]) {
        self.totalTokens = totalTokens
        self.workspaces = workspaces
    }
}
