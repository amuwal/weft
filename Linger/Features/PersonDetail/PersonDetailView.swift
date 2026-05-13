import SwiftData
import SwiftUI

struct PersonDetailView: View {
    enum Section: String, CaseIterable, Identifiable {
        case notes
        case threads
        case log

        var id: String {
            rawValue
        }

        var label: String {
            switch self {
            case .notes: "Notes"
            case .threads: "Threads"
            case .log: "Log"
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
        if args.contains("--log") { return .log }
        return .notes
    }

    private static var initialEdit: Bool {
        ProcessInfo.processInfo.arguments.contains("--edit")
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.l) {
                header
                Picker("Section", selection: $section.animation(.lingerSpring)) {
                    ForEach(Section.allCases) { Text($0.label).tag($0) }
                }
                .pickerStyle(.segmented)
                content
            }
            .padding(.horizontal, Spacing.xl)
            .padding(.bottom, 140)
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
        .overlay(alignment: .bottom) {
            Button {
                Haptic.soft.play()
                showingAddNote = true
            } label: {
                Label("New note", systemImage: "plus")
            }
            .buttonStyle(LingerSagePillButtonStyle())
            .padding(.horizontal, Spacing.xl)
            .padding(.bottom, 32)
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
                ForEach(notes, id: \.id) { NoteRow(note: $0, threads: person.threadsOrEmpty) }
            }
        case .threads:
            let threads = person.threadsOrEmpty.sorted { lhs, rhs in
                (lhs.dueDate, lhs.isOpen.intValue) < (rhs.dueDate, rhs.isOpen.intValue)
            }
            if threads.isEmpty {
                EmptySectionState(
                    line: "No open threads.",
                    action: "Toggle ‘follow up’ when you save a note."
                )
            } else {
                ForEach(threads, id: \.id) { thread in
                    ThreadRow(thread: thread) { resolve(thread) }
                }
            }
        case .log:
            let touchpoints = person.touchpointsOrEmpty.sorted { $0.createdAt > $1.createdAt }
            if touchpoints.isEmpty {
                EmptySectionState(line: "Nothing logged yet.", action: nil)
            } else {
                ForEach(touchpoints, id: \.id) { LogRow(touchpoint: $0) }
            }
        }
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
            .font(LingerFont.caption)
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
}

private extension Bool {
    var intValue: Int {
        self ? 0 : 1
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
                    .font(LingerFont.caption)
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

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(note.createdAt, format: .dateTime.month(.abbreviated).day().weekday(.wide))
                .font(LingerFont.mini)
                .foregroundStyle(Color.whisper)
            Text(note.body)
                .font(LingerFont.serifBody)
                .foregroundStyle(Color.ink)
                .frame(maxWidth: .infinity, alignment: .leading)
            if let openThread = threads.first(where: { $0.sourceNoteId == note.id && $0.isOpen }) {
                Label {
                    Text("Follow up · \(openThread.dueDate, format: .dateTime.month(.abbreviated).day())")
                } icon: {
                    Image(systemName: "link")
                }
                .font(LingerFont.caption)
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
    }
}

private struct ThreadRow: View {
    let thread: Thread
    let onResolve: () -> Void

    var body: some View {
        Button(action: thread.isOpen ? onResolve : {}) {
            HStack(alignment: .top, spacing: Spacing.m) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(thread.isOpen ? "OPEN" : "RESOLVED")
                        .font(LingerFont.mini)
                        .foregroundStyle(thread.isOpen ? Color.sage : Color.muted)
                    Text(thread.body)
                        .font(LingerFont.serifBody)
                        .foregroundStyle(Color.ink)
                        .strikethrough(!thread.isOpen, color: Color.whisper)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                Spacer()
                Group {
                    if thread.isOpen {
                        Text(thread.dueDate, format: .dateTime.month(.abbreviated).day())
                            .font(LingerFont.caption.monospacedDigit())
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.warmWash, in: Capsule())
                            .foregroundStyle(Color(red: 0.42, green: 0.29, blue: 0.12))
                    } else {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(Color.sage)
                            .imageScale(.large)
                    }
                }
            }
            .padding(Spacing.ml)
            .background(
                Color.surface.opacity(thread.isOpen ? 1 : 0.5),
                in: RoundedRectangle(cornerRadius: Radius.card, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Radius.card, style: .continuous)
                    .strokeBorder(Color.ink.opacity(0.06), lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
        .pressable()
    }
}

private struct LogRow: View {
    let touchpoint: Touchpoint
    var body: some View {
        HStack(spacing: Spacing.m) {
            Image(systemName: icon)
                .foregroundStyle(tint)
                .frame(width: 28, height: 28)
                .background(tint.opacity(0.15), in: Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(LingerFont.body)
                    .foregroundStyle(Color.ink)
                Text(touchpoint.createdAt, format: .dateTime.month(.abbreviated).day().hour().minute())
                    .font(LingerFont.caption)
                    .foregroundStyle(Color.muted)
            }
        }
        .padding(.vertical, Spacing.s)
    }

    private var icon: String {
        switch touchpoint.kind {
        case .note: "text.append"
        case .markedCaughtUp: "checkmark.circle"
        case .snoozed: "moon.zzz"
        case .imported: "tray.and.arrow.down"
        }
    }

    private var tint: Color {
        switch touchpoint.kind {
        case .note: .sage
        case .markedCaughtUp: .sage
        case .snoozed: .muted
        case .imported: .warm
        }
    }

    private var label: String {
        switch touchpoint.kind {
        case .note: "Note added"
        case .markedCaughtUp: "Marked caught up"
        case .snoozed: "Snoozed"
        case .imported: "Imported"
        }
    }
}

struct LingerSagePillButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(LingerFont.body.weight(.semibold))
            .foregroundStyle(Color.white.opacity(0.97))
            .frame(height: 52)
            .frame(maxWidth: .infinity)
            .background(Color.sage, in: Capsule())
            .shadow(color: Color.sage.opacity(0.45), radius: 14, y: 8)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.lingerPress, value: configuration.isPressed)
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
