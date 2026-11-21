# GEMINI.md — EventLedger Project Documentation

## Project Overview

**EventLedger** (`event_ledger_desktop`) is a cross-platform desktop application built with Dart and Flutter (targeting Linux, macOS, and Windows). It provides a personal event expense tracker localized in Brazilian Portuguese (`pt_BR`), featuring Brazilian Real (`R$`) currency formatting and standard Brazilian date representations.

### Key Capabilities
- **Consolidated Dashboard**: High-level KPIs (Total Spent, Total Paid, Pending Balance, Combined Budgets), category expense distributions, and an event summary overview.
- **Event Lifecycle Management**: Create, edit, and delete personal events with planned budgets, venues, dates, and notes.
- **Expense Categorization & Management (CRUD)**: Log individual expenses by vendor, amount, date, and category. Full CRUD for expense categories with customizable names, thematic colors, and Material icons. Deleting a category prompts for expense reassignment.
- **Payment Status Tracking**: One-click toggling between Paid (`Pago`) and Unpaid/Pending (`Pendente`), dynamically recalculating remaining balances.
- **Local Persistence**: Automatically serializes events and expenses into JSON (`event_ledger_data.json`) stored in the platform's application support directory (`com.github.iltons.EventLedger`).
- **Desktop-Optimized UI**: Responsive two-pane layout with a persistent sidebar, breadcrumb navigation header, and specialized desktop data tables.

---

## Directory Layout & Architecture

```
EventLedger/
├── analysis_options.yaml    # Dart analyzer configuration & lint rules (flutter_lints)
├── pubspec.yaml             # Project dependencies, assets, and SDK constraints
├── pubspec.lock             # Exact dependency lockfile for reproducible builds
├── README.md                # Project README (Portuguese)
├── .gitignore               # Git ignore configuration
├── lib/                     # Application source code
│   ├── main.dart            # Application entrypoint & root window layout
│   ├── models/              # Domain models and enums
│   │   └── event_models.dart# PersonalEvent, ExpenseItem, ExpenseCategory
│   ├── screens/             # Top-level workspace views
│   │   ├── all_expenses_screen.dart # Cross-event filtered expense table
│   │   ├── categories_screen.dart   # Category management (CRUD) screen
│   │   ├── dashboard_screen.dart    # Aggregated KPI dashboard & charts
│   │   └── event_detail_screen.dart # Per-event management & expense ledger
│   ├── state/               # State management & persistence
│   │   └── ledger_store.dart# LedgerStore (ChangeNotifier) & JSON storage
│   ├── theme/               # Design tokens & Material 3 theme definition
│   │   └── app_theme.dart   # Color palette, typography, card & button styles
│   └── widgets/             # Reusable UI components & dialogs
│       ├── desktop_sidebar.dart # Desktop navigation sidebar
│       └── dialogs.dart         # Modals for creating/editing events and expenses
├── linux/                   # Linux GTK/CMake platform runner & configuration
└── test/                    # Unit and widget test suite
    └── widget_test.dart
```

### Architectural Patterns

- **State Management**: Uses a centralized `ChangeNotifier` store (`LedgerStore`). Top-level routing and view state transitions (`WorkspaceView.dashboard`, `WorkspaceView.allExpenses`, `WorkspaceView.eventDetail`) are driven through `AnimatedBuilder` in `EventLedgerDesktopApp`.
- **Model Immutability**: Domain models (`PersonalEvent`, `ExpenseItem`) are immutable with copy constructors (`copyWith`) and JSON serialization (`toJson`, `fromJson`). Computed properties (such as `totalSpent`, `budgetRemaining`, and `budgetUtilization`) are calculated on-the-fly.
- **Persistence Layer**: Asynchronous, local file-based persistence via `path_provider` (`getApplicationSupportDirectory()`). If no existing data is found or deserialization fails, the application initializes with an empty dataset (`[]`).
- **Localization**: Localized for `pt_BR` via `flutter_localizations` and `intl`. Dates and currencies are formatted using standard Brazilian conventions (`R$ #.###,##` and `dd/MM/yyyy`).

---

## Build, Run, and Test Commands

### Prerequisites
- Flutter SDK `>=3.3.0 <4.0.0` (Recommended `>=3.22`)
- Desktop build toolchains for your host platform:
  - **Linux**: `clang`, `cmake`, `ninja-build`, `pkg-config`, `gtk3-devel` (or `libgtk-3-dev`)
  - **macOS**: Xcode & CocoaPods
  - **Windows**: Visual Studio 2022 (with Desktop development with C++)

### Commands

#### Dependency Management
```bash
# Fetch and update dependencies
flutter pub get
```

#### Platform Scaffolding
```bash
# Generate platform runner files if adding new desktop targets
flutter create --platforms=linux .
flutter create --platforms=macos .
flutter create --platforms=windows .
```

#### Running the Application
```bash
# Run on Linux desktop
flutter run -d linux

# Run on macOS or Windows
flutter run -d macos
flutter run -d windows
```

#### Static Analysis & Linting
```bash
# Run static analysis
flutter analyze
```

#### Testing
```bash
# Run unit and widget tests
flutter test
```

#### Building Release Executables
```bash
# Linux
flutter build linux --release

# macOS
flutter build macos --release

# Windows
flutter build windows --release
```

---

## Coding Conventions & Guidelines

### 1. Language & Localization
- **UI Strings**: All user-facing strings, labels, tooltips, dialogs, and messages must be in **Brazilian Portuguese (`pt-BR`)**.
- **Code & Identifiers**: Class names, variables, methods, file names, and comments should be written in English (e.g., `PersonalEvent`, `addExpense`, `ledger_store.dart`).
- **Numbers & Currencies**: Always format monetary values using `NumberFormat.currency(locale: 'pt_BR', symbol: 'R$')`. When parsing user input, handle Brazilian decimal commas (`1.250,50` -> `1250.50`).

### 2. State & Architecture
- Keep UI components decoupled from low-level storage. All mutations must pass through `LedgerStore` methods (`addEvent`, `updateEvent`, `deleteEvent`, `addExpense`, `updateExpense`, `toggleExpensePaid`, `deleteExpense`).
- Avoid direct mutations on model instances; always use `copyWith`.
- Call `notifyListeners()` followed by `_persist()` when updating shared application state in `LedgerStore`.

### 3. Styling & Theming
- Centralize colors and styling in `AppTheme` (`lib/theme/app_theme.dart`).
- Maintain consistent spacing and design tokens: Slate neutrals (`canvas`, `surface`, `border`, `inkPrimary`, `inkSecondary`, `inkMuted`), semantic status colors (`paidGreen`, `unpaidAmber`, `overBudgetCrimson`), and Material 3 controls.
- Use `AppTheme.tabularNumber` for tabular numeric columns to ensure consistent alignment.

### 4. Code Formatting & Quality
- Follow the rules defined in `package:flutter_lints/flutter.yaml`.
- Ensure files are formatted with `dart format .`.
- Avoid hardcoding secrets, absolute local paths, or environment-specific credentials in the codebase.
