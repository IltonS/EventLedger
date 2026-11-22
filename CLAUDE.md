# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

EventLedger (`event_ledger_desktop`) is a Flutter desktop app (Linux/macOS/Windows) for tracking personal event expenses. The UI is localized to Brazilian Portuguese (`pt_BR`, `R$`, `dd/MM/yyyy`). Data is persisted as a single JSON file (`event_ledger_data.json`) in the app support directory (`com.github.iltons.EventLedger`). Only the `linux/` platform runner is checked in.

## Commands

```bash
flutter pub get
flutter run -d linux          # or macos / windows
flutter analyze               # flutter_lints; build/** and linux/** are excluded
dart format .
flutter test                  # all tests (test/widget_test.dart)
flutter test --plain-name "<test name>"   # single test
flutter build linux --release
```

## Architecture

- **Single store, no router**: `LedgerStore` (`lib/state/ledger_store.dart`, a `ChangeNotifier`) owns all events, categories, *and* navigation state (`WorkspaceView` enum + `selectedEventId`). `EventLedgerHomeScreen` in `lib/main.dart` wraps it in an `AnimatedBuilder` and switches the main pane by `activeView`; there is no `Navigator` routing between screens. Adding a screen means adding a `WorkspaceView` value, a sidebar entry, and a case in `main.dart`.
- **All mutations go through `LedgerStore`** methods (add/update/delete/archive event, expense, category, toggle paid). Each mutation updates state, calls `notifyListeners()`, then `_persist()` to JSON. Models in `lib/models/event_models.dart` (`PersonalEvent`, `ExpenseItem`, `ExpenseCategory`) are immutable — use `copyWith`; totals/budget figures are computed getters.
- **Archiving**: `store.events` excludes archived events; `archivedEvents` and `allEvents` expose the rest. Dashboard aggregates (`totalSpentAllEvents`, `aggregatedCategoryTotals`, etc.) use only non-archived events.
- **Categories are user-editable** (name, color, icon); deleting one prompts to reassign its expenses.
- **Budget is optional** per event; budget UI is hidden when an event (or all events) has none (`hasAnyEventWithBudget`).
- `lib/widgets/dialogs.dart` holds all form/confirm dialogs (returns result objects consumed by screens). Shared UI such as `category_chart_card.dart` lives in `lib/widgets/`.
- `LedgerStore` accepts `initialEvents`/`initialCategories` for tests, so widget tests build a store directly and wrap screens in a `MaterialApp` with the `pt_BR` localization delegates (see `_buildTestApp` in `test/widget_test.dart`).

## Conventions

- UI strings in pt-BR; code, identifiers, file names and comments in English.
- Money: format with `NumberFormat.currency(locale: 'pt_BR', symbol: 'R$')`; parse user input with Brazilian separators (`1.250,50` → `1250.50`).
- Centralize colors/styles in `AppTheme` (`lib/theme/app_theme.dart`); use `AppTheme.tabularNumber` for numeric columns.
- Commit messages follow Conventional Commits (`feat:`, `refactor:`, `docs:`, `chore:`), optionally with `Closes #N`.
