import SwiftUI

/// Birthday entry that drops into a SwiftUI `Form`. Emits one row per concept
/// so the Form's native separators do the layout work — no custom card.
///
/// Year-known mode: a single `.compact` `DatePicker` row (the standard iOS
/// pattern, identical to what Calendar / Reminders use).
/// Year-unknown mode: two `.menu` Pickers — Month and Day — each as its own
/// row, again native iOS feel.
///
/// `date` is always written with *some* year (callers default to .now / 2000)
/// so downstream code (ScoringService, exporters) can keep operating on a
/// `Date`. The `yearKnown` flag tells display code whether to render the year.
///
/// Use inside a `Section` like any other Form content:
///
///     Section {
///         Toggle("Birthday", isOn: $on)
///         if on {
///             BirthdayField(date: $date, yearKnown: $yearKnown)
///         }
///     }
struct BirthdayField: View {
    @Binding var date: Date
    @Binding var yearKnown: Bool

    private let cal = Calendar.current

    var body: some View {
        Group {
            if yearKnown {
                DatePicker(
                    "Date",
                    selection: $date,
                    displayedComponents: .date
                )
            } else {
                monthRow
                dayRow
            }
            Toggle("Year unknown", isOn: Binding(
                get: { !yearKnown },
                set: { yearKnown = !$0 }
            ).animation(.weftSpring))
        }
    }

    /// Month picker as its own Form row — label left, `.menu` Picker right.
    /// Matches Settings / Reminders styling exactly.
    private var monthRow: some View {
        let current = cal.component(.month, from: date)
        return Picker("Month", selection: Binding(
            get: { current },
            set: { newMonth in
                let yearAnchor = cal.component(.year, from: date)
                let dayClamp = min(
                    cal.component(.day, from: date),
                    daysIn(month: newMonth, year: yearAnchor)
                )
                setComponents(month: newMonth, day: dayClamp)
            }
        )) {
            ForEach(1 ... 12, id: \.self) { m in
                Text(monthName(m)).tag(m)
            }
        }
        .pickerStyle(.menu)
    }

    /// Day picker as its own Form row. Range rebuilds with the current month
    /// so Feb 30 / Apr 31 can never be selected.
    private var dayRow: some View {
        let current = cal.component(.day, from: date)
        let month = cal.component(.month, from: date)
        let year = cal.component(.year, from: date)
        let days = daysIn(month: month, year: year)
        return Picker("Day", selection: Binding(
            get: { current },
            set: { setComponents(month: month, day: $0) }
        )) {
            ForEach(1 ... days, id: \.self) { d in
                Text(String(d)).tag(d)
            }
        }
        .pickerStyle(.menu)
    }

    private func setComponents(month: Int, day: Int) {
        var comps = cal.dateComponents([.year, .month, .day], from: date)
        comps.month = month
        comps.day = day
        if let next = cal.date(from: comps) {
            date = next
        }
    }

    private func daysIn(month: Int, year: Int) -> Int {
        var anchor = DateComponents()
        anchor.year = year
        anchor.month = month
        guard let date = cal.date(from: anchor),
              let range = cal.range(of: .day, in: .month, for: date)
        else { return 31 }
        return range.count
    }

    /// Uses the current locale's standalone month names — "May" in en,
    /// "5月" in ja — so the picker reads natively in both languages.
    private func monthName(_ m: Int) -> String {
        let fmt = DateFormatter()
        fmt.locale = .current
        return fmt.standaloneMonthSymbols[max(0, min(11, m - 1))]
    }
}

#Preview {
    struct Demo: View {
        @State var on = true
        @State var date = Date.now
        @State var yearKnown = true
        var body: some View {
            Form {
                Section("Birthday") {
                    Toggle("Birthday", isOn: $on.animation(.weftSpring))
                    if on {
                        BirthdayField(date: $date, yearKnown: $yearKnown)
                    }
                }
            }
        }
    }
    return Demo()
}
