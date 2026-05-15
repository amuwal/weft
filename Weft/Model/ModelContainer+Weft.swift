import Foundation
import SwiftData

extension ModelContainer {
    static let weftSchema = Schema([
        Person.self,
        Note.self,
        Thread.self,
        Touchpoint.self
    ])

    /// Production container — backed by the user's private CloudKit DB
    /// when iCloud is entitled; falls back to a plain local store otherwise
    /// (simulator builds without an iCloud account, UI/unit tests, etc.).
    static func weft() throws -> ModelContainer {
        let config = if iCloudIsEntitled {
            ModelConfiguration(
                "Weft",
                schema: weftSchema,
                cloudKitDatabase: .private("iCloud.com.amuwal.weft")
            )
        } else {
            ModelConfiguration("Weft", schema: weftSchema, cloudKitDatabase: .none)
        }
        return try ModelContainer(for: weftSchema, configurations: [config])
    }

    /// Heuristic: only opt into CloudKit on a real device with an iCloud token.
    /// The simulator falls back to a local store — CloudKit there demands every
    /// attribute be optional, which clashes with the SwiftData models we ship.
    /// Real-device sync is the developer's responsibility to wire up.
    private static var iCloudIsEntitled: Bool {
        let isTesting = NSClassFromString("XCTest") != nil
        guard !isTesting else { return false }
        #if targetEnvironment(simulator)
            return false
        #else
            return FileManager.default.ubiquityIdentityToken != nil
        #endif
    }

    /// Used by SwiftUI previews and tests. In-memory, no CloudKit.
    @MainActor
    static var preview: ModelContainer = {
        let config = ModelConfiguration(isStoredInMemoryOnly: true, cloudKitDatabase: .none)
        // swiftlint:disable:next force_try
        let container = try! ModelContainer(for: weftSchema, configurations: [config])
        SampleData.populate(container.mainContext)
        return container
    }()
}
