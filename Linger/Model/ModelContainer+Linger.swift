import Foundation
import SwiftData

extension ModelContainer {
    static let lingerSchema = Schema([
        Person.self,
        Note.self,
        Thread.self,
        Touchpoint.self
    ])

    /// Production container — backed by the user's private CloudKit DB
    /// when iCloud is entitled; falls back to a plain local store otherwise
    /// (simulator builds without an iCloud account, UI/unit tests, etc.).
    static func linger() throws -> ModelContainer {
        let config = if iCloudIsEntitled {
            ModelConfiguration(
                "Linger",
                schema: lingerSchema,
                cloudKitDatabase: .private("iCloud.com.amuwal.linger")
            )
        } else {
            ModelConfiguration("Linger", schema: lingerSchema)
        }
        return try ModelContainer(for: lingerSchema, configurations: [config])
    }

    /// Heuristic: only opt into CloudKit if the iCloud token is present.
    /// `FileManager.ubiquityIdentityToken` is non-nil only when the user
    /// is signed into iCloud and the app is entitled.
    private static var iCloudIsEntitled: Bool {
        let isTesting = NSClassFromString("XCTest") != nil
        guard !isTesting else { return false }
        return FileManager.default.ubiquityIdentityToken != nil
    }

    /// Used by SwiftUI previews and tests. In-memory, no CloudKit.
    @MainActor
    static var preview: ModelContainer = {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        // swiftlint:disable:next force_try
        let container = try! ModelContainer(for: lingerSchema, configurations: [config])
        SampleData.populate(container.mainContext)
        return container
    }()
}
