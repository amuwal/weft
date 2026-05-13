import OrderedCollections
import SwiftData
import SwiftUI

struct PeopleListView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Person.name) private var people: [Person]
    @State private var searchText = ""
    @State private var rhythmTarget: Person?

    var body: some View {
        List {
            ForEach(groupedKeys, id: \.self) { key in
                Section(key.label) {
                    ForEach(grouped[key] ?? []) { person in
                        NavigationLink(value: person) {
                            PersonRow(person: person)
                        }
                        .contextMenu { contextMenuItems(for: person) }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) { delete(person) } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .swipeActions(edge: .leading, allowsFullSwipe: false) {
                            Button { togglePin(person) } label: {
                                Label(
                                    person.pinned ? "Unpin" : "Pin",
                                    systemImage: person.pinned ? "pin.slash" : "pin"
                                )
                            }
                            .tint(.sage)
                        }
                    }
                }
            }
        }
        .listStyle(.plain)
        .background(Color.bg)
        .scrollContentBackground(.hidden)
        .searchable(text: $searchText, prompt: "Search Sarah, conversations, threads…")
        .navigationTitle("People")
        .navigationDestination(for: Person.self) { PersonDetailView(person: $0) }
        .sheet(item: $rhythmTarget) { person in
            NavigationStack {
                ChangeRhythmSheet(person: person)
            }
            .presentationDetents([.medium])
            .presentationCornerRadius(28)
            .presentationBackground(.regularMaterial)
        }
    }

    @ViewBuilder
    private func contextMenuItems(for person: Person) -> some View {
        Button { togglePin(person) } label: {
            Label(
                person.pinned ? "Unpin" : "Pin to top",
                systemImage: person.pinned ? "pin.slash" : "pin"
            )
        }
        Button { rhythmTarget = person } label: {
            Label("Change rhythm", systemImage: "metronome")
        }
        Divider()
        Button(role: .destructive) { delete(person) } label: {
            Label("Delete", systemImage: "trash")
        }
    }

    private func togglePin(_ person: Person) {
        person.pinned.toggle()
        try? context.save()
        Haptic.soft.play()
    }

    private func delete(_ person: Person) {
        context.delete(person)
        try? context.save()
        Haptic.warning.play()
    }

    private var filtered: [Person] {
        guard !searchText.isEmpty else { return people }
        return people.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    private var grouped: OrderedDictionary<RelationshipType, [Person]> {
        var result = OrderedDictionary<RelationshipType, [Person]>()
        for type in [RelationshipType.inner, .close, .family, .work, .other] {
            let bucket = filtered
                .filter { $0.relationship == type }
                .sorted { lhs, rhs in
                    if lhs.pinned != rhs.pinned { return lhs.pinned && !rhs.pinned }
                    return lhs.name < rhs.name
                }
            if !bucket.isEmpty { result[type] = bucket }
        }
        return result
    }

    private var groupedKeys: [RelationshipType] {
        Array(grouped.keys)
    }
}

private struct PersonRow: View {
    let person: Person

    var body: some View {
        HStack(spacing: Spacing.m) {
            PersonAvatar(initial: person.initial, palette: person.avatarPalette, size: 40)
            HStack(spacing: 6) {
                if person.pinned {
                    Image(systemName: "pin.fill")
                        .font(.system(size: 11))
                        .foregroundStyle(Color.sage)
                }
                Text(person.name)
                    .font(LingerFont.body)
                    .foregroundStyle(Color.ink)
            }
            Spacer()
            HStack(spacing: 6) {
                DotIndicator(state: .onRhythm)
                Text(person.rhythm.label)
                    .font(LingerFont.caption)
                    .foregroundStyle(Color.muted)
            }
        }
        .padding(.vertical, 4)
        .listRowBackground(Color.bg)
        .listRowSeparatorTint(Color.ink.opacity(0.08))
    }
}

struct ChangeRhythmSheet: View {
    let person: Person
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @State private var chosen: Rhythm

    init(person: Person) {
        self.person = person
        _chosen = State(initialValue: person.rhythm)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.l) {
            VStack(alignment: .leading, spacing: 4) {
                Text("How often")
                    .font(LingerFont.caption)
                    .foregroundStyle(Color.muted)
                Text(person.name)
                    .font(.system(size: 30, design: .serif).weight(.medium))
                    .foregroundStyle(Color.ink)
            }
            Picker("Rhythm", selection: $chosen) {
                ForEach(Rhythm.allCases) { Text($0.label).tag($0) }
            }
            .pickerStyle(.inline)
            .labelsHidden()
            Spacer()
            Button("Save") {
                person.rhythm = chosen
                try? context.save()
                Haptic.success.play()
                dismiss()
            }
            .buttonStyle(LingerPrimaryButtonStyle())
        }
        .padding(.horizontal, Spacing.xl)
        .padding(.vertical, Spacing.l)
        .background(Color.bg)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", action: dismiss.callAsFunction)
            }
        }
    }
}

#Preview {
    NavigationStack { PeopleListView() }
        .modelContainer(.preview)
}
