import SwiftData
import SwiftUI

struct PersonDetailView: View {
    enum Section: String, CaseIterable, Identifiable {
        case notes
        case threads

        var id: String {
            rawValue
        }

        var label: String {
            switch self {
            case .notes: String(localized: "Notes")
            case .threads: String(localized: "Threads")
            }
        }
    }

    let person: Person
    @Environment(\.modelContext) private var context
    @State private var section: Section = Self.initialSection
    @State private var showingAddNote = false
    @State private var showingEdit = Self.initialEdit

    private static var initialSection: Section {
        let args = ProcessInfo.processInfo.arguments
        if args.contains("--threads") { return .threads }
        return .notes
    }

    private static var initialEdit: Bool {
        ProcessInfo.processInfo.arguments.contains("--edit")
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.l) {
                header
                Picker("Section", selection: $section.animation(.weftSpring)) {
                    ForEach(Section.allCases) { Text($0.label).tag($0) }
                }
                .pickerStyle(.segmented)
                content
            }
            .padding(.horizontal, Spacing.xl)
            .padding(.bottom, 20)
        }
        .background(Color.bg)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Haptic.selection.play()
                    showingEdit = true
                } label: {
                    Image(systemName: "pencil")
                        .foregroundStyle(Color.muted)
                }
            }
        }
        .sheet(isPresented: $showingEdit) {
            NavigationStack { EditPersonSheet(person: person) }
                .presentationDetents([.large])
                .presentationCornerRadius(28)
                .presentationBackground(.regularMaterial)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            Button {
                Haptic.soft.play()
                showingAddNote = true
            } label: {
                Label("New note", systemImage: "plus")
            }
            .buttonStyle(WeftSagePillButtonStyle())
            .padding(.horizontal, Spacing.xl)
            .padding(.bottom, 16)
            .background(
                LinearGradient(
                    colors: [Color.bg.opacity(0), Color.bg.opacity(0.95)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 110)
                .allowsHitTesting(false),
                alignment: .bottom
            )
        }
        .sheet(isPresented: $showingAddNote) {
            NavigationStack {
                AddNoteForm(prefilledPerson: person)
                    .navigationTitle("New note")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") { showingAddNote = false }
                        }
                    }
            }
            .presentationDetents([.large])
            .presentationCornerRadius(28)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            Text(person.name)
                .font(.system(size: 40, design: .serif).weight(.medium))
                .foregroundStyle(Color.ink)
            HStack(spacing: 8) {
                pill(person.relationship.label, isAccent: true)
                pill(person.rhythm.label, isAccent: false)
                if let label = sinceLabel { pill(label, isAccent: false) }
            }
            if let until = person.snoozedUntil, until > .now {
                Button {
                    Haptic.selection.play()
                    person.snoozedUntil = nil
                    try? context.save()
                } label: {
                    Label {
                        Text(
                            "Snoozed until \(until, format: .dateTime.month(.abbreviated).day()) · tap to wake"
                        )
                    } icon: {
                        Image(systemName: "moon.zzz.fill")
                    }
                    .font(WeftFont.caption.weight(.medium))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.surface2, in: Capsule())
                    .foregroundStyle(Color.muted)
                }
                .buttonStyle(.plain)
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch section {
        case .notes:
            let notes = person.notesOrEmpty.sorted { $0.createdAt > $1.createdAt }
            if notes.isEmpty {
                EmptySectionState(line: "No notes yet.", action: "Write the first.")
            } else {
                ForEach(notes, id: \.id) { note in
                    NoteRow(note: note, threads: person.threadsOrEmpty)
                        .contextMenu {
                            Button(role: .destructive) { delete(note) } label: {
                                Label("Delete note", systemImage: "trash")
                            }
                        }
                }
            }
        case .threads:
            let rows = threadRows
            if rows.isEmpty {
                EmptySectionState(
                    line: "No follow-ups.",
                    action: "Toggle ‘follow up’ when you save a note."
                )
            } else {
                ForEach(rows, id: \.thread.id) { row in
                    ThreadRow(
                        thread: row.thread,
                        sourceNote: row.note,
                        status: row.status,
                        onResolve: { resolve(row.thread) },
                        onReopen: { reopen(row.thread) }
                    )
                }
            }
        }
    }

    private var threadRows: [ThreadRowModel] {
        person.threadsOrEmpty
            .map { thread in
                let note = thread.sourceNoteId.flatMap { id in
                    person.notesOrEmpty.first(where: { $0.id == id })
                }
                return ThreadRowModel(
                    thread: thread,
                    note: note,
                    status: status(for: thread)
                )
            }
            .sorted { lhs, rhs in
                if lhs.status.sortKey != rhs.status.sortKey {
                    return lhs.status.sortKey < rhs.status.sortKey
                }
                return lhs.thread.dueDate < rhs.thread.dueDate
            }
    }

    private func status(for thread: Thread) -> ThreadStatus {
        if let resolvedAt = thread.resolvedAt {
            return .caughtUp(at: resolvedAt)
        }
        if let until = person.snoozedUntil, until > .now {
            return .snoozed(until: until)
        }
        return .open(due: thread.dueDate)
    }

    private var sinceLabel: String? {
        let latest = (person.notesOrEmpty.map(\.createdAt) + person.touchpointsOrEmpty.map(\.createdAt)).max()
        guard let latest else { return "new" }
        let days = Int(Date.now.timeIntervalSince(latest) / 86400)
        if days < 1 { return "today" }
        if days < 7 { return "\(days)d" }
        return "\(days / 7)w"
    }

    private func pill(_ text: String, isAccent: Bool) -> some View {
        Text(text)
            .font(WeftFont.caption)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isAccent ? Color.sageWash : Color.surface2, in: Capsule())
            .foregroundStyle(isAccent ? Color.sageInk : Color.muted)
    }

    private func resolve(_ thread: Thread) {
        thread.resolvedAt = .now
        try? context.save()
        Haptic.success.play()
    }

    private func reopen(_ thread: Thread) {
        thread.resolvedAt = nil
        try? context.save()
        Haptic.selection.play()
    }

    private func delete(_ note: Note) {
        context.delete(note)
        try? context.save()
        Haptic.warning.play()
    }
}

