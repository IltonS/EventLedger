import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/event_models.dart';
import '../state/ledger_store.dart';
import '../theme/app_theme.dart';

class AllExpensesScreen extends StatefulWidget {
  const AllExpensesScreen({super.key, required this.store});

  final LedgerStore store;

  @override
  State<AllExpensesScreen> createState() => _AllExpensesScreenState();
}

class _AllExpensesScreenState extends State<AllExpensesScreen> {
  ExpenseCategory? _categoryFilter;
  PaymentFilter _paymentFilter = PaymentFilter.all;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final dateFmt = DateFormat.yMMMd('pt_BR');

    final rows = <({PersonalEvent event, ExpenseItem item})>[];
    for (final event in widget.store.events) {
      for (final item in event.expenses) {
        if (_categoryFilter != null && item.category != _categoryFilter) {
          continue;
        }
        if (_paymentFilter == PaymentFilter.paid && !item.isPaid) continue;
        if (_paymentFilter == PaymentFilter.unpaid && item.isPaid) continue;
        if (_searchQuery.trim().isNotEmpty) {
          final q = _searchQuery.toLowerCase();
          final matchTitle = item.title.toLowerCase().contains(q);
          final matchVendor = item.vendor.toLowerCase().contains(q);
          final matchEvent = event.name.toLowerCase().contains(q);
          if (!matchTitle && !matchVendor && !matchEvent) continue;
        }
        rows.add((event: event, item: item));
      }
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 700;
        final padding = isMobile ? 16.0 : 28.0;

        return SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 16 : 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header & Controls
                  if (!isMobile)
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Todas as Despesas',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.onSurface,
                                letterSpacing: -0.2,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'Registro consolidado de todas as despesas lançadas',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: AppTheme.secondary,
                              ),
                            ),
                          ],
                        ),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            SizedBox(
                              width: 190,
                              child: TextField(
                                onChanged: (v) =>
                                    setState(() => _searchQuery = v),
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
                                          Icon(cat.icon,
                                              size: 14, color: cat.color),
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
                                onChanged: (v) =>
                                    setState(() => _categoryFilter = v),
                              ),
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
                        ),
                      ],
                    )
                  else
                    // Mobile Controls (stacked vertically)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Todas as Despesas',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.onSurface,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          onChanged: (v) => setState(() => _searchQuery = v),
                          decoration: const InputDecoration(
                            hintText: 'Buscar despesa ou evento...',
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
                  const SizedBox(height: 18),
                  if (rows.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
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
                            const SizedBox(height: 14),
                            const Text(
                              'Nenhuma despesa corresponde aos filtros selecionados.',
                              style: TextStyle(color: AppTheme.secondary),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (isMobile)
                    // Mobile Cards View
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: rows.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final entry = rows[index];
                        return _buildMobileExpenseCard(
                          entry: entry,
                          currency: currency,
                          dateFmt: dateFmt,
                        );
                      },
                    )
                  else
                    // Desktop / Tablet DataTable
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          dividerTheme: DividerThemeData(
                            color:
                                AppTheme.outlineVariant.withValues(alpha: 0.25),
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
                            DataColumn(label: Text('EVENTO')),
                            DataColumn(label: Text('CATEGORIA')),
                            DataColumn(label: Text('DATA')),
                            DataColumn(label: Text('VALOR'), numeric: true),
                          ],
                          rows: rows.map((entry) {
                            return DataRow(
                              cells: [
                                DataCell(
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Checkbox(
                                        value: entry.item.isPaid,
                                        onChanged: (_) =>
                                            widget.store.toggleExpensePaid(
                                          eventId: entry.event.id,
                                          expenseId: entry.item.id,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: entry.item.isPaid
                                              ? AppTheme.paidGreenSurface
                                              : AppTheme.unpaidAmberSurface,
                                          borderRadius:
                                              BorderRadius.circular(9999),
                                        ),
                                        child: Text(
                                          entry.item.isPaid
                                              ? 'Pago'
                                              : 'Pendente',
                                          style: TextStyle(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w600,
                                            color: entry.item.isPaid
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        entry.item.title,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                          color: AppTheme.onSurface,
                                          decoration: entry.item.isPaid
                                              ? TextDecoration.lineThrough
                                              : null,
                                        ),
                                      ),
                                      if (entry.item.vendor.isNotEmpty)
                                        Text(
                                          entry.item.vendor,
                                          style: const TextStyle(
                                            fontSize: 11.5,
                                            color: AppTheme.secondary,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                DataCell(
                                  InkWell(
                                    borderRadius: BorderRadius.circular(6),
                                    onTap: () => widget.store
                                        .selectEvent(entry.event.id),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                        vertical: 2,
                                      ),
                                      child: Text(
                                        entry.event.name,
                                        style: const TextStyle(
                                          color: AppTheme.primary,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
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
                                          color: entry.item.category.color
                                              .withValues(alpha: 0.14),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Icon(
                                          entry.item.category.icon,
                                          size: 14,
                                          color: entry.item.category.color,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        entry.item.category.label,
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    dateFmt.format(entry.item.date),
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      color: AppTheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    currency.format(entry.item.amount),
                                    style: AppTheme.tabularNumber.copyWith(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                      color: AppTheme.onSurface,
                                    ),
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
          ),
        );
      },
    );
  }

  Widget _buildMobileExpenseCard({
    required ({PersonalEvent event, ExpenseItem item}) entry,
    required NumberFormat currency,
    required DateFormat dateFmt,
  }) {
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
                value: entry.item.isPaid,
                onChanged: (_) => widget.store.toggleExpensePaid(
                  eventId: entry.event.id,
                  expenseId: entry.item.id,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.item.title,
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.onSurface,
                        decoration: entry.item.isPaid
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    InkWell(
                      onTap: () => widget.store.selectEvent(entry.event.id),
                      child: Text(
                        entry.event.name,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    currency.format(entry.item.amount),
                    style: AppTheme.tabularNumber.copyWith(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: entry.item.isPaid
                          ? AppTheme.paidGreenSurface
                          : AppTheme.unpaidAmberSurface,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Text(
                      entry.item.isPaid ? 'Pago' : 'Pendente',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: entry.item.isPaid
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
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    entry.item.category.icon,
                    size: 14,
                    color: entry.item.category.color,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    entry.item.category.label,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppTheme.secondary,
                    ),
                  ),
                ],
              ),
              Text(
                dateFmt.format(entry.item.date),
                style: const TextStyle(
                  fontSize: 11.5,
                  color: AppTheme.secondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
