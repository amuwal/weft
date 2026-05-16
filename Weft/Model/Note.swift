import Foundation
import SwiftData

@Model
final class Note {
    // Defaults required by CloudKit's schema mirror; `init` overwrites them.
    var id = UUID()
    var body: String = ""
    var createdAt = Date.now
    var person: Person?
    /// `.externalStorage` keeps the blob out of the .sqlite store and lets
    /// CloudKit sync it as a CKAsset. Always compressed via PhotoCompressor
    /// before being assigned — never store raw camera-roll bytes here.
    @Attribute(.externalStorage) var photoData: Data?

    init(body: String, person: Person, createdAt: Date = .now, photoData: Data? = nil) {
        self.id = UUID()
        self.body = body
        self.person = person
        self.createdAt = createdAt
        self.photoData = photoData
    }
}