private struct EmptySectionState: View {
    let line: String
    let action: String?

    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Text(line)
                .font(.system(size: 22, design: .serif).weight(.regular))
                .foregroundStyle(Color.ink)
            if let action {
                Text(action)
                    .font(WeftFont.caption)
                    .foregroundStyle(Color.whisper)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.xxl)
    }
}

private struct NoteRow: View {
    let note: Note
    let threads: [Thread]
    @State private var showingPhoto = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(note.createdAt, format: .dateTime.month(.abbreviated).day().weekday(.wide))
                .font(WeftFont.mini)
                .foregroundStyle(Color.whisper)
            if let data = note.photoData, let image = UIImage(data: data) {
                Button {
                    Haptic.soft.play()
                    showingPhoto = true
                } label: {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(maxHeight: 280)
                        .clipShape(RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: Radius.card, style: .continuous)
                                .strokeBorder(Color.ink.opacity(0.06), lineWidth: 0.5)
                        )
                }
                .buttonStyle(.plain)
            }
            Text(note.body)
                .font(WeftFont.serifBody)
                .foregroundStyle(Color.ink)
                .frame(maxWidth: .infinity, alignment: .leading)
            if let openThread = threads.first(where: { $0.sourceNoteId == note.id && $0.isOpen }) {
                Label {
                    Text("Follow up · \(openThread.dueDate, format: .dateTime.month(.abbreviated).day())")
                } icon: {
                    Image(systemName: "link")
                }
                .font(WeftFont.caption)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.sageWash, in: Capsule())
                .foregroundStyle(Color.sageInk)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, Spacing.m)
        .overlay(alignment: .bottom) {
            Rectangle().fill(Color.ink.opacity(0.06)).frame(height: 0.5)
        }
        .sheet(isPresented: $showingPhoto) {
            if let data = note.photoData, let image = UIImage(data: data) {
                PhotoViewer(image: image)
            }
        }
    }
}

