import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/event_models.dart';
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 650;
        final isTablet =
            constraints.maxWidth >= 650 && constraints.maxWidth < 1050;
        final padding = isMobile ? 16.0 : (isTablet ? 20.0 : 28.0);

        return SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // KPI Deck: 4 equal cols (Desktop), 2x2 Grid (Tablet & Mobile)
              _buildKpiDeck(
                currency: currency,
                totalSpent: totalSpent,
                totalPaid: totalPaid,
                totalUnpaid: totalUnpaid,
                totalBudget: totalBudget,
                isMobile: isMobile,
                isTablet: isTablet,
              ),
              const SizedBox(height: 20),

              // Main section layout:
              // Desktop: 8 cols left, 4 cols right
              // Tablet / Mobile: stacked (Events summary then Category breakdown)
              if (!isMobile && !isTablet)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 8,
                      child: _buildEventsCard(
                        context: context,
                        currency: currency,
                        dateFmt: dateFmt,
                        isMobile: false,
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
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildEventsCard(
                      context: context,
                      currency: currency,
                      dateFmt: dateFmt,
                      isMobile: isMobile,
                    ),
                    const SizedBox(height: 20),
                    CategoryExpenseChartCard(
                      categoryTotals: store.aggregatedCategoryTotals,
                      totalSpent: totalSpent,
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildKpiDeck({
    required NumberFormat currency,
    required double totalSpent,
    required double totalPaid,
    required double totalUnpaid,
    required double totalBudget,
    required bool isMobile,
    required bool isTablet,
  }) {
    final kpiItems = [
      _KpiTile(
        label: 'Total de Despesas',
        value: currency.format(totalSpent),
        detail:
            '${store.totalExpenseCount} itens em ${store.events.length} eventos',
        icon: Icons.payments_outlined,
        iconColor: AppTheme.secondary,
        iconBgColor: AppTheme.surfaceContainerHigh,
      ),
      _KpiTile(
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
      _KpiTile(
        label: 'Saldo a Pagar',
        value: currency.format(totalUnpaid),
        valueColor: totalUnpaid > 0 ? AppTheme.unpaidAmber : AppTheme.onSurface,
        detail: totalUnpaid > 0
            ? 'Pagamentos pendentes'
            : 'Todas as despesas quitadas',
        icon: Icons.schedule_outlined,
        iconColor: AppTheme.tertiary,
        iconBgColor: AppTheme.tertiaryContainer.withValues(alpha: 0.18),
      ),
      _KpiTile(
        label: 'Orçamentos Combinados',
        value: currency.format(totalBudget),
        detail: !store.hasAnyEventWithBudget
            ? 'Sem metas estipuladas'
            : totalBudget >= totalSpent
                ? '${currency.format(totalBudget - totalSpent)} de margem disponível'
                : '${currency.format(totalSpent - totalBudget)} acima do orçamento',
        valueColor: totalSpent > totalBudget && store.hasAnyEventWithBudget
            ? AppTheme.overBudgetCrimson
            : AppTheme.onSurface,
        icon: Icons.pie_chart_outline,
        iconColor: AppTheme.onSurfaceVariant,
        iconBgColor: AppTheme.surfaceContainer,
      ),
    ];

    if (!isMobile && !isTablet) {
      return Row(
        children: [
          for (int i = 0; i < kpiItems.length; i++) ...[
            if (i > 0) const SizedBox(width: 16),
            Expanded(child: kpiItems[i]),
          ],
        ],
      );
    }

    // 2x2 Grid for Tablet and Mobile
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: kpiItems[0]),
            const SizedBox(width: 12),
            Expanded(child: kpiItems[1]),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: kpiItems[2]),
            const SizedBox(width: 12),
            Expanded(child: kpiItems[3]),
          ],
        ),
      ],
    );
  }

  Widget _buildEventsCard({
    required BuildContext context,
    required NumberFormat currency,
    required DateFormat dateFmt,
    required bool isMobile,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
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
                      horizontal: 14,
                      vertical: 8,
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
                        decoration: const BoxDecoration(
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
            else if (isMobile)
              // Responsive Mobile Card list for events
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: store.events.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final event = store.events[index];
                  return _buildMobileEventCard(
                    context: context,
                    event: event,
                    currency: currency,
                    dateFmt: dateFmt,
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
                        onSelectChanged: (_) => store.selectEvent(event.id),
                        cells: [
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: AppTheme.surfaceContainer,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.celebration_outlined,
                                    size: 16,
                                    color: AppTheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                style: AppTheme.tabularNumber.copyWith(
                                  fontSize: 13,
                                  color: AppTheme.secondary,
                                ),
                              ),
                            ),
                          DataCell(
                            Text(
                              currency.format(event.totalSpent),
                              style: AppTheme.tabularNumber.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: AppTheme.onSurface,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              currency.format(event.paidAmount),
                              style: AppTheme.tabularNumber.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: AppTheme.paidGreen,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              currency.format(event.unpaidAmount),
                              style: AppTheme.tabularNumber.copyWith(
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
    );
  }

  Widget _buildMobileEventCard({
    required BuildContext context,
    required PersonalEvent event,
    required NumberFormat currency,
    required DateFormat dateFmt,
  }) {
    return InkWell(
      onTap: () => store.selectEvent(event.id),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    event.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.onSurface,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Arquivar',
                  icon: const Icon(Icons.archive_outlined, size: 18),
                  color: AppTheme.secondary,
                  onPressed: () =>
                      _handleArchive(context, event.id, event.name),
                ),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 13, color: AppTheme.secondary),
                const SizedBox(width: 4),
                Text(
                  dateFmt.format(event.eventDate),
                  style:
                      const TextStyle(fontSize: 12, color: AppTheme.secondary),
                ),
                if (event.venue.isNotEmpty) ...[
                  const Text(' · ',
                      style: TextStyle(color: AppTheme.secondary)),
                  Flexible(
                    child: Text(
                      event.venue,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.secondary),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text('Gasto',
                          style: TextStyle(
                              fontSize: 10.5, color: AppTheme.secondary)),
                      const SizedBox(height: 2),
                      Text(
                        currency.format(event.totalSpent),
                        style: AppTheme.tabularNumber.copyWith(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text('Pago',
                          style: TextStyle(
                              fontSize: 10.5, color: AppTheme.secondary)),
                      const SizedBox(height: 2),
                      Text(
                        currency.format(event.paidAmount),
                        style: AppTheme.tabularNumber.copyWith(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.paidGreen,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text('Pendente',
                          style: TextStyle(
                              fontSize: 10.5, color: AppTheme.secondary)),
                      const SizedBox(height: 2),
                      Text(
                        currency.format(event.unpaidAmount),
                        style: AppTheme.tabularNumber.copyWith(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: event.unpaidAmount > 0
                              ? AppTheme.unpaidAmber
                              : AppTheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.secondary,
                    ),
                  ),
                ),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 15, color: iconColor),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: AppTheme.tabularNumber.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: valueColor,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              detail,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11.5,
                color: AppTheme.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
