# EventLedger — Project Brief & Product Requirements Document (PRD)

## 1. Overview
**EventLedger** is a personal event budget and expense tracking application. This project is a comprehensive UI/UX redesign of an existing Dart/Flutter desktop application, translating its core functionality into a modern, responsive **Google Material Design 3 (M3)** experience across **Desktop**, **Tablet**, and **Mobile** viewports.

### Core Constraint
- **Feature Parity Only**: No new features were added. All existing workflows, data fields, and actions from the original Flutter application are preserved with improved visual hierarchy, accessibility, and responsive ergonomics.

---

## 2. Design System: Forest Ledger M3
- **Visual Language**: Google Material Design 3 (M3)
- **Primary Color**: `#217346` (Forest Green)
- **Color Mode**: Light Mode with tonal surface containers (`#f4fcf2` surface, `#ffffff` lowest container, `#eef6ec` low container)
- **Typography**: `Inter`
- **Corner Radius**: `8px` (`ROUND_EIGHT`) for inputs/cards, `28px` (`rounded-3xl`) for M3 dialogs and bottom sheets.

---

## 3. Target Platforms & Responsive Strategy
| Platform | Navigation Pattern | Modal Presentation |
| :--- | :--- | :--- |
| **Desktop** | Persistent Left Sidebar + Top Header Bar | Centered M3 Dialogs with soft backdrop blur |
| **Tablet** | Collapsible/Compact Left Rail + Top Header Bar | Floating Medium M3 Dialogs |
| **Mobile** | Top App Bar + Fixed Bottom Tab Navigation (4 tabs) / Stack Header for sub-views | M3 Modal Bottom Sheets with drag handle |

---

## 4. Core Screens & Information Architecture

### 4.1 Painel de Despesas (Expense Dashboard)
- **KPI Summary Cards**: Total de Despesas, Total Pago, Saldo a Pagar, Orçamentos Combinados.
- **Resumo dos Eventos**: List of active personal events with date, budget, total spent, paid, pending, and quick actions.
- **Gastos por Categoria**: Horizontal progress breakdown of spending by category.

### 4.2 Todas as Despesas (All Expenses)
- Unified ledger of expenses across all events.
- **Controls**: Search bar, Category dropdown filter, Status segmented filter (*Todas*, *Pagas*, *Pendentes*).
- **Table/List**: Status checkbox (*Pago* / *Pendente*), Expense name, Event link, Category badge, Date, and Value.

### 4.3 Categorias de Despesas (Expense Categories)
- **Summary Cards**: Total de Categorias, Total em Despesas, Maior Categoria de Gasto.
- **Category List**: Displays category icon, name, expense count, total spent, percentage of total, and Edit/Delete actions.

### 4.4 Detalhes do Evento (Event Details)
- Event header with metadata (date, location, paid count) and actions (*Editar Evento*, *Arquivar*, *Excluir*, *+ Adicionar Despesa*).
- Event-level KPIs: Orçamento, Total Gasto, Pago, Pendente, and budget progress bar.
- Filtered expense table for the specific event + Category spending breakdown.

---

## 5. Modals & Dialogs
1. **Adicionar / Editar Despesa**:
   - Fields: *Descrição da Despesa*, *Categoria* (icon dropdown), *Valor (R$)*, *Fornecedor*, *Data da Despesa*, and *Marcar como Pago* switch.
   - Actions: *Cancelar*, *Adicionar/Salvar Despesa*.
2. **Nova / Editar Categoria de Despesa**:
   - Live preview card showing selected icon, color, and name.
   - Fields: *Nome da Categoria*, *Cor Temática* (circular color palette), *Ícone Representativo* (24-icon M3 grid).
   - Actions: *Cancelar*, *Criar/Salvar Categoria*.
3. **Criar Evento Pessoal**:
   - Fields: *Nome do Evento* (required), *Local / Espaço*, *Orçamento Previsto (R$)*, *Data do Evento*, *Observações do Evento*.
   - Actions: *Cancelar*, *Criar Evento*.
4. **Confirmar Exclusão**:
   - Destructive confirmation dialog with warning icon, safety status banner (e.g., *"Nenhuma despesa está utilizando esta categoria no momento"*), and destructive *Excluir* / *Cancelar* actions.

---

## 6. Deliverables Summary
- **24 Redesigned Screens** on the Canvas:
  - 4 Core Screens × 3 Breakpoints (Desktop, Tablet, Mobile) = 12 screens
  - 4 Modals × 3 Breakpoints (Desktop, Tablet, Mobile) = 12 screens
- **1 Design System** (`Forest Ledger M3`)