/// Full-screen zoomable viewer for an attached photo. Tap-to-dismiss; pinch
/// zooms via the system magnification gesture stack.
private struct PhotoViewer: View {
    let image: UIImage
    @Environment(\.dismiss) private var dismiss
    @State private var scale: CGFloat = 1
    @State private var lastScale: CGFloat = 1

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .scaleEffect(scale)
                .gesture(
                    MagnifyGesture()
                        .onChanged { value in scale = max(1, min(lastScale * value.magnification, 4)) }
                        .onEnded { _ in lastScale = scale }
                )
                .onTapGesture { dismiss() }
        }
    }
}

enum ThreadStatus {
    case open(due: Date)
    case caughtUp(at: Date)
    case snoozed(until: Date)

    var label: String {
        switch self {
        case .open: String(localized: "OPEN")
        case .caughtUp: String(localized: "CAUGHT UP")
        case .snoozed: String(localized: "SNOOZED")
        }
    }

    var icon: String {
        switch self {
        case .open: "link"
        case .caughtUp: "checkmark.circle.fill"
        case .snoozed: "moon.zzz.fill"
        }
    }

    var tint: Color {
        switch self {
        case .open: .sage
        case .caughtUp: .sage
        case .snoozed: .muted
        }
    }

    /// Open first, then snoozed, then caught up.
    var sortKey: Int {
        switch self {
        case .open: 0
        case .snoozed: 1
        case .caughtUp: 2
        }
    }

    var dateForMeta: Date {
        switch self {
        case .open(let due): due
        case .caughtUp(let at): at
        case .snoozed(let until): until
        }
    }

    var metaPrefix: String {
        switch self {
        case .open: "due"
        case .caughtUp: "on"
        case .snoozed: "until"
        }
    }
}

struct ThreadRowModel {
    let thread: Thread
    let note: Note?
    let status: ThreadStatus
}

private struct ThreadRow: View {
    let thread: Thread
    let sourceNote: Note?
    let status: ThreadStatus
    let onResolve: () -> Void
    let onReopen: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: status.icon)
                    .foregroundStyle(status.tint)
                Text(status.label)
                    .font(WeftFont.mini.weight(.semibold))
                    .foregroundStyle(status.tint)
                Spacer()
                Text(
                    "\(status.metaPrefix) \(status.dateForMeta, format: .dateTime.month(.abbreviated).day())"
                )
                .font(WeftFont.caption.monospacedDigit())
                .foregroundStyle(Color.muted)
            }

            Text(thread.body)
                .font(WeftFont.serifBody)
                .foregroundStyle(Color.ink)
                .strikethrough(isCaughtUp, color: Color.whisper)
                .frame(maxWidth: .infinity, alignment: .leading)

            if let body = sourceNote?.body, !body.isEmpty {
                Text(body)
                    .font(WeftFont.caption)
                    .foregroundStyle(Color.muted)
                    .lineLimit(3)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(Spacing.ml)
        .background(
            Color.surface.opacity(isCaughtUp ? 0.55 : 1),
            in: RoundedRectangle(cornerRadius: Radius.card, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Radius.card, style: .continuous)
                .strokeBorder(Color.ink.opacity(0.06), lineWidth: 0.5)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            if isCaughtUp { onReopen() } else { onResolve() }
        }
        .pressable()
    }

    private var isCaughtUp: Bool {
        if case .caughtUp = status { return true }
        return false
    }
}

struct WeftSagePillButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(WeftFont.body.weight(.semibold))
            .foregroundStyle(Color.white.opacity(0.97))
            .frame(height: 52)
            .frame(maxWidth: .infinity)
            .background(Color.sage, in: Capsule())
            .shadow(color: Color.sage.opacity(0.45), radius: 14, y: 8)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.weftPress, value: configuration.isPressed)
    }
}

#Preview {
    NavigationStack {
        PersonDetailView(
            person: Person(name: "Sarah", relationship: .inner, rhythm: .weekly, avatarPalette: .rose)
        )
    }
    .modelContainer(.preview)
}
