import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/event_models.dart';
import '../state/ledger_store.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class AllExpensesScreen extends StatefulWidget {
  const AllExpensesScreen({super.key, required this.store});

  final LedgerStore store;

  @override
  State<AllExpensesScreen> createState() => _AllExpensesScreenState();
}

class _AllExpensesScreenState extends State<AllExpensesScreen> {
  ExpenseCategory? _categoryFilter;
  PaymentFilter _paymentFilter = PaymentFilter.all;

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
        rows.add((event: event, item: item));
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Text(
                    'Todas as Despesas dos Eventos',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.inkPrimary,
                    ),
                  ),
                  const Spacer(),
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
                  const SizedBox(width: 12),
                  SegmentedFilterBar<PaymentFilter>(
                    options: const {
                      PaymentFilter.all: 'Todas',
                      PaymentFilter.paid: 'Pagas',
                      PaymentFilter.unpaid: 'Pendentes',
                    },
                    selected: _paymentFilter,
                    onChanged: (v) => setState(() => _paymentFilter = v),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (rows.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Text(
                      'Nenhuma despesa corresponde aos filtros selecionados.',
                      style: TextStyle(color: AppTheme.inkMuted),
                    ),
                  ),
                )
              else
                DataTable(
                  horizontalMargin: 0,
                  columnSpacing: 20,
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
                              const SizedBox(width: 4),
                              StatusBadge.forPaid(entry.item.isPaid),
                            ],
                          ),
                        ),
                        DataCell(Text(entry.item.title)),
                        DataCell(
                          InkWell(
                            onTap: () =>
                                widget.store.selectEvent(entry.event.id),
                            child: Text(
                              entry.event.name,
                              style: const TextStyle(
                                color: AppTheme.accent,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        DataCell(Text(entry.item.category.label)),
                        DataCell(Text(dateFmt.format(entry.item.date))),
                        DataCell(
                          Text(
                            currency.format(entry.item.amount),
                            style: AppTheme.tabularNumber.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
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
    );
  }
}
