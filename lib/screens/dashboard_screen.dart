import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/event_models.dart';
import '../state/ledger_store.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/category_chart_card.dart';
import '../widgets/dialogs.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    required this.store,
    required this.onCreateEvent,
  });

  final LedgerStore store;
  final VoidCallback onCreateEvent;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  /// Event the dashboard is scoped to; null means all events.
  String? _scopeEventId;

  LedgerStore get store => widget.store;
  VoidCallback get onCreateEvent => widget.onCreateEvent;

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

    final allEvents = store.events;
    PersonalEvent? scoped;
    for (final e in allEvents) {
      if (e.id == _scopeEventId) scoped = e;
    }
    final scopeEvents = scoped != null ? [scoped] : allEvents;

    final totalSpent = scopeEvents.fold(0.0, (a, e) => a + e.totalSpent);
    final totalPaid = scopeEvents.fold(0.0, (a, e) => a + e.paidAmount);
    final totalUnpaid = scopeEvents.fold(0.0, (a, e) => a + e.unpaidAmount);
    final totalBudget = scopeEvents.fold(0.0, (a, e) => a + e.budget);
    final hasBudget = totalBudget > 0;
    final itemCount = scopeEvents.fold(0, (a, e) => a + e.expenses.length);
    final paidShare = totalSpent > 0 ? totalPaid / totalSpent : 0.0;

    final categoryTotals = <ExpenseCategory, double>{};
    for (final e in scopeEvents) {
      e.categoryTotals.forEach((k, v) {
        categoryTotals[k] = (categoryTotals[k] ?? 0) + v;
      });
    }

    final recent = <({PersonalEvent event, ExpenseItem item})>[
      for (final e in scopeEvents)
        for (final x in e.expenses) (event: e, item: x),
    ]..sort((a, b) => b.item.date.compareTo(a.item.date));

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 1000;
        final narrow = constraints.maxWidth < 700;
        final pad = narrow ? 16.0 : 32.0;

        final totalCard = _TotalCard(
          value: currency.format(totalSpent),
          chip:
              '$itemCount ${itemCount == 1 ? 'item' : 'itens'} • ${scopeEvents.length} ${scopeEvents.length == 1 ? 'evento' : 'eventos'}',
          caption: hasBudget
              ? (totalBudget >= totalSpent
                  ? '${currency.format(totalBudget - totalSpent)} de margem no orçamento'
                  : '${currency.format(totalSpent - totalBudget)} acima do orçamento de ${currency.format(totalBudget)}')
              : 'Soma das despesas lançadas',
          overBudget: hasBudget && totalSpent > totalBudget,
          ringValue: hasBudget ? totalSpent / totalBudget : paidShare,
          ringLabel: hasBudget ? 'orçado' : 'pago',
        );
        final paidCard = _MiniKpi(
          icon: Icons.verified_outlined,
          iconBg: AppTheme.paidBadgeBg,
          iconFg: AppTheme.paidGreen,
          tag: 'Quitado',
          tagBg: AppTheme.paidBadgeBg,
          tagFg: AppTheme.paidBadgeFg,
          value: currency.format(totalPaid),
          valueColor: AppTheme.paidGreen,
          caption: totalSpent > 0
              ? '${(paidShare * 100).toStringAsFixed(0)}% já liquidado'
              : 'Nenhuma despesa lançada',
        );
        final unpaidCard = _MiniKpi(
          icon: Icons.pending_actions_outlined,
          iconBg: AppTheme.pendingBadgeBg,
          iconFg: AppTheme.unpaidAmber,
          tag: totalUnpaid > 0 ? 'Em aberto' : 'Em dia',
          tagBg:
              totalUnpaid > 0 ? AppTheme.pendingBadgeBg : AppTheme.paidBadgeBg,
          tagFg:
              totalUnpaid > 0 ? AppTheme.pendingBadgeFg : AppTheme.paidBadgeFg,
          value: currency.format(totalUnpaid),
          valueColor:
              totalUnpaid > 0 ? AppTheme.unpaidAmber : AppTheme.inkPrimary,
          caption: totalUnpaid > 0
              ? 'Pendente de quitação'
              : 'Todas as despesas quitadas',
        );

        final kpis = wide
            ? IntrinsicHeight(
                child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(flex: 5, child: totalCard),
                  const SizedBox(width: 16),
                  Expanded(flex: 3, child: paidCard),
                  const SizedBox(width: 16),
                  Expanded(flex: 3, child: unpaidCard),
                ],
              ))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  totalCard,
                  const SizedBox(height: 12),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: paidCard),
                        const SizedBox(width: 12),
                        Expanded(child: unpaidCard),
                      ],
                    ),
                  ),
                ],
              );

        final eventsSection = scoped != null
            ? _ActiveEventCard(
                event: scoped,
                currency: currency,
                dateFmt: dateFmt,
                onOpen: () => store.selectEvent(scoped!.id),
                onArchive: () =>
                    _handleArchive(context, scoped!.id, scoped.name),
              )
            : _SectionCard(
                icon: Icons.event_note_outlined,
                title: 'Resumo dos Eventos',
                trailing: TextButton.icon(
                  onPressed: onCreateEvent,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Criar Evento'),
                ),
                child: allEvents.isEmpty
                    ? Padding(
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
                    : narrow
                        ? Column(
                            children: [
                              for (final event in allEvents)
                                _EventRowCard(
                                  event: event,
                                  currency: currency,
                                  dateFmt: dateFmt,
                                  onTap: () => store.selectEvent(event.id),
                                ),
                            ],
                          )
                        : _buildEventsTable(
                            context, allEvents, currency, dateFmt),
              );

        final categoriesCard = CategoryExpenseChartCard(
          categoryTotals: categoryTotals,
          totalSpent: totalSpent,
        );

        final recentCard = _SectionCard(
          icon: Icons.receipt_long_outlined,
          title: 'Lançamentos Recentes',
          trailing: TextButton(
            onPressed: store.selectAllExpenses,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Ver todos'),
                Icon(Icons.chevron_right, size: 16),
              ],
            ),
          ),
          child: recent.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      'Nenhuma despesa lançada ainda.',
                      style: TextStyle(color: AppTheme.inkMuted),
                    ),
                  ),
                )
              : Column(
                  children: [
                    for (final r in recent.take(5))
                      _RecentExpenseRow(
                        entry: r,
                        currency: currency,
                        dateFmt: dateFmt,
                        showEvent: scoped == null,
                        onTap: () => store.selectEvent(r.event.id),
                      ),
                  ],
                ),
        );

        return SingleChildScrollView(
          padding: EdgeInsets.all(pad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Painel Financeiro',
                style: TextStyle(
                  fontSize: 24,
                  height: 32 / 24,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.inkPrimary,
                ),
              ),
              const Text(
                'Visão consolidada dos seus eventos',
                style: TextStyle(fontSize: 13, color: AppTheme.inkMuted),
              ),
              const SizedBox(height: 14),
              _ScopeChips(
                events: allEvents,
                selectedId: scoped?.id,
                onSelected: (id) => setState(() => _scopeEventId = id),
              ),
              const SizedBox(height: 20),
              kpis,
              if (hasBudget && !narrow) ...[
                const SizedBox(height: 16),
                _BudgetStrip(
                  spent: totalSpent,
                  budget: totalBudget,
                  currency: currency,
                ),
              ],
              const SizedBox(height: 20),
              if (wide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: eventsSection),
                    const SizedBox(width: 20),
                    Expanded(flex: 2, child: categoriesCard),
                  ],
                )
              else ...[
                eventsSection,
                const SizedBox(height: 16),
                categoriesCard,
              ],
              const SizedBox(height: 20),
              recentCard,
            ],
          ),
        );
      },
    );
  }

  Widget _buildEventsTable(
    BuildContext context,
    List<PersonalEvent> events,
    NumberFormat currency,
    DateFormat dateFmt,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        showCheckboxColumn: false,
        horizontalMargin: 0,
        columnSpacing: 24,
        columns: [
          const DataColumn(label: Text('EVENTO')),
          const DataColumn(label: Text('DATA')),
          if (store.hasAnyEventWithBudget)
            const DataColumn(label: Text('ORÇAMENTO'), numeric: true),
          const DataColumn(label: Text('TOTAL GASTO'), numeric: true),
          const DataColumn(label: Text('PAGO'), numeric: true),
          const DataColumn(label: Text('PENDENTE'), numeric: true),
          const DataColumn(label: Text('AÇÕES')),
        ],
        rows: events.map((event) {
          return DataRow(
            onSelectChanged: (_) => store.selectEvent(event.id),
            cells: [
              DataCell(
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.name,
                      style: const TextStyle(fontWeight: FontWeight.w700),
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
                    event.hasBudget ? currency.format(event.budget) : '—',
                    style: AppTheme.tabularNumber.copyWith(fontSize: 13),
                  ),
                ),
              DataCell(
                Text(
                  currency.format(event.totalSpent),
                  style: AppTheme.tabularNumber.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              DataCell(
                Text(
                  currency.format(event.paidAmount),
                  style: AppTheme.tabularNumber.copyWith(
                    fontSize: 13,
                    color: AppTheme.paidGreen,
                  ),
                ),
              ),
              DataCell(
                Text(
                  currency.format(event.unpaidAmount),
                  style: AppTheme.tabularNumber.copyWith(
                    fontSize: 13,
                    color: event.unpaidAmount > 0
                        ? AppTheme.unpaidAmber
                        : AppTheme.inkMuted,
                  ),
                ),
              ),
              DataCell(
                IconButton(
                  tooltip: 'Arquivar evento',
                  icon: const Icon(Icons.archive_outlined, size: 18),
                  onPressed: () =>
                      _handleArchive(context, event.id, event.name),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Building blocks
// ---------------------------------------------------------------------------

/// Rounded tinted square holding an icon (used across cards and rows).
class _IconChip extends StatelessWidget {
  const _IconChip({
    required this.icon,
    required this.background,
    required this.foreground,
    this.size = 36,
  });

  final IconData icon;
  final Color background;
  final Color foreground;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: size * 0.55, color: foreground),
    );
  }
}

class _SmallTag extends StatelessWidget {
  const _SmallTag({required this.label, required this.bg, required this.fg});

  final String label;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }
}

class _ScopeChips extends StatelessWidget {
  const _ScopeChips({
    required this.events,
    required this.selectedId,
    required this.onSelected,
  });

  final List<PersonalEvent> events;
  final String? selectedId;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    Widget chip(String label, IconData icon, bool active, String? id) {
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Material(
          color: active ? AppTheme.accent : AppTheme.divider,
          borderRadius: BorderRadius.circular(9999),
          child: InkWell(
            borderRadius: BorderRadius.circular(9999),
            onTap: () => onSelected(id),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 16,
                    color: active ? Colors.white : AppTheme.inkMuted,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: active ? Colors.white : AppTheme.inkSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          chip('Todos os Eventos', Icons.layers_outlined, selectedId == null,
              null),
          for (final e in events)
            chip(e.name, Icons.celebration_outlined, selectedId == e.id, e.id),
        ],
      ),
    );
  }
}

/// Large card: total expenses with a radial progress ring.
class _TotalCard extends StatelessWidget {
  const _TotalCard({
    required this.value,
    required this.chip,
    required this.caption,
    required this.ringValue,
    required this.ringLabel,
    required this.overBudget,
  });

  final String value;
  final String chip;
  final String caption;
  final double ringValue;
  final String ringLabel;
  final bool overBudget;

  @override
  Widget build(BuildContext context) {
    final ringColor = overBudget ? AppTheme.overBudgetCrimson : AppTheme.accent;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const _IconChip(
                  icon: Icons.account_balance_wallet_outlined,
                  background: AppTheme.paidBadgeBg,
                  foreground: AppTheme.accent,
                  size: 32,
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Total de Despesas',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.inkSecondary,
                    ),
                  ),
                ),
                _SmallTag(
                  label: chip,
                  bg: AppTheme.divider,
                  fg: AppTheme.inkMuted,
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          value,
                          style: AppTheme.tabularNumber.copyWith(
                            fontSize: 28,
                            height: 36 / 28,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.inkPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        caption,
                        style: TextStyle(
                          fontSize: 12,
                          color: overBudget
                              ? AppTheme.overBudgetCrimson
                              : AppTheme.inkMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 56,
                  height: 56,
                  child: CustomPaint(
                    painter: _RingPainter(
                      value: ringValue.clamp(0.0, 1.0),
                      color: ringColor,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${(ringValue * 100).round()}%',
                            style: AppTheme.tabularNumber.copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: ringColor,
                            ),
                          ),
                          Text(
                            ringLabel,
                            style: const TextStyle(
                              fontSize: 8.5,
                              height: 1,
                              color: AppTheme.inkMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.value, required this.color});

  final double value;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 5.0;
    final rect = Offset.zero & size;
    final arcRect = rect.deflate(stroke / 2);
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = AppTheme.divider;
    final fill = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = color;
    canvas.drawArc(arcRect, 0, 6.2831853, false, track);
    if (value > 0) {
      canvas.drawArc(arcRect, -1.5707963, 6.2831853 * value, false, fill);
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.value != value || old.color != color;
}

class _MiniKpi extends StatelessWidget {
  const _MiniKpi({
    required this.icon,
    required this.iconBg,
    required this.iconFg,
    required this.tag,
    required this.tagBg,
    required this.tagFg,
    required this.value,
    required this.valueColor,
    required this.caption,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconFg;
  final String tag;
  final Color tagBg;
  final Color tagFg;
  final String value;
  final Color valueColor;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _IconChip(
                  icon: icon,
                  background: iconBg,
                  foreground: iconFg,
                  size: 30,
                ),
                _SmallTag(label: tag, bg: tagBg, fg: tagFg),
              ],
            ),
            const SizedBox(height: 16),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: AppTheme.tabularNumber.copyWith(
                  fontSize: 18,
                  height: 24 / 18,
                  fontWeight: FontWeight.w700,
                  color: valueColor,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              caption,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11.5, color: AppTheme.inkMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _BudgetStrip extends StatelessWidget {
  const _BudgetStrip({
    required this.spent,
    required this.budget,
    required this.currency,
  });

  final double spent;
  final double budget;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    final over = spent > budget;
    final color = over ? AppTheme.overBudgetCrimson : AppTheme.accent;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            const _IconChip(
              icon: Icons.savings_outlined,
              background: AppTheme.divider,
              foreground: AppTheme.inkSecondary,
              size: 30,
            ),
            const SizedBox(width: 12),
            const Text(
              'Orçamento combinado',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 16),
            Text(
              currency.format(budget),
              style: AppTheme.tabularNumber.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: LedgerProgressBar(
                value: spent / budget,
                color: color,
                height: 8,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${(spent / budget * 100).toStringAsFixed(0)}% utilizado',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: AppTheme.accent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _ActiveEventCard extends StatelessWidget {
  const _ActiveEventCard({
    required this.event,
    required this.currency,
    required this.dateFmt,
    required this.onOpen,
    required this.onArchive,
  });

  final PersonalEvent event;
  final NumberFormat currency;
  final DateFormat dateFmt;
  final VoidCallback onOpen;
  final VoidCallback onArchive;

  @override
  Widget build(BuildContext context) {
    final total = event.totalSpent;
    final share = total > 0 ? event.paidAmount / total : 0.0;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const _IconChip(
                  icon: Icons.cake_outlined,
                  background: AppTheme.paidBadgeBg,
                  foreground: AppTheme.accent,
                  size: 40,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        [
                          dateFmt.format(event.eventDate),
                          if (event.venue.isNotEmpty) 'Local: ${event.venue}',
                        ].join(' • '),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.inkMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Arquivar evento',
                  icon: const Icon(Icons.archive_outlined, size: 18),
                  onPressed: onArchive,
                ),
                const SizedBox(width: 4),
                OutlinedButton(
                  onPressed: onOpen,
                  child: const Text('Abrir evento'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.canvas,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.divider),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Execução financeira',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: AppTheme.inkMuted,
                        ),
                      ),
                      Text(
                        '${(share * 100).toStringAsFixed(0)}% liquidado',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.accent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LedgerProgressBar(value: share, height: 10),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${currency.format(event.paidAmount)} pagos',
                        style: AppTheme.tabularNumber.copyWith(
                          fontSize: 11.5,
                          color: AppTheme.inkSecondary,
                        ),
                      ),
                      Text(
                        'Faltam ${currency.format(event.unpaidAmount)}',
                        style: AppTheme.tabularNumber.copyWith(
                          fontSize: 11.5,
                          color: AppTheme.inkSecondary,
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

class _EventRowCard extends StatelessWidget {
  const _EventRowCard({
    required this.event,
    required this.currency,
    required this.dateFmt,
    required this.onTap,
  });

  final PersonalEvent event;
  final NumberFormat currency;
  final DateFormat dateFmt;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppTheme.canvas,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const _IconChip(
                  icon: Icons.celebration_outlined,
                  background: AppTheme.paidBadgeBg,
                  foreground: AppTheme.accent,
                  size: 40,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        dateFmt.format(event.eventDate),
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppTheme.inkMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  currency.format(event.totalSpent),
                  style: AppTheme.tabularNumber.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RecentExpenseRow extends StatelessWidget {
  const _RecentExpenseRow({
    required this.entry,
    required this.currency,
    required this.dateFmt,
    required this.showEvent,
    required this.onTap,
  });

  final ({PersonalEvent event, ExpenseItem item}) entry;
  final NumberFormat currency;
  final DateFormat dateFmt;
  final bool showEvent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final item = entry.item;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppTheme.canvas,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                _IconChip(
                  icon: item.category.icon,
                  background: item.category.color.withValues(alpha: 0.12),
                  foreground: item.category.color,
                  size: 40,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        [
                          item.category.label,
                          if (showEvent) entry.event.name,
                          dateFmt.format(item.date),
                        ].join(' • '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppTheme.inkMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      currency.format(item.amount),
                      style: AppTheme.tabularNumber.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: item.isPaid
                            ? AppTheme.paidGreen
                            : AppTheme.inkPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    StatusBadge.forPaid(item.isPaid),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
