import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/event_models.dart';
import '../state/ledger_store.dart';
import '../theme/app_theme.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    required this.store,
    required this.onCreateEvent,
  });

  final LedgerStore store;
  final VoidCallback onCreateEvent;

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final dateFmt = DateFormat.yMMMd('pt_BR');
    final totalBudget = store.totalBudgetAllEvents;
    final totalSpent = store.totalSpentAllEvents;
    final totalPaid = store.totalPaidAllEvents;
    final totalUnpaid = store.totalUnpaidAllEvents;
    final categoryEntries = store.aggregatedCategoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: _KpiTile(
                  label: 'Total de Despesas',
                  value: currency.format(totalSpent),
                  detail:
                      '${store.totalExpenseCount} itens em ${store.events.length} eventos',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _KpiTile(
                  label: 'Total Pago',
                  value: currency.format(totalPaid),
                  valueColor: AppTheme.paidGreen,
                  detail: totalSpent > 0
                      ? '${((totalPaid / totalSpent) * 100).toStringAsFixed(0)}% do total quitado'
                      : 'Nenhuma despesa lançada',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _KpiTile(
                  label: 'Saldo a Pagar',
                  value: currency.format(totalUnpaid),
                  valueColor: totalUnpaid > 0
                      ? AppTheme.unpaidAmber
                      : AppTheme.inkPrimary,
                  detail: totalUnpaid > 0
                      ? 'Pagamentos pendentes'
                      : 'Todas as despesas quitadas',
                ),
              ),
              if (store.hasAnyEventWithBudget) ...[
                const SizedBox(width: 16),
                Expanded(
                  child: _KpiTile(
                    label: 'Orçamentos Combinados',
                    value: currency.format(totalBudget),
                    detail: totalBudget >= totalSpent
                        ? '${currency.format(totalBudget - totalSpent)} de margem disponível'
                        : '${currency.format(totalSpent - totalBudget)} acima do orçamento',
                    valueColor: totalSpent > totalBudget
                        ? AppTheme.overBudgetCrimson
                        : AppTheme.inkPrimary,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Resumo dos Eventos',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.inkPrimary,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: onCreateEvent,
                              icon: const Icon(Icons.add, size: 16),
                              label: const Text('Criar Evento'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (store.events.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 32),
                            child: Center(
                              child: Column(
                                children: [
                                  const Text(
                                    'Nenhum evento pessoal criado ainda.',
                                    style: TextStyle(color: AppTheme.inkMuted),
                                  ),
                                  const SizedBox(height: 12),
                                  FilledButton(
                                    onPressed: onCreateEvent,
                                    child: const Text('Criar Primeiro Evento'),
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
                            columns: [
                              const DataColumn(label: Text('Evento')),
                              const DataColumn(label: Text('Data')),
                              if (store.hasAnyEventWithBudget)
                                const DataColumn(
                                  label: Text('Orçamento'),
                                  numeric: true,
                                ),
                              const DataColumn(
                                label: Text('Total Gasto'),
                                numeric: true,
                              ),
                              const DataColumn(
                                label: Text('Pago'),
                                numeric: true,
                              ),
                              const DataColumn(
                                label: Text('Pendente'),
                                numeric: true,
                              ),
                            ],
                            rows: store.events.map((event) {
                              return DataRow(
                                onSelectChanged: (_) =>
                                    store.selectEvent(event.id),
                                cells: [
                                  DataCell(
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          event.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.inkPrimary,
                                          ),
                                        ),
                                        if (event.venue.isNotEmpty)
                                          Text(
                                            event.venue,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppTheme.inkMuted,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  DataCell(Text(dateFmt.format(event.eventDate))),
                                  if (store.hasAnyEventWithBudget)
                                    DataCell(
                                      Text(
                                        event.hasBudget
                                            ? currency.format(event.budget)
                                            : '—',
                                        style: AppTheme.tabularNumber,
                                      ),
                                    ),
                                  DataCell(
                                    Text(
                                      currency.format(event.totalSpent),
                                      style: AppTheme.tabularNumber.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      currency.format(event.paidAmount),
                                      style: AppTheme.tabularNumber.copyWith(
                                        color: AppTheme.paidGreen,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      currency.format(event.unpaidAmount),
                                      style: AppTheme.tabularNumber.copyWith(
                                        color: event.unpaidAmount > 0
                                            ? AppTheme.unpaidAmber
                                            : AppTheme.inkMuted,
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
              ),
              const SizedBox(width: 20),
              Expanded(
                flex: 2,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Gastos por Categoria',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.inkPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (categoryEntries.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Text(
                              'Adicione despesas para visualizar os totais por categoria.',
                              style: TextStyle(color: AppTheme.inkMuted),
                            ),
                          )
                        else
                          ...categoryEntries.map((entry) {
                            final share = totalSpent > 0
                                ? (entry.value / totalSpent).clamp(0.0, 1.0)
                                : 0.0;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            entry.key.icon,
                                            size: 16,
                                            color: entry.key.color,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            entry.key.label,
                                            style: const TextStyle(
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        '${currency.format(entry.value)} · ${(share * 100).toStringAsFixed(0)}%',
                                        style: AppTheme.tabularNumber.copyWith(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: AppTheme.inkSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: share,
                                      minHeight: 7,
                                      backgroundColor: AppTheme.canvas,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        entry.key.color,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _KpiTile extends StatelessWidget {
  const _KpiTile({
    required this.label,
    required this.value,
    required this.detail,
    this.valueColor = AppTheme.inkPrimary,
  });

  final String label;
  final String value;
  final String detail;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: AppTheme.inkMuted,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTheme.tabularNumber.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: valueColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              detail,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.inkSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
