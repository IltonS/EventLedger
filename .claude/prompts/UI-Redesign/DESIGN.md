---
name: Emerald Ledger
colors:
  surface: '#f8f9ff'
  surface-dim: '#cbdbf5'
  surface-bright: '#f8f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#eff4ff'
  surface-container: '#e5eeff'
  surface-container-high: '#dce9ff'
  surface-container-highest: '#d3e4fe'
  on-surface: '#0b1c30'
  on-surface-variant: '#3f4941'
  inverse-surface: '#213145'
  inverse-on-surface: '#eaf1ff'
  outline: '#6f7a70'
  outline-variant: '#bfc9be'
  surface-tint: '#176c40'
  primary: '#005931'
  on-primary: '#ffffff'
  primary-container: '#217346'
  on-primary-container: '#a4f5bd'
  inverse-primary: '#88d8a1'
  secondary: '#565e74'
  on-secondary: '#ffffff'
  secondary-container: '#dae2fd'
  on-secondary-container: '#5c647a'
  tertiary: '#005a2c'
  on-tertiary: '#ffffff'
  tertiary-container: '#00753b'
  on-tertiary-container: '#6cff9d'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#a3f4bc'
  primary-fixed-dim: '#88d8a1'
  on-primary-fixed: '#00210f'
  on-primary-fixed-variant: '#00522d'
  secondary-fixed: '#dae2fd'
  secondary-fixed-dim: '#bec6e0'
  on-secondary-fixed: '#131b2e'
  on-secondary-fixed-variant: '#3f465c'
  tertiary-fixed: '#6bfe9c'
  tertiary-fixed-dim: '#4ae183'
  on-tertiary-fixed: '#00210c'
  on-tertiary-fixed-variant: '#005228'
  background: '#f8f9ff'
  on-background: '#0b1c30'
  surface-variant: '#d3e4fe'
typography:
  headline-xl:
    fontFamily: Manrope
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
  headline-xl-mobile:
    fontFamily: Manrope
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
  headline-lg:
    fontFamily: Manrope
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
  headline-md:
    fontFamily: Manrope
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  headline-sm:
    fontFamily: Manrope
    fontSize: 16px
    fontWeight: '600'
    lineHeight: 24px
  body-lg:
    fontFamily: Manrope
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Manrope
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  body-sm:
    fontFamily: Manrope
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 18px
  label-numeric:
    fontFamily: JetBrains Mono
    fontSize: 15px
    fontWeight: '600'
    lineHeight: 20px
  label-badge:
    fontFamily: Manrope
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
  label-sm:
    fontFamily: Manrope
    fontSize: 11px
    fontWeight: '500'
    lineHeight: 14px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 1.25rem
  gutter-mobile: 0.75rem
  margin: 2rem
  margin-mobile: 1rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2rem
---

## Brand & Style

This design system establishes an executive, data-precise, yet effortlessly human financial experience tailored for event budgeting and ledger management. Moving away from generic cold SaaS aesthetics and cluttered spreadsheets, the system blends **Corporate Modernism** with the structured ergonomics of modern fintech tools like Linear and Stripe.

