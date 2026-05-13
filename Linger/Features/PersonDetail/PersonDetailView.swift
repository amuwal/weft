import SwiftData
import SwiftUI

struct PersonDetailView: View {
    let person: Person

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

    @State private var section: Section = .notes

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.l) {
                header
                Picker("Section", selection: $section) {
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
                Button {} label: {
                    Image(systemName: "pencil").foregroundStyle(Color.muted)
                }
            }
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
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch section {
        case .notes:
            ForEach(person.notesOrEmpty.sorted { $0.createdAt > $1.createdAt }, id: \.id) { note in
                NoteRow(note: note)
            }
        case .threads:
            ForEach(person.threadsOrEmpty.sorted { $0.dueDate < $1.dueDate }, id: \.id) { thread in
                ThreadRow(thread: thread)
            }
        case .log:
            ForEach(person.touchpointsOrEmpty.sorted { $0.createdAt > $1.createdAt }, id: \.id) { tp in
                LogRow(touchpoint: tp)
            }
        }
    }

    private func pill(_ text: String, isAccent: Bool) -> some View {
        Text(text)
            .font(LingerFont.caption)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isAccent ? Color.sageWash : Color.surface2, in: Capsule())
            .foregroundStyle(isAccent ? Color.sageInk : Color.muted)
    }
}

private struct NoteRow: View {
    let note: Note
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(note.createdAt, format: .dateTime.month(.abbreviated).day())
                .font(LingerFont.mini)
                .foregroundStyle(Color.whisper)
            Text(note.body)
                .font(LingerFont.serifBody)
                .foregroundStyle(Color.ink)
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
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                Text(thread.isOpen ? "OPEN" : "RESOLVED")
                    .font(LingerFont.mini)
                    .foregroundStyle(thread.isOpen ? Color.sage : Color.muted)
                Text(thread.body)
                    .font(LingerFont.serifBody)
                    .foregroundStyle(Color.ink)
                    .strikethrough(!thread.isOpen, color: Color.whisper)
            }
            Spacer()
            Text(thread.dueDate, format: .dateTime.month(.abbreviated).day())
                .font(LingerFont.caption.monospacedDigit())
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.warmWash, in: Capsule())
                .foregroundStyle(Color(red: 0.42, green: 0.29, blue: 0.12))
        }
        .padding(Spacing.ml)
        .background(Color.surface, in: RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Radius.card, style: .continuous)
                .strokeBorder(Color.ink.opacity(0.06), lineWidth: 0.5)
        )
    }
}

private struct LogRow: View {
    let touchpoint: Touchpoint
    var body: some View {
        HStack {
            Text(touchpoint.createdAt, format: .dateTime.month(.abbreviated).day())
                .font(LingerFont.caption.monospacedDigit())
                .foregroundStyle(Color.muted)
            Text(touchpoint.kind == .markedCaughtUp ? "Marked caught up" : "Note added")
                .font(LingerFont.body)
                .foregroundStyle(Color.ink)
        }
        .padding(.vertical, Spacing.s)
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
