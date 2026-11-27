import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../state/ledger_store.dart';
import '../theme/app_theme.dart';
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
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 4-column M3 KPI Cards deck
          Row(
            children: [
              Expanded(
                child: _KpiTile(
                  label: 'Total de Despesas',
                  value: currency.format(totalSpent),
                  detail:
                      '${store.totalExpenseCount} itens em ${store.events.length} eventos',
                  icon: Icons.payments_outlined,
                  iconColor: AppTheme.secondary,
                  iconBgColor: AppTheme.surfaceContainerHigh,
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
                  icon: Icons.check_circle_outline,
                  iconColor: AppTheme.primary,
                  iconBgColor: AppTheme.secondaryContainer,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _KpiTile(
                  label: 'Saldo a Pagar',
                  value: currency.format(totalUnpaid),
                  valueColor: totalUnpaid > 0
                      ? AppTheme.unpaidAmber
                      : AppTheme.onSurface,
                  detail: totalUnpaid > 0
                      ? 'Pagamentos pendentes'
                      : 'Todas as despesas quitadas',
                  icon: Icons.schedule_outlined,
                  iconColor: AppTheme.tertiary,
                  iconBgColor: AppTheme.tertiaryContainer.withOpacity(0.18),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _KpiTile(
                  label: 'Orçamentos Combinados',
                  value: currency.format(totalBudget),
                  detail: !store.hasAnyEventWithBudget
                      ? 'Sem metas estipuladas'
                      : totalBudget >= totalSpent
                          ? '${currency.format(totalBudget - totalSpent)} de margem disponível'
                          : '${currency.format(totalSpent - totalBudget)} acima do orçamento',
                  valueColor:
                      totalSpent > totalBudget && store.hasAnyEventWithBudget
                          ? AppTheme.overBudgetCrimson
                          : AppTheme.onSurface,
                  icon: Icons.pie_chart_outline,
                  iconColor: AppTheme.onSurfaceVariant,
                  iconBgColor: AppTheme.surfaceContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Main 2-column split (8 cols Events Summary, 4 cols Category Distribution)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 8,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Resumo dos Eventos',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.onSurface,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                SizedBox(height: 3),
                                Text(
                                  'Visão geral e monitoramento de saldo',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: AppTheme.secondary,
                                  ),
                                ),
                              ],
                            ),
                            FilledButton.tonalIcon(
                              onPressed: onCreateEvent,
                              icon: const Icon(Icons.add, size: 16),
                              label: const Text('Criar Evento'),
                              style: FilledButton.styleFrom(
                                backgroundColor: AppTheme.surfaceContainerLow,
                                foregroundColor: AppTheme.primary,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (store.events.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            child: Center(
                              child: Column(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: AppTheme.surfaceContainerHigh,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.event_outlined,
                                      color: AppTheme.secondary,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  const Text(
                                    'Nenhum evento pessoal criado ainda.',
                                    style: TextStyle(
                                      color: AppTheme.secondary,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  FilledButton(
                                    onPressed: onCreateEvent,
                                    child: const Text('Criar Primeiro Evento'),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Theme(
                              data: Theme.of(context).copyWith(
                                dividerTheme: DividerThemeData(
                                  color:
                                      AppTheme.outlineVariant.withOpacity(0.25),
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
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              width: 32,
                                              height: 32,
                                              decoration: BoxDecoration(
                                                color:
                                                    AppTheme.surfaceContainer,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: const Icon(
                                                Icons.celebration_outlined,
                                                size: 16,
                                                color: AppTheme.primary,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
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
                                                    fontSize: 13.5,
                                                    color: AppTheme.onSurface,
                                                  ),
                                                ),
                                                if (event.venue.isNotEmpty)
                                                  Text(
                                                    event.venue,
                                                    style: const TextStyle(
                                                      fontSize: 11.5,
                                                      color: AppTheme.secondary,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          dateFmt.format(event.eventDate),
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: AppTheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ),
                                      if (store.hasAnyEventWithBudget)
                                        DataCell(
                                          Text(
                                            event.hasBudget
                                                ? currency.format(event.budget)
                                                : '—',
                                            style:
                                                AppTheme.tabularNumber.copyWith(
                                              fontSize: 13,
                                              color: AppTheme.secondary,
                                            ),
                                          ),
                                        ),
                                      DataCell(
                                        Text(
                                          currency.format(event.totalSpent),
                                          style:
                                              AppTheme.tabularNumber.copyWith(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13,
                                            color: AppTheme.onSurface,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          currency.format(event.paidAmount),
                                          style:
                                              AppTheme.tabularNumber.copyWith(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                            color: AppTheme.paidGreen,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          currency.format(event.unpaidAmount),
                                          style:
                                              AppTheme.tabularNumber.copyWith(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                            color: event.unpaidAmount > 0
                                                ? AppTheme.unpaidAmber
                                                : AppTheme.secondary,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        IconButton(
                                          tooltip: 'Arquivar evento',
                                          icon: const Icon(
                                            Icons.archive_outlined,
                                            size: 18,
                                            color: AppTheme.secondary,
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
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                flex: 4,
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
    this.valueColor = AppTheme.onSurface,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
  });

  final String label;
  final String value;
  final String detail;
  final Color valueColor;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.secondary,
                  ),
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 16, color: iconColor),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: AppTheme.tabularNumber.copyWith(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: valueColor,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              detail,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