The personality balances rigor, clarity, and fiscal assurance. It is engineered to evoke order and calm control over complex budgets. High-contrast typography paired with razor-sharp borders (#E2E8F0) and focused emerald green accents creates a reassuring atmosphere where financial numbers, statuses, and transaction details are instantly readable without cognitive friction.

## Colors

The palette is anchored by the deep authority of emerald spreadsheet green (`#217346`), complemented by dense slate shades for typography and hierarchy, clean surface backdrops, and dedicated financial feedback states.

- **Primary (`#217346`)**: Core interaction points, brand markers, focused tabs, and primary action buttons.
- **Primary Hover (`#165632`)**: Used for interactive hover and active pressing states.
- **Secondary (`#0F172A`)**: High-contrast text, primary headings, key monetary values, and grounding elements.
- **Tertiary (`#2ECC71`)**: Success micro-indicators, positive progress bar fills, and live metrics.
- **Backgrounds**: Canvas sits on `#F8FAFC`, with elevated surfaces and cards rendered on pristine `#FFFFFF`.
- **Borders & Dividers**: Structured, low-noise lines set in `#E2E8F0` with subtle dividers in `#F1F5F9`.
- **Text Tiers**:
  - Primary text: Slate 900 (`#0F172A`)
  - Secondary text / descriptive copy: Slate 700 (`#334155`)
  - Subdued / metadata / placeholders: Slate 500 (`#64748B`)
- **Semantic Badges**:
  - Paid (`Pago`): Soft mint surface `#DCFCE7` with deep forest text `#166534`.
  - Pending (`Pendente`): Soft amber surface `#FEF3C7` with dark amber text `#92400E`.
  - Alert / Destructive (`Excluir`): Rose background `#FEE2E2` with ruby text `#991B1B`.

## Typography

The typography system relies on **Manrope** for primary text and structural headings, matched with **JetBrains Mono** for monetary amounts, tabular data, and transaction figures.

- **Manrope**: Offers clean geometric forms with humanist terminals, rendering both Portuguese diacritics (`á, é, ã, ç, õ`) and UI titles with razor sharpness.
- **JetBrains Mono**: Deployed for numeric values (e.g., `R$ 214,60`, `R$ 89,70`). Monospaced figures ensure vertical balance and quick scanning across comparative ledger rows and balance cards.
- **Numbers & Currencies**: All monetary representations must employ tabular lining figures to maintain uniform width across itemized tables.

## Layout & Spacing

The layout is built upon an 8pt base grid structured within a fluid, responsive container system:

- **Desktop (≥ 1024px)**: Uses a persistent 260px left sidebar alongside a 12-column content grid with `1.25rem` gutters and `2rem` screen margins. Metric summary cards sit in 3 equal columns across the top row.
- **Tablet (768px – 1023px)**: The left sidebar collapses into an icon-rail or off-canvas drawer. Metric cards reflow into a 2-column or 3-column horizontal scroll rail with `1rem` gutters.
- **Mobile (< 768px)**: A single-column flow with `1rem` screen margin. Summary cards stack or form a snap-scroll carousel. Tables transform into individual expense cards. Top headers pin cleanly beneath the status bar, and key navigation moves to a bottom tab bar.
- **Padding Densities**: Dense tabular layouts utilize `space-sm` vertically and `space-md` horizontally to preserve viewable line items, avoiding unnecessary vertical expansion.

## Elevation & Depth

Visual hierarchy is maintained through crisp, tonal separation and fine borders rather than heavy dropshadows.

- **Base Canvas**: Flat `#F8FAFC` provides the foundational layer.
- **Cards & Data Tables**: Grounded `#FFFFFF` surface enclosed by a fine `1px solid #E2E8F0` border.
- **Floating Overlays & Menus**: Filter drop-downs, date pickers, and context menus use a whisper ambient shadow: `0 4px 20px -2px rgba(15, 23, 42, 0.08)` coupled with an ultra-thin perimeter outline (`#E2E8F0`).
- **Sidebar**: Neutral `#FFFFFF` or subtle tint `#F8FAFC` separated from main workspace by a persistent right border (`1px solid #E2E8F0`).
- **Active / Pressed State**: Eliminates shadow entirely and applies an internal active stroke or inset contrast tint `#165632`.

## Shapes

The interface embraces a balanced shape geometry (`roundedness: 2`), utilizing 8px (0.5rem) base corner radiuses for standard interactive elements, inputs, and metric tiles.

- **Inputs, Buttons, and Search Bars**: `0.5rem` (8px) corner radius for clean visual alignment.
- **Container Cards & Summary Panels**: `0.75rem` (12px) for structured containment.
- **Status Badges & Chips**: Pill-rounded `9999px` to distinguish metadata tokens from rectangular cards.
- **Interactive Checkboxes**: `0.25rem` (4px) with subtle internal check icons.

## Components

### Buttons
- **Primary (`Novo Evento`, `Adicionar Despesa`)**: Solid `#217346` fill, white bold text, 8px border radius, 40px height on desktop, 44px on mobile. Hover state: `#165632`. Active state: subtle scale down (0.99).
- **Secondary / Ghost (`Editar Evento`, `Arquivar`, `Importar`, `Exportar`)**: White background, `1px solid #E2E8F0`, slate text (`#334155`), hover fill `#F8FAFC`.
- **Destructive (`Excluir`)**: White background with `1px solid #FECACA`, text `#DC2626`, hover background `#FEE2E2`.

### Segmented Filter Bar
- A unified pills/tab cluster (`Todas`, `Pagas`, `Pendentes`) with an `#F1F5F9` container. Active item has a pure white surface, subtle border, and bold `#0F172A` text.

### Status Badges
- Built with a full pill radius, `space-xs` vertical padding, and `space-sm` horizontal padding.
- **Pago**: Mint surface `#DCFCE7`, text `#166534`, leading checkmark indicator.
- **Pendente**: Amber surface `#FEF3C7`, text `#92400E`, leading clock or circle indicator.

### Input Fields & Search Bars
- Standard height of 40px, bordered with `#E2E8F0`, background `#FFFFFF`. Focus state applies a `2px` ring in `#217346` with zero layout shift. Clear, legible search icon anchored at `space-md` left padding.

### Metric Cards (`Total de Despesas`, `Total Pago`, `Saldo a Pagar`)
- Crisp white background cards with a 12px border radius.
- Distinct color-coded accents for primary metrics:
  - Total de Despesas: `#0F172A`
  - Total Pago: `#217346`
  - Saldo a Pagar: `#D97706` (warning amber)
- Includes secondary progress indicators (e.g., progress bar tracking percentage settled).

### Ledger Data Rows & Tables
- Table headers in uppercase `body-sm` with `#64748B` slate text.
- Row items separated by `1px solid #F1F5F9` borders, featuring an interactive hover highlight of `#F8FAFC`.
- Action icons (edit pencil, delete trash) styled in neutral `#94A3B8` with red or green transitions on hover.