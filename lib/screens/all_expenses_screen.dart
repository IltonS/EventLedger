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
      padding: const EdgeInsets.all(28),
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
                      fontSize: 18,
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
                        ...ExpenseCategory.values.map(
                          (cat) => DropdownMenuItem<ExpenseCategory?>(
                            value: cat,
                            child: Text(cat.label),
                          ),
                        ),
                      ],
                      onChanged: (v) => setState(() => _categoryFilter = v),
                    ),
                  ),
                  const SizedBox(width: 12),
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
                  headingTextStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.inkMuted,
                  ),
                  columns: const [
                    DataColumn(label: Text('Pago')),
                    DataColumn(label: Text('Despesa')),
                    DataColumn(label: Text('Evento')),
                    DataColumn(label: Text('Categoria')),
                    DataColumn(label: Text('Data')),
                    DataColumn(label: Text('Valor'), numeric: true),
                  ],
                  rows: rows.map((entry) {
                    return DataRow(
                      cells: [
                        DataCell(
                          Checkbox(
                            value: entry.item.isPaid,
                            activeColor: AppTheme.paidGreen,
                            onChanged: (_) => widget.store.toggleExpensePaid(
                              eventId: entry.event.id,
                              expenseId: entry.item.id,
                            ),
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
