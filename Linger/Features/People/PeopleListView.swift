import OrderedCollections
import SwiftData
import SwiftUI

struct PeopleListView: View {
    @Query(sort: \Person.name) private var people: [Person]
    @State private var searchText = ""

    var body: some View {
        List {
            ForEach(groupedKeys, id: \.self) { key in
                Section(key.label) {
                    ForEach(grouped[key] ?? []) { person in
                        NavigationLink(value: person) {
                            PersonRow(person: person)
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
    }

    private var filtered: [Person] {
        guard !searchText.isEmpty else { return people }
        return people.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    private var grouped: OrderedDictionary<RelationshipType, [Person]> {
        var result = OrderedDictionary<RelationshipType, [Person]>()
        for type in [RelationshipType.inner, .close, .family, .work, .other] {
            let bucket = filtered.filter { $0.relationship == type }
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
            Text(person.name)
                .font(LingerFont.body)
                .foregroundStyle(Color.ink)
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

#Preview {
    NavigationStack { PeopleListView() }
        .modelContainer(.preview)
}
