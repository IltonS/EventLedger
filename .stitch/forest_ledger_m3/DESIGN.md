---
name: Forest Ledger M3
colors:
  surface: '#f4fcf2'
  surface-dim: '#d4dcd3'
  surface-bright: '#f4fcf2'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#eef6ec'
  surface-container: '#e8f0e6'
  surface-container-high: '#e2eae1'
  surface-container-highest: '#dde5db'
  on-surface: '#161d17'
  on-surface-variant: '#3f4941'
  inverse-surface: '#2b322c'
  inverse-on-surface: '#ebf3e9'
  outline: '#6f7a70'
  outline-variant: '#bfc9be'
  surface-tint: '#176c40'
  primary: '#005931'
  on-primary: '#ffffff'
  primary-container: '#217346'
  on-primary-container: '#a4f5bd'
  inverse-primary: '#88d8a1'
  secondary: '#4f6354'
  on-secondary: '#ffffff'
  secondary-container: '#cfe5d2'
  on-secondary-container: '#536758'
  tertiary: '#29535e'
  on-tertiary: '#ffffff'
  tertiary-container: '#426b77'
  on-tertiary-container: '#bfeaf8'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#a3f4bc'
  primary-fixed-dim: '#88d8a1'
  on-primary-fixed: '#00210f'
  on-primary-fixed-variant: '#00522d'
  secondary-fixed: '#d2e8d5'
  secondary-fixed-dim: '#b6ccba'
  on-secondary-fixed: '#0d1f14'
  on-secondary-fixed-variant: '#384b3d'
  tertiary-fixed: '#bfe9f8'
  tertiary-fixed-dim: '#a3cddb'
  on-tertiary-fixed: '#001f27'
  on-tertiary-fixed-variant: '#224c58'
  background: '#f4fcf2'
  on-background: '#161d17'
  surface-variant: '#dde5db'
typography:
  display-md:
    fontFamily: Inter
    fontSize: 44px
    fontWeight: '700'
    lineHeight: 52px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
    letterSpacing: -0.015em
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 26px
    fontWeight: '600'
    lineHeight: 34px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
    letterSpacing: -0.01em
  title-lg:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  title-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '600'
    lineHeight: 24px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  body-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 16px
  label-lg:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.01em
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.02em
  label-sm:
    fontFamily: Inter
    fontSize: 11px
    fontWeight: '500'
    lineHeight: 14px
    letterSpacing: 0.03em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 1.25rem
  gutter-sm: 0.75rem
  gutter-lg: 1.5rem
  margin: 1.5rem
  margin-mobile: 1rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2rem
---

## Brand & Style

The design system re-architects EventLedger into a disciplined, high-density financial management interface based on Google Material Design 3 (M3). The target audience consists of event planners, coordinators, and individuals handling rigorous event budgets requiring accuracy, visual reassurance, and effortless status recognition. 

The aesthetic marries Material 3’s organic container-based architecture with financial rigor. The signature deep forest emerald green (`#217346`) provides institutional trust, calm fiscal confidence, and clarity, moving decisively away from generic primary blues.

### Key Visual Attributes
- **M3 Container Layering:** Visual weight is created not through heavy drop shadows, but via disciplined surface-tier nesting (`surface-container-low`, `surface-container`, `surface-container-high`).
- **Precision Data Presentation:** Tabular data, monetary units, and status badges prioritize legibility and strict visual alignment.
- **Organic Geometry:** Distinctive Material 3 rounded forms (pills for interactive triggers and segmented buttons, rounded containers for cards and dialogs) counterbalance structured tabular lists.
- **Portuguese Language Fidelity:** Maintain strict adherence to all existing localization strings (`Painel de Despesas`, `Todas as Despesas`, `Categorias`, `Eventos Arquivados`, `Detalhes do Evento`, and transaction modals).

## Colors

The palette is derived directly from the M3 tonal generation system anchored by primary deep forest green (`#217346`).

### Tonal Hierarchy & Surfaces
- **Primary (`#217346`):** Applied to primary actions (`+ Novo Evento`, `+ Adicionar Despesa`, `+ Nova Categoria`), active navigation indicators, and key metric progress tracks.
- **Primary Container (`#A4F2BD`):** Used for soft positive feedback states, selected filter segments, and subtle primary badges. On-Primary-Container is `#00210E`.
- **Secondary (`#4F6354`):** Earthy slate-green providing supporting structure, secondary action triggers (`Importar`, `Exportar`), and subtle icon fills.
- **Tertiary (`#3B6470`):** Soft teal used for secondary analytical data points and auxiliary status markers.
- **Error & Attention (`#BA1A1A`):** Used for danger actions (`Excluir`), negative budget overages, and critical alerts. Container: `#FFDAD6`.
- **Status Indicators (Fiscal Financial Semantics):**
  - **Pago (Paid):** Emerald Green (`#1E7D47`), Surface: `#E6F7ED`, Text: `#0D4A27`.
  - **Pendente (Pending / Saldo a Pagar):** Warm Amber (`#B26A00`), Surface: `#FFF3E0`, Text: `#683B00`.
  - **Orçamento / Neutro:** Slate Neutral (`#4F6354`), Surface: `#EDF2EC`.

