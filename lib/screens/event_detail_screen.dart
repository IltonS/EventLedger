import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/event_models.dart';
import '../state/ledger_store.dart';
import '../theme/app_theme.dart';
import '../widgets/dialogs.dart';

class EventDetailScreen extends StatefulWidget {
  const EventDetailScreen({
    super.key,
    required this.store,
    required this.event,
  });

  final LedgerStore store;
  final PersonalEvent event;

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  String _searchQuery = '';
  ExpenseCategory? _categoryFilter;
  PaymentFilter _paymentFilter = PaymentFilter.all;

  List<ExpenseItem> get _filteredExpenses {
    return widget.event.expenses.where((item) {
      if (_categoryFilter != null && item.category != _categoryFilter) {
        return false;
      }
      if (_paymentFilter == PaymentFilter.paid && !item.isPaid) return false;
      if (_paymentFilter == PaymentFilter.unpaid && item.isPaid) return false;
      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchTitle = item.title.toLowerCase().contains(q);
        final matchVendor = item.vendor.toLowerCase().contains(q);
        if (!matchTitle && !matchVendor) return false;
      }
      return true;
    }).toList();
  }

  Future<void> _addExpense() async {
    final result = await showExpenseFormDialog(
      context,
      categories: widget.store.categories,
    );
    if (result == null) return;
    await widget.store.addExpense(
      eventId: widget.event.id,
      title: result.title,
      vendor: result.vendor,
      amount: result.amount,
      category: result.category,
      date: result.date,
      isPaid: result.isPaid,
      notes: result.notes,
    );
  }

  Future<void> _editExpense(ExpenseItem item) async {
    final result = await showExpenseFormDialog(
      context,
      existing: item,
      categories: widget.store.categories,
    );
    if (result == null) return;
    await widget.store.updateExpense(
      eventId: widget.event.id,
      updated: item.copyWith(
        title: result.title,
        vendor: result.vendor,
        amount: result.amount,
        category: result.category,
        date: result.date,
        isPaid: result.isPaid,
        notes: result.notes,
      ),
    );
  }

  Future<void> _editEvent() async {
    final result = await showEventFormDialog(context, existing: widget.event);
    if (result == null) return;
    await widget.store.updateEvent(
      widget.event.copyWith(
        name: result.name,
        eventDate: result.eventDate,
        venue: result.venue,
        budget: result.budget,
        notes: result.notes,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final dateFmt = DateFormat.yMMMd('pt_BR');
    final event = widget.event;
    final filtered = _filteredExpenses;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.name,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.inkPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              [
                                dateFmt.format(event.eventDate),
                                if (event.venue.isNotEmpty) event.venue,
                                '${event.paidCount} de ${event.expenses.length} despesas pagas',
                              ].join(' · '),
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.inkMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: _editEvent,
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        label: const Text('Editar Evento'),
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton.icon(
                        onPressed: () => widget.store.deleteEvent(event.id),
                        icon: const Icon(Icons.delete_outline, size: 16),
                        label: const Text('Excluir'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.overBudgetCrimson,
                        ),
                      ),
                      const SizedBox(width: 10),
                      FilledButton.icon(
                        onPressed: _addExpense,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Adicionar Despesa'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(height: 1),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      if (event.hasBudget) ...[
                        _MetricPair(
                          label: 'Orçamento',
                          value: currency.format(event.budget),
                        ),
                        const SizedBox(width: 36),
                      ],
                      _MetricPair(
                        label: 'Total Gasto',
                        value: currency.format(event.totalSpent),
                        color: event.hasBudget && event.totalSpent > event.budget
                            ? AppTheme.overBudgetCrimson
                            : AppTheme.inkPrimary,
                      ),
                      const SizedBox(width: 36),
                      _MetricPair(
                        label: 'Pago',
                        value: currency.format(event.paidAmount),
                        color: AppTheme.paidGreen,
                      ),
                      const SizedBox(width: 36),
                      _MetricPair(
                        label: 'Pendente',
                        value: currency.format(event.unpaidAmount),
                        color: event.unpaidAmount > 0
                            ? AppTheme.unpaidAmber
                            : AppTheme.inkMuted,
                      ),
                      if (event.hasBudget) ...[
                        const Spacer(),
                        SizedBox(
                          width: 240,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                event.budgetRemaining >= 0
                                    ? '${currency.format(event.budgetRemaining)} dentro do orçamento'
                                    : '${currency.format(event.budgetRemaining.abs())} acima do orçamento',
                                style: AppTheme.tabularNumber.copyWith(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: event.budgetRemaining >= 0
                                      ? AppTheme.inkSecondary
                                      : AppTheme.overBudgetCrimson,
                                ),
                              ),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: event.budgetUtilization.clamp(0.0, 1.0),
                                  minHeight: 7,
                                  backgroundColor: AppTheme.canvas,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    event.totalSpent > event.budget
                                        ? AppTheme.overBudgetCrimson
                                        : AppTheme.accent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 260,
                        child: TextField(
                          onChanged: (v) => setState(() => _searchQuery = v),
                          decoration: const InputDecoration(
                            hintText: 'Buscar despesa ou fornecedor...',
                            prefixIcon: Icon(Icons.search, size: 18),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 220,
                        child: DropdownButtonFormField<ExpenseCategory?>(
                          initialValue: _categoryFilter,
                          isDense: true,
                          decoration: const InputDecoration(
                            labelText: 'Categoria',
                            isDense: true,
                          ),
                          items: [
                            const DropdownMenuItem<ExpenseCategory?>(
                              value: null,
                              child: Text('Todas as Categorias'),
                            ),
                            ...widget.store.categories.map(
                              (cat) => DropdownMenuItem<ExpenseCategory?>(
                                value: cat,
                                child: Text(cat.name),
                              ),
                            ),
                          ],
                          onChanged: (v) => setState(() => _categoryFilter = v),
                        ),
                      ),
                      const Spacer(),
                      SegmentedButton<PaymentFilter>(
                        segments: const [
                          ButtonSegment(
                            value: PaymentFilter.all,
                            label: Text('Todas'),
                          ),
                          ButtonSegment(
                            value: PaymentFilter.paid,
                            label: Text('Pagas'),
                          ),
                          ButtonSegment(
                            value: PaymentFilter.unpaid,
                            label: Text('Pendentes'),
                          ),
                        ],
                        selected: {_paymentFilter},
                        onSelectionChanged: (values) {
                          setState(() => _paymentFilter = values.first);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (filtered.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 36),
                      child: Center(
                        child: Column(
                          children: [
                            const Text(
                              'Nenhuma despesa encontrada para este evento.',
                              style: TextStyle(color: AppTheme.inkMuted),
                            ),
                            const SizedBox(height: 12),
                            FilledButton.icon(
                              onPressed: _addExpense,
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('Adicionar Primeira Despesa'),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    DataTable(
                      horizontalMargin: 0,
                      columnSpacing: 20,
                      headingTextStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.inkMuted,
                      ),
                      columns: const [
                        DataColumn(label: Text('Situação')),
                        DataColumn(label: Text('Despesa')),
                        DataColumn(label: Text('Categoria')),
                        DataColumn(label: Text('Data')),
                        DataColumn(label: Text('Valor'), numeric: true),
                        DataColumn(label: Text('Ações')),
                      ],
                      rows: filtered.map((item) {
                        return DataRow(
                          cells: [
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Checkbox(
                                    value: item.isPaid,
                                    activeColor: AppTheme.paidGreen,
                                    onChanged: (_) =>
                                        widget.store.toggleExpensePaid(
                                      eventId: event.id,
                                      expenseId: item.id,
                                    ),
                                  ),
                                  Text(
                                    item.isPaid ? 'Pago' : 'Pendente',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                      color: item.isPaid
                                          ? AppTheme.paidGreen
                                          : AppTheme.unpaidAmber,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            DataCell(
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.inkPrimary,
                                      decoration: item.isPaid
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                                  ),
                                  if (item.vendor.isNotEmpty)
                                    Text(
                                      item.vendor,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.inkMuted,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    item.category.icon,
                                    size: 16,
                                    color: item.category.color,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(item.category.label),
                                ],
                              ),
                            ),
                            DataCell(Text(dateFmt.format(item.date))),
                            DataCell(
                              Text(
                                currency.format(item.amount),
                                style: AppTheme.tabularNumber.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    tooltip: 'Editar Despesa',
                                    icon: const Icon(
                                      Icons.edit_outlined,
                                      size: 18,
                                    ),
                                    onPressed: () => _editExpense(item),
                                  ),
                                  IconButton(
                                    tooltip: 'Excluir Despesa',
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      size: 18,
                                    ),
                                    color: AppTheme.overBudgetCrimson,
                                    onPressed: () => widget.store.deleteExpense(
                                      eventId: event.id,
                                      expenseId: item.id,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricPair extends StatelessWidget {
  const _MetricPair({
    required this.label,
    required this.value,
    this.color = AppTheme.inkPrimary,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppTheme.inkMuted),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTheme.tabularNumber.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}
