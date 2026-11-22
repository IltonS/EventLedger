import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../state/ledger_store.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/category_chart_card.dart';
import '../widgets/dialogs.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    required this.store,
    required this.onCreateEvent,
  });

  final LedgerStore store;
  final VoidCallback onCreateEvent;

  Future<void> _handleArchive(
    BuildContext context,
    String eventId,
    String eventName,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Arquivar Evento'),
        content: Text(
          'Deseja arquivar o evento "$eventName"? Ele deixará de ser exibido no painel de despesas e nos cálculos do dashboard.',
        ),
        actions: [
          TextButton(
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

    if (confirmed == true) {
      await store.archiveEvent(eventId);
      if (context.mounted) {
        showAppSnackBar(
          context,
          message: 'Evento "$eventName" arquivado com sucesso.',
          actionLabel: 'Desfazer',
          onAction: () => store.unarchiveEvent(eventId),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final dateFmt = DateFormat.yMMMd('pt_BR');
    final totalBudget = store.totalBudgetAllEvents;
    final totalSpent = store.totalSpentAllEvents;
    final totalPaid = store.totalPaidAllEvents;
    final totalUnpaid = store.totalUnpaidAllEvents;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
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
                  progress: totalSpent > 0 ? totalPaid / totalSpent : 0,
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
                  progress: totalSpent > 0 ? totalUnpaid / totalSpent : 0,
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
                    progress: totalBudget > 0 ? totalSpent / totalBudget : 0,
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
                            columns: [
                              const DataColumn(label: Text('EVENTO')),
                              const DataColumn(label: Text('DATA')),
                              if (store.hasAnyEventWithBudget)
                                const DataColumn(
                                  label: Text('ORÇAMENTO'),
                                  numeric: true,
                                ),
                              const DataColumn(
                                label: Text('TOTAL GASTO'),
                                numeric: true,
                              ),
                              const DataColumn(
                                label: Text('PAGO'),
                                numeric: true,
                              ),
                              const DataColumn(
                                label: Text('PENDENTE'),
                                numeric: true,
                              ),
                              const DataColumn(label: Text('AÇÕES')),
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
                                  DataCell(
                                      Text(dateFmt.format(event.eventDate))),
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
                                  DataCell(
                                    IconButton(
                                      tooltip: 'Arquivar evento',
                                      icon: const Icon(
                                        Icons.archive_outlined,
                                        size: 18,
                                      ),
                                      onPressed: () => _handleArchive(
                                        context,
                                        event.id,
                                        event.name,
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
                child: CategoryExpenseChartCard(
                  categoryTotals: store.aggregatedCategoryTotals,
                  totalSpent: totalSpent,
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
    this.progress,
  });

  final String label;
  final String value;
  final String detail;
  final Color valueColor;

  /// Optional 0..1 progress shown as a slim bar (e.g. percentage settled).
  final double? progress;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
                color: AppTheme.inkMuted,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: AppTheme.tabularNumber.copyWith(
                fontSize: 24,
                height: 32 / 24,
                fontWeight: FontWeight.w700,
                color: valueColor,
              ),
            ),
            const SizedBox(height: 10),
            if (progress != null) ...[
              LedgerProgressBar(value: progress!, color: valueColor),
              const SizedBox(height: 8),
            ],
            Text(
              detail,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.inkMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