### Surface Container Hierarchy (Light Mode)
- **Base Surface (`#F7FAF5`):** Root canvas background for main viewports.
- **Surface Container Lowest (`#FFFFFF`):** High-prominence cards, data table containers, and modals.
- **Surface Container Low (`#F1F5EF`):** Outer sidebar rail and secondary toolbar regions.
- **Surface Container (`#EBEFE9`):** Input field fills and grouped segmented button bases.
- **Surface Container High (`#E5EAE3`):** Table header fills and subtle divider hover states.
- **Outline & Outline Variant (`#717971` / `#C1C9BF`):** Crisp, subtle 1px framing for tabular data cells, text fields, and quiet card edges.

## Typography

The type system is powered by Inter, delivering geometric crispness and distinct tabular numerals essential for currency and ledger alignment.

### Numeric & Currency Styling
- All currency values (`R$ 214,60`, `R$ 1.000,00`) must utilize tabular figure features (`font-variant-numeric: tabular-nums;`) to guarantee columnar vertical alignment in data tables and summary metric decks.
- Metric values in KPI cards use `headline-lg` (`28px` to `32px` semi-bold) paired with `body-sm` muted labels.

### Hierarchy Guidelines
- **Breadcrumbs / Top Rail:** `body-sm` using `neutral_color_hex` at 70% opacity, terminating in `label-md` for the current view.
- **Section Headers:** `title-lg` with tight tracking for dashboard divisions (`Resumo dos Eventos`, `Gastos por Categoria`).
- **Table Headers:** `label-md` in uppercase or bolded sentence-case using M3 surface-variant contrast.
- **Line Items & Descriptions:** `body-md` for primary item labels (`Kit Decoração`), paired with `body-sm` for secondary categorization (`Escola`).

## Layout & Spacing

The layout model is divided into a persistent structural navigation rail/drawer on the left (280px fixed width on desktop; collapsible drawer on mobile/tablet) and a responsive fluid canvas on the right.

### Responsive Grid & Structure
- **Desktop (>= 1200px):** 12-column fluid grid inside the content canvas. Outer margins are `space-lg` (24px) with `gutter-lg` (24px) column gaps. The metric row scales across 4 equal-width cards (col-span-3 each). The main overview splits into a 2/3 column layout: `Resumo dos Eventos` spans 8 columns, while `Gastos por Categoria` spans 4 columns.
- **Tablet (768px – 1199px):** 8-column layout. Metric deck wraps into a 2x2 grid. Sidebar transitions to an M3 Navigation Rail (80px icon+label mode). 
- **Mobile (< 768px):** Single-column stacked layout. Navigation rail transitions to an M3 bottom navigation bar or modal drawer. Table components transform into responsive horizontal cards to prevent horizontal overflow issues (such as the category filter overflow seen in legacy views).

### Internal Component Spacing
- **Data Tables:** Cell padding is set to 14px vertical and 16px horizontal to ensure scannability without visual fatigue.
- **Cards & Modals:** Standard inner padding is `space-lg` (24px) for desktop containers and `space-md` (16px) on mobile viewports.
- **Form Groups:** Vertical spacing between input groups is strictly `space-md` (16px), with action button trays spaced by `space-sm` (8px).

## Elevation & Depth

Visual hierarchy conforms to the Material Design 3 elevation system, relying on surface color tonal steps supplemented by subtle, tinted ambient contact shadows rather than harsh drop shadows.

### Elevation Levels
- **Level 0 (Flat / Basal):** `surface` (`#F7FAF5`). Used for underlying window background and static page canvas. No shadow.
- **Level 1 (Card & Content Containers):** `surface-container-lowest` (`#FFFFFF`) with a 1px border using `outline-variant` (`rgba(193, 201, 191, 0.45)`). Shadow: `0px 1px 3px rgba(33, 115, 70, 0.05), 0px 1px 2px rgba(0, 0, 0, 0.04)`.
- **Level 2 (Hovered Cards & Interactive Table Rows):** Shadow: `0px 3px 6px rgba(33, 115, 70, 0.08), 0px 2px 4px rgba(0, 0, 0, 0.04)`. Background tint slightly shifts to `surface-container-low`.
- **Level 3 (Dropdown Menus, Popovers, Filter Menus):** Shadow: `0px 6px 12px rgba(0, 33, 14, 0.12), 0px 2px 4px rgba(0, 0, 0, 0.06)`. Surface: `surface-container-low`.
- **Level 4 (Dialogs & Creation Modals):** Used for `Adicionar Despesa`, `Editar Despesa`, and `Nova Categoria`. Backdrop blur `4px` with scrim `rgba(14, 25, 18, 0.40)`. Shadow: `0px 12px 24px rgba(0, 33, 14, 0.16)`.
- **Level 5 (Navigational Drawers & Floating Actions):** Maximum priority elevated states with high-clarity tonal contrast.

## Shapes

