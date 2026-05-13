# Screens — v1

10 screens total. ASCII wireframes for clarity; real designs would be in Figma.

## 1. Onboarding (3 quick steps, no signup)

```
╭──────────────────────────────────╮
│                                  │
│   Linger.                        │
│                                  │
│   A quiet place for the          │
│   people who matter.             │
│                                  │
│                                  │
│           [  Begin  ]            │
│                                  │
│   No account, no cloud.          │
│   Everything stays on your phone.│
│                                  │
╰──────────────────────────────────╯
```

Step 2: import (optional) "Pick a few people from your contacts to start." Light-touch — multi-select up to 10, can skip.

Step 3: rhythm "How often would you like to think of them?" — five chips: weekly · biweekly · monthly · quarterly · no schedule. Applied to all imported people; per-person editable later.

## 2. Today (home tab)

```
╭──────────────────────────────────╮
│  Linger.                    ⚙︎   │
│                                  │
│  Wednesday, May 13               │
│                                  │
│  Who's on your mind today?       │
│                                  │
│  ┌──────────────────────────┐    │
│  │ Sarah                    │    │
│  │ It's been three weeks.   │    │
│  │ Last time: her mom's     │    │
│  │ surgery was on the 14th. │    │
│  └──────────────────────────┘    │
│                                  │
│  ┌──────────────────────────┐    │
│  │ David                    │    │
│  │ He starts the new job    │    │
│  │ Monday — wish him luck.  │    │
│  └──────────────────────────┘    │
│                                  │
│  [+ Note]    [+ Person]          │
│                                  │
│  ─────── Today · People · ─────  │
╰──────────────────────────────────╯
```

- Max 2-3 cards. If everyone's been seen recently, the screen says "Nothing pressing. Enjoy your day." in serif.
- Each card shows the *reason* surfaced — what you might follow up on. Pulled from your last note's open threads.
- Tap card → person detail. Swipe right → "saw them, mark caught up." Swipe left → "snooze."

## 3. People (list tab)

```
╭──────────────────────────────────╮
│  People                     ⌕    │
│                                  │
│  Inner circle                    │
│  ─────────────────────────       │
│   ●  Sarah     · weekly          │
│   ●  Mom       · weekly          │
│   ●  David     · biweekly        │
│                                  │
│  Close friends                   │
│  ─────────────────────────       │
│   ●  Alex      · monthly         │
│   ●  Priya     · monthly         │
│                                  │
│  Family                          │
│  ─────────────────────────       │
│   ●  Dad       · biweekly        │
│   ●  Sis       · monthly         │
│                                  │
╰──────────────────────────────────╯
```

- Grouped by relationship type (editable). Sections collapsible.
- Search icon top-right → fuzzy search by name or note content.
- Single dot color cue: green = recent · cream = within rhythm · warm = it's been a while. Never red.
- Long-press a person → quick actions: log a note, change rhythm, pin.

## 4. Person detail

```
╭──────────────────────────────────╮
│  ‹ Back                   Edit   │
│                                  │
│  Sarah                           │
│  Inner circle · weekly           │
│  Last seen: 3 weeks ago          │
│                                  │
│  ─────  Notes · Threads · Log ── │
│                                  │
│  Apr 22                          │
│  Coffee at Verve. She's been     │
│  worried about her mom's         │
│  upcoming surgery (Apr 14).      │
│  Started a new book on grief.    │
│                                  │
│  Mar 30                          │
│  Quick check-in by text.         │
│  She's loving the new job.       │
│                                  │
│  [+ New note]                    │
│                                  │
╰──────────────────────────────────╯
```

- Person name in New York serif Medium, 28pt. The most-loved person gets the most beautiful header.
- Three segments: **Notes** (chronological journal of interactions), **Threads** (open loops — things to follow up on, with dates), **Log** (terse interaction history — date + 1-line).
- Edit allows changing name, rhythm, relationship type, removal.

## 5. Quick-add note (modal sheet)

```
╭──────────────────────────────────╮
│             ───                  │
│                                  │
│  Note about…                     │
│  ┌──────────────────────────┐    │
│  │ Sarah                  ▾ │    │
│  └──────────────────────────┘    │
│                                  │
│  ┌──────────────────────────┐    │
│  │                          │    │
│  │  Type here…              │    │
│  │                          │    │
│  │                          │    │
│  └──────────────────────────┘    │
│                                  │
│  ▢ Follow up on this   📅 Date   │
│                                  │
│              [  Save  ]          │
╰──────────────────────────────────╯
```

- Sheet, not full-screen.
- Person picker at top — uses last-selected as default. Recent people surfaced first.
- Body: free text. No formatting toolbar visible; markdown supported invisibly.
- "Follow up on this" toggle → if on, asks for a date and adds to Threads.
- Save button is the only action. Cancel via swipe down.
- Target: 5 seconds from tap-to-save for a one-line note.

## 6. Quick-add person (modal)

```
╭──────────────────────────────────╮
│             ───                  │
│                                  │
│   Add a person                   │
│                                  │
│   Name                           │
│   ┌──────────────────────────┐   │
│   │                          │   │
│   └──────────────────────────┘   │
│                                  │
│   Relationship                   │
│   [Inner] [Close] [Family]       │
│   [Work]  [Other]                │
│                                  │
│   How often?                     │
│   [Weekly] [Biweekly] [Monthly]  │
│   [Quarterly] [No schedule]      │
│                                  │
│              [  Save  ]          │
╰──────────────────────────────────╯
```

## 7. Settings

```
╭──────────────────────────────────╮
│  Settings                        │
│                                  │
│  Sync                            │
│   iCloud sync             [On]   │
│   Last synced: 2 min ago         │
│                                  │
│  Reminders                       │
│   Daily nudge time      9:00 AM  │
│   Quiet days            None     │
│                                  │
│  Appearance                      │
│   Theme        Light · Dark · Auto│
│   Accent       Sage · Slate · ... │
│                                  │
│  Data                            │
│   Export to PDF / Markdown       │
│   Delete all data                │
│                                  │
│  About                           │
│   Linger Premium      Active     │
│   Send feedback                  │
│                                  │
╰──────────────────────────────────╯
```

## 8. Paywall

```
╭──────────────────────────────────╮
│            ───                   │
│                                  │
│   Linger Premium                 │
│                                  │
│   The free version is for 7      │
│   people. Premium is for         │
│   everyone you care about.       │
│                                  │
│   ✓  Unlimited people            │
│   ✓  iCloud sync                 │
│   ✓  Apple Watch                 │
│   ✓  PDF export                  │
│   ✓  Photo memories              │
│                                  │
│  ┌──────────────────────────┐    │
│  │ Yearly       $24.99      │    │
│  │ $2.08/mo · 7-day trial   │    │
│  └──────────────────────────┘    │
│                                  │
│  ┌──────────────────────────┐    │
│  │ Monthly      $3.99       │    │
│  └──────────────────────────┘    │
│                                  │
│   Restore  ·  Terms  ·  Privacy  │
╰──────────────────────────────────╯
```

## 9. Widget (home + lock screen)

Small (lock screen complication): single name + "It's been ~3 weeks."
Medium: top 2 people for today, tap-to-open person.
Large: top 4 people + reason.
Tinted variant for iOS 18+ lock screen.

## 10. Apple Watch

Single screen, complication or app:
- "Today's person: Sarah"
- Tap → open iPhone to compose or just acknowledge "saw them"
