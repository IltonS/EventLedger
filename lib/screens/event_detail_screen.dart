import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/event_models.dart';
import '../state/ledger_store.dart';
import '../theme/app_theme.dart';
import '../widgets/category_chart_card.dart';
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

  Future<void> _handleArchiveEvent() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Arquivar Evento'),
        content: Text(
          'Deseja arquivar o evento "${widget.event.name}"? '
          'Ele não será mais exibido no painel de despesas, mas continuará salvo e poderá ser gerenciado na tela de Eventos Arquivados.',
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Arquivar'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await widget.store.archiveEvent(widget.event.id);
      if (mounted) {
        showAppSnackBar(
          context,
          message: 'Evento "${widget.event.name}" arquivado com sucesso.',
          actionLabel: 'Desfazer',
          onAction: () => widget.store.unarchiveEvent(widget.event.id),
        );
      }
    }
  }

  Future<void> _handleUnarchiveEvent() async {
    await widget.store.unarchiveEvent(widget.event.id);
    if (mounted) {
      showAppSnackBar(
        context,
        message: 'Evento "${widget.event.name}" desarquivado com sucesso.',
      );
    }
  }

  Future<void> _handleDeleteEvent() async {
    final isArchived = widget.event.isArchived;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          isArchived ? 'Excluir evento definitivamente?' : 'Excluir evento?',
        ),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tem certeza que deseja excluir o evento "${widget.event.name}"?',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              Text(
                'Esta ação é permanente e removerá todas as ${widget.event.expenses.length} despesas cadastradas neste evento.',
                style: const TextStyle(color: AppTheme.secondary),
              ),
            ],
          ),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.overBudgetCrimson,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              isArchived ? 'Excluir Definitivamente' : 'Excluir',
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await widget.store.deleteEvent(widget.event.id);
      if (mounted) {
        showAppSnackBar(
          context,
          message: isArchived
              ? 'Evento "${widget.event.name}" excluído definitivamente.'
              : 'Evento "${widget.event.name}" excluído.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final dateFmt = DateFormat.yMMMd('pt_BR');
    final event = widget.event;
    final filtered = _filteredExpenses;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 700;
        final isTablet =
            constraints.maxWidth >= 700 && constraints.maxWidth < 1100;
        final padding = isMobile ? 16.0 : (isTablet ? 20.0 : 28.0);

        return SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (event.isArchived)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.unpaidAmberSurface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppTheme.unpaidAmber.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.archive_outlined,
                        color: AppTheme.unpaidAmber,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Este evento está arquivado. Ele não aparece no painel de despesas e suas métricas não são contabilizadas nos totais gerais.',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      FilledButton.tonalIcon(
                        onPressed: _handleUnarchiveEvent,
                        icon: const Icon(Icons.unarchive_outlined, size: 16),
                        label: const Text('Desarquivar Evento'),
                      ),
                    ],
                  ),
                ),

              // Event Summary Card
              Card(
                child: Padding(
                  padding: EdgeInsets.all(isMobile ? 16 : 22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (!isMobile)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildEventHeaderTexts(event, dateFmt),
                            ),
                            _buildEventActionButtons(event),
                          ],
                        )
                      else ...[
                        _buildEventHeaderTexts(event, dateFmt),
                        const SizedBox(height: 14),
                        _buildEventActionButtons(event, isMobile: true),
                      ],
                      const SizedBox(height: 18),
                      const Divider(height: 1),
                      const SizedBox(height: 16),
                      // Metrics row / grid
                      _buildEventMetrics(
                        event: event,
                        currency: currency,
                        isMobile: isMobile,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Content Area: Expenses Table/Cards + Category chart
              if (!isMobile && !isTablet)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: _buildExpenseTableCard(
                        context: context,
                        event: event,
                        filtered: filtered,
                        currency: currency,
                        dateFmt: dateFmt,
                        isMobile: false,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 2,
                      child: CategoryExpenseChartCard(
                        categoryTotals: event.categoryTotals,
                        totalSpent: event.totalSpent,
                      ),
                    ),
                  ],
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildExpenseTableCard(
                      context: context,
                      event: event,
                      filtered: filtered,
                      currency: currency,
                      dateFmt: dateFmt,
                      isMobile: isMobile,
                    ),
                    const SizedBox(height: 20),
                    CategoryExpenseChartCard(
                      categoryTotals: event.categoryTotals,
                      totalSpent: event.totalSpent,
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEventHeaderTexts(PersonalEvent event, DateFormat dateFmt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          event.name,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppTheme.onSurface,
            letterSpacing: -0.3,
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
            color: AppTheme.secondary,
          ),
        ),
      ],
    );
  }

  Widget _buildEventActionButtons(PersonalEvent event,
      {bool isMobile = false}) {
    if (isMobile) {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          OutlinedButton.icon(
            onPressed: _editEvent,
            icon: const Icon(Icons.edit_outlined, size: 15),
            label: const Text('Editar'),
          ),
          OutlinedButton.icon(
            onPressed: _handleArchiveEvent,
            icon: const Icon(Icons.archive_outlined, size: 15),
            label: const Text('Arquivar'),
          ),
          OutlinedButton.icon(
            onPressed: _handleDeleteEvent,
            icon: const Icon(Icons.delete_outline, size: 15),
            label: const Text('Excluir'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.overBudgetCrimson,
            ),
          ),
          FilledButton.icon(
            onPressed: _addExpense,
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Adicionar Despesa'),
          ),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (event.isArchived) ...[
          OutlinedButton.icon(
            onPressed: _handleUnarchiveEvent,
            icon: const Icon(Icons.unarchive_outlined, size: 16),
            label: const Text('Desarquivar'),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: _handleDeleteEvent,
            icon: const Icon(Icons.delete_forever_outlined, size: 16),
            label: const Text('Excluir Definitivamente'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.overBudgetCrimson,
              side: const BorderSide(color: AppTheme.overBudgetCrimson),
            ),
          ),
        ] else ...[
          OutlinedButton.icon(
            onPressed: _editEvent,
            icon: const Icon(Icons.edit_outlined, size: 16),
            label: const Text('Editar Evento'),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: _handleArchiveEvent,
            icon: const Icon(Icons.archive_outlined, size: 16),
            label: const Text('Arquivar'),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: _handleDeleteEvent,
            icon: const Icon(Icons.delete_outline, size: 16),
            label: const Text('Excluir'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.overBudgetCrimson,
            ),
          ),
        ],
        const SizedBox(width: 10),
        FilledButton.icon(
          onPressed: _addExpense,
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Adicionar Despesa'),
        ),
      ],
    );
  }

  Widget _buildEventMetrics({
    required PersonalEvent event,
    required NumberFormat currency,
    required bool isMobile,
  }) {
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              if (event.hasBudget) ...[
                Expanded(
                  child: _MetricPair(
                    label: 'Orçamento',
                    value: currency.format(event.budget),
                  ),
                ),
              ],
              Expanded(
                child: _MetricPair(
                  label: 'Total Gasto',
                  value: currency.format(event.totalSpent),
                  color: event.hasBudget && event.totalSpent > event.budget
                      ? AppTheme.overBudgetCrimson
                      : AppTheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MetricPair(
                  label: 'Pago',
                  value: currency.format(event.paidAmount),
                  color: AppTheme.paidGreen,
                ),
              ),
              Expanded(
                child: _MetricPair(
                  label: 'Pendente',
                  value: currency.format(event.unpaidAmount),
                  color: event.unpaidAmount > 0
                      ? AppTheme.unpaidAmber
                      : AppTheme.secondary,
                ),
              ),
            ],
          ),
          if (event.hasBudget) ...[
            const SizedBox(height: 14),
            Text(
              event.budgetRemaining >= 0
                  ? '${currency.format(event.budgetRemaining)} dentro do orçamento'
                  : '${currency.format(event.budgetRemaining.abs())} acima do orçamento',
              style: AppTheme.tabularNumber.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: event.budgetRemaining >= 0
                    ? AppTheme.secondary
                    : AppTheme.overBudgetCrimson,
              ),
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(9999),
              child: LinearProgressIndicator(
                value: event.budgetUtilization.clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: AppTheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  event.totalSpent > event.budget
                      ? AppTheme.overBudgetCrimson
                      : AppTheme.primary,
                ),
              ),
            ),
          ],
        ],
      );
    }

    return Row(
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
              : AppTheme.onSurface,
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
              : AppTheme.secondary,
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
                        ? AppTheme.secondary
                        : AppTheme.overBudgetCrimson,
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(9999),
                  child: LinearProgressIndicator(
                    value: event.budgetUtilization.clamp(0.0, 1.0),
                    minHeight: 6,
                    backgroundColor: AppTheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      event.totalSpent > event.budget
                          ? AppTheme.overBudgetCrimson
                          : AppTheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildExpenseTableCard({
    required BuildContext context,
    required PersonalEvent event,
    required List<ExpenseItem> filtered,
    required NumberFormat currency,
    required DateFormat dateFmt,
    required bool isMobile,
  }) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!isMobile)
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      SizedBox(
                        width: 200,
                        child: TextField(
                          onChanged: (v) => setState(() => _searchQuery = v),
                          decoration: const InputDecoration(
                            hintText: 'Buscar despesa...',
                            prefixIcon: Icon(Icons.search, size: 18),
                            isDense: true,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 190,
                        child: DropdownButtonFormField<ExpenseCategory?>(
                          isExpanded: true,
                          initialValue: _categoryFilter,
                          isDense: true,
                          decoration: const InputDecoration(
                            labelText: 'Categoria',
                            isDense: true,
                          ),
                          items: [
                            const DropdownMenuItem<ExpenseCategory?>(
                              value: null,
                              child: Text(
                                'Todas as Categorias',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            ...widget.store.categories.map(
                              (cat) => DropdownMenuItem<ExpenseCategory?>(
                                value: cat,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(cat.icon, size: 14, color: cat.color),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        cat.name,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                          onChanged: (v) => setState(() => _categoryFilter = v),
                        ),
                      ),
                    ],
                  ),
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
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: const InputDecoration(
                      hintText: 'Buscar despesa...',
                      prefixIcon: Icon(Icons.search, size: 18),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<ExpenseCategory?>(
                    isExpanded: true,
                    initialValue: _categoryFilter,
                    isDense: true,
                    decoration: const InputDecoration(
                      labelText: 'Categoria',
                      isDense: true,
                    ),
                    items: [
                      const DropdownMenuItem<ExpenseCategory?>(
                        value: null,
                        child: Text(
                          'Todas as Categorias',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      ...widget.store.categories.map(
                        (cat) => DropdownMenuItem<ExpenseCategory?>(
                          value: cat,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(cat.icon, size: 14, color: cat.color),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  cat.name,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    onChanged: (v) => setState(() => _categoryFilter = v),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<PaymentFilter>(
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
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: AppTheme.surfaceContainerHigh,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.receipt_long_outlined,
                          size: 24,
                          color: AppTheme.secondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Nenhuma despesa encontrada para este evento.',
                        style: TextStyle(color: AppTheme.secondary),
                      ),
                      const SizedBox(height: 14),
                      FilledButton.icon(
                        onPressed: _addExpense,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Adicionar Primeira Despesa'),
                      ),
                    ],
                  ),
                ),
              )
            else if (isMobile)
              // Mobile Expense Cards for Event Detail
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = filtered[index];
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.outlineVariant.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Checkbox(
                              value: item.isPaid,
                              onChanged: (_) => widget.store.toggleExpensePaid(
                                eventId: event.id,
                                expenseId: item.id,
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.onSurface,
                                      decoration: item.isPaid
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                                  ),
                                  if (item.vendor.isNotEmpty)
                                    Text(
                                      item.vendor,
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        color: AppTheme.secondary,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  currency.format(item.amount),
                                  style: AppTheme.tabularNumber.copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: item.isPaid
                                        ? AppTheme.paidGreenSurface
                                        : AppTheme.unpaidAmberSurface,
                                    borderRadius: BorderRadius.circular(9999),
                                  ),
                                  child: Text(
                                    item.isPaid ? 'Pago' : 'Pendente',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w600,
                                      color: item.isPaid
                                          ? AppTheme.paidGreenText
                                          : AppTheme.unpaidAmberText,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Divider(height: 1),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(item.category.icon,
                                    size: 14, color: item.category.color),
                                const SizedBox(width: 4),
                                Text(
                                  item.category.label,
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    color: AppTheme.secondary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '· ${dateFmt.format(item.date)}',
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    color: AppTheme.secondary,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: 'Editar',
                                  icon:
                                      const Icon(Icons.edit_outlined, size: 16),
                                  color: AppTheme.secondary,
                                  onPressed: () => _editExpense(item),
                                ),
                                IconButton(
                                  tooltip: 'Excluir',
                                  icon: const Icon(Icons.delete_outline,
                                      size: 16),
                                  color: AppTheme.overBudgetCrimson,
                                  onPressed: () => widget.store.deleteExpense(
                                    eventId: event.id,
                                    expenseId: item.id,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              )
            else
              // Desktop & Tablet DataTable
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Theme(
                  data: Theme.of(context).copyWith(
                    dividerTheme: DividerThemeData(
                      color: AppTheme.outlineVariant.withValues(alpha: 0.25),
                    ),
                  ),
                  child: DataTable(
                    horizontalMargin: 0,
                    columnSpacing: 22,
                    headingRowColor: WidgetStateProperty.all(
                      AppTheme.surfaceContainerLow,
                    ),
                    headingTextStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: AppTheme.secondary,
                    ),
                    columns: const [
                      DataColumn(label: Text('SITUAÇÃO')),
                      DataColumn(label: Text('DESPESA')),
                      DataColumn(label: Text('CATEGORIA')),
                      DataColumn(label: Text('DATA')),
                      DataColumn(label: Text('VALOR'), numeric: true),
                      DataColumn(label: Text('AÇÕES')),
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
                                  onChanged: (_) =>
                                      widget.store.toggleExpensePaid(
                                    eventId: event.id,
                                    expenseId: item.id,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: item.isPaid
                                        ? AppTheme.paidGreenSurface
                                        : AppTheme.unpaidAmberSurface,
                                    borderRadius: BorderRadius.circular(9999),
                                  ),
                                  child: Text(
                                    item.isPaid ? 'Pago' : 'Pendente',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      color: item.isPaid
                                          ? AppTheme.paidGreenText
                                          : AppTheme.unpaidAmberText,
                                    ),
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
                                    fontSize: 13,
                                    color: AppTheme.onSurface,
                                    decoration: item.isPaid
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                                if (item.vendor.isNotEmpty)
                                  Text(
                                    item.vendor,
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      color: AppTheme.secondary,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: item.category.color
                                        .withValues(alpha: 0.14),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Icon(
                                    item.category.icon,
                                    size: 14,
                                    color: item.category.color,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  item.category.label,
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          DataCell(Text(
                            dateFmt.format(item.date),
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: AppTheme.onSurfaceVariant,
                            ),
                          )),
                          DataCell(
                            Text(
                              currency.format(item.amount),
                              style: AppTheme.tabularNumber.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: AppTheme.onSurface,
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
                                    color: AppTheme.secondary,
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
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MetricPair extends StatelessWidget {
  const _MetricPair({
    required this.label,
    required this.value,
    this.color = AppTheme.onSurface,
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
          style: const TextStyle(fontSize: 11.5, color: AppTheme.secondary),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: AppTheme.tabularNumber.copyWith(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}