The design system implements M3’s expressive curved shape language, calibrated to roundedness level 2 for structured enterprise layouts.

### Geometry Token Allocation
- **Standard Cards & Modals (`rounded-lg`):** 16px (`1rem`) border radius on all KPI containers, summary cards, and popovers.
- **Data Table Wrappers (`rounded-lg`):** 16px (`1rem`) outer wrapper clipping, creating a smooth border boundary.
- **Buttons & Filter Chips (`rounded-xl` / Full Pill):** Primary action buttons (`+ Novo Evento`, `Salvar`), status badges (`Pago`, `Pendente`), and segmented filter tabs use 24px to 9999px fully rounded pill caps.
- **Form Input Fields & Dropdowns:** 8px (`0.5rem`) soft-edge rounding conforming to standard M3 filled and outlined text field geometry.
- **Progress Track Indicators:** 9999px rounded caps on linear progress bars for category allocation and budget consumption.

## Components

### 1. Navigation Rail & Sidebar
- **Brand Plaque:** Display `EventLedger` with an emerald badge indicator (`#217346`).
- **Navigation Items (`Painel de Despesas`, `Todas as Despesas`, `Categorias`, `Eventos Arquivados`):**
  - Inactive: Transparent background, `neutral_color_hex` icon and text, 48px height, 8px horizontal padding.
  - Active: Filled pill background using `primary-container` (`#A4F2BD`), icon and label styled with on-primary-container (`#00210E`), font weight semi-bold.
  - Item counter badges (`2`, `8`, `1`): Encapsulated inside `surface-container-high` rounded capsules.
- **Sidebar Action Button:** Full-width pill button (`+ Novo Evento`) pinned to bottom or top rail, filled with `#217346` and white text.

### 2. Action Bars & Breadcrumbs
- Breadcrumb route display (`Espaço de Trabalho / Painel de Despesas`) aligned left in `body-sm`.
- Action cluster aligned right containing:
  - `Importar`: Outlined pill button, 1px `outline-variant`, subtle hover fill.
  - `Exportar`: Outlined pill button with leading download tray icon.
  - `+ Novo Evento` or context action: Elevated primary pill button with drop shadow level 1.

### 3. Metric KPI Cards (Painel de Despesas)
- Container: Level 1 white surface with subtle 1px border. 
- Top row: Semantic label (`Total de Despesas`, `Total Pago`, `Saldo a Pagar`, `Orçamentos Combinados`) in muted `label-md`.
- Middle: Large financial value (`R$ 214,60`) in `headline-lg` tabular figures.
  - `Total Pago`: Highlighted in positive forest emerald (`#1E7D47`).
  - `Saldo a Pagar`: Highlighted in warning amber (`#B26A00`).
- Bottom caption: Secondary context (`42% do total quitado`, `R$ 785,40 de margem disponível`) in `body-sm`.

### 4. Filter Chips & Segmented Controls
- Segmented button groups (`Todas`, `Pagas`, `Pendentes`):
  - Container uses `surface-container` (`#EBEFE9`) with a 1px border.
  - Active segment: Elevated white surface with subtle shadow and `primary_color_hex` text with a leading checkmark icon (`✓ Todas`).
  - Inactive segments: Transparent background, medium-weight neutral text.
- Dropdown Filter (`Categoria: Todas as Categorias`):
  - M3 outlined style with a floating label to eliminate layout cut-off/overflow errors. Dropdown arrow icon nested neatly inside the right padded boundary.

### 5. Data Tables (Event Ledger & Category Tables)
- Outer container: `rounded-lg` clipped card with `outline-variant` boundary.
- Table Header: Background `#F1F5EF`, typography `label-md` in uppercase, vertical padding 12px.
- Table Rows:
  - Checkbox: M3 rounded checkbox with primary green checked fill.
  - Status Badge: Pill badge displaying `Pago` (green tint) or `Pendente` (amber tint).
  - Financial Data: Right-aligned tabular numerals with bold weight on totals.
  - Actions: Inline icon buttons (pencil for edit, red trash icon for delete) with circular hover ripple effects (`#217346` at 8% opacity).
  - Hover state: Row transitions to `surface-container-low` with a 150ms ease.

### 6. Progress Bars & Category Distribution
- Used in `Gastos por Categoria`.
- Header row with category icon, category title (`Decoração`, `Lembrancinhas`), and monetary total with percentage (`R$ 124,90 · 58%`).
- Progress track: Height 6px, rounded pill ends, background `surface-container-high`.
- Fill track: Dynamic thematic color (Primary Emerald `#217346` for dominant, Violet `#7B529A` and Rose `#B3406E` for auxiliary categories).

### 7. Form Controls & Dialogs (Modais de Adicionar/Editar Despesa e Categoria)
- Form Fields: Material 3 Outlined Text Field with 8px corner radius, focused outline 2px in `#217346`.
- Dialog Structure: Max width 480px, 24px padding, corner radius 20px, clear header title, explicit primary button (`Salvar` / `Confirmar`) and neutral text button (`Cancelar`).