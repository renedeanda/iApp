# Add a Quick Access home shelf (SwiftUI)

> **Source:** *pattern described inline* — compact/regular Home shelf implementations proven across multiple shipped production apps.
>
> **Reliability:** ✅ compiled, shipped pattern on iPhone and iPad.

## Product contract

Call the shelf **Quick Access**, not Favorites: a first-run user has not chosen
favorites yet. Seed three or four high-value tools that demonstrate the app's
range. Keep the shelf expanded on first run so the capability is discoverable;
let compact-width users collapse it and remember that choice.

Quick Access supports recognition and repetition. It does not replace the full
catalog, global navigation, recents, or a real input action.

## Layout

- Compact width: plain section header, Edit action, and two-column 56-point
  controls. If the user selects an odd fifth item, let it span the last row.
- Regular width: a bounded secondary-surface panel with informative rows,
  leading symbols, and disclosure or lock state.
- Accessibility Dynamic Type: collapse compact grids to one readable row per
  tool, allow labels to wrap without scaling, and avoid fixed card heights.
  Every target is at least 44 points.
- Keep product-specific anchors ahead of it — e.g. a saved-items row, a concise
  paste/open action, or a document-privacy note, depending on the app.

## Customization and persistence

- Permit zero to five tools, drag reorder, explicit remove, and add from
  Available. Empty is an intentional, persisted choice—not a signal to restore
  defaults. Shortcut removal is reversible customization, not destructive data
  deletion: use a neutral 44-point remove control, tactile feedback, and a
  short-lived, item-specific Undo confirmation instead of a red Delete action.
- When the last tool is removed, expand the shelf and show a compact empty state
  with one **Choose Tools** action. In the editor, replace irrelevant reorder
  instructions with the same empty-state explanation.
- Put up to three unselected tools in **Suggested for You** above Available.
  Rank with capped, on-device-only use counts, then fall back to curated
  defaults. Never auto-add, reorder, sync, or transmit these suggestions, and
  disclose the local activity signal in the section footer.
- Offer Restore Defaults only when the current order differs from the curated
  set. Confirm restoration visually and tactually, then move VoiceOver focus to
  that confirmation so the result is not silent.
- Inject `UserDefaults` into the store and write back to that same instance.
  Test with an isolated suite so tests never mutate real app preferences.
- Preserve existing raw identifiers and ordering when renaming the UI.
- Keep the rendered `ForEach` structurally present when its collection changes
  from one item to zero. Do not conditionally replace the collection at the
  same moment its final child is removed; SwiftUI can trap while reconciling
  `ForEachChild.updateValue()`. Likewise, build multi-column rows from value
  snapshots rather than indexing a live mutable array inside row closures.
- Undo should restore the prior index and re-check eligibility, duplicate, and
  maximum-count guards. One-level Undo is sufficient; a second removal may
  supersede the first confirmation without resurrecting anything automatically.
- Treat add, remove, move, Undo, and Restore Defaults as one explicit editor
  state machine. A successful add supersedes a pending removal, every removal
  gets a fresh expiry identifier (even when it is the same tool twice), and any
  later edit clears a stale Restore Defaults confirmation. Never dismiss an
  Undo affordance after a rejected insert as though the item returned.
- An always-editing SwiftUI `List` can leave newly inserted rows without native
  reorder controls until a later reconciliation pass, and refreshing only the
  selected `ForEach` identity is insufficient because the enclosing list can
  reuse stale edit cells. For editors that mutate in place, render an app-owned
  handle in every selected row and attach the drag payload, row drop target,
  deterministic reorder operation, and accessibility adjustment to that
  explicit UI. Keep insertion and removal animation-free.
- Treat an explicitly stored empty array differently from corrupt legacy data:
  `[]` stays empty, while a non-empty array containing no valid identifiers
  restores the curated defaults. Filter unavailable capabilities before display.

## Search interaction

A non-empty tool query temporarily replaces anchors, Quick Access, recents, and
the tile wall with informative rows: symbol, localized title, short purpose,
category, and lock state. Match localized title/description/category plus
stable technical aliases. Clearing search restores Home exactly as the user
left it.

## Verification

- Fresh install shows the curated set without implying prior personalization.
- Collapse state survives relaunch; customization survives relaunch.
- Removing the last tool survives relaunch and reveals a usable empty state;
  corrupt identifiers recover to defaults; suggested and Available never
  duplicate one another.
- Host the real SwiftUI editor in a `UIWindowScene`, render one selected item,
  mutate it to zero, yield and lay out again, then restore it. Store-only tests
  do not exercise collection reconciliation and would miss this crash class.
- Rapidly add from one to five selected items without pausing; every inserted
  row must expose its app-owned reorder control immediately and drag from first
  to last and back successfully. Pin the reorder operation independently for
  before/after placement. Pin editor state separately: add clears pending Undo,
  repeated removal of the same item restarts expiry, stale expiry cannot dismiss
  a newer removal, and any edit after Restore Defaults removes the confirmation.
- Restore Defaults confirms success and changes no documents or unrelated
  settings.
- Four and five-item layouts have no orphaned half-width row.
- Search routing and Pro gates match the corresponding catalog tile.
- Collapsible headers expose localized **Expanded**/**Collapsed** values rather
  than the selected trait, and their transition does not animate under Reduce
  Motion.
- Locked rows and search results include a localized hint that activation opens
  Pro; do not rely on a lock glyph alone.
- Verify iPhone, regular iPad, narrow Split View, VoiceOver, RTL, Reduce Motion,
  and AX sizes.
