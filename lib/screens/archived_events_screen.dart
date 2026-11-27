import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/event_models.dart';
import '../state/ledger_store.dart';
import '../theme/app_theme.dart';
import '../widgets/dialogs.dart';

class ArchivedEventsScreen extends StatefulWidget {
  const ArchivedEventsScreen({super.key, required this.store});

  final LedgerStore store;

  @override
  State<ArchivedEventsScreen> createState() => _ArchivedEventsScreenState();
}

class _ArchivedEventsScreenState extends State<ArchivedEventsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<PersonalEvent> get _filteredEvents {
    final archived = widget.store.archivedEvents;
    if (_searchQuery.trim().isEmpty) return archived;
    final q = _searchQuery.toLowerCase();
    return archived.where((e) {
      final matchName = e.name.toLowerCase().contains(q);
      final matchVenue = e.venue.toLowerCase().contains(q);
      final matchNotes = e.notes.toLowerCase().contains(q);
      return matchName || matchVenue || matchNotes;
    }).toList();
  }

  Future<void> _handleUnarchive(PersonalEvent event) async {
    await widget.store.unarchiveEvent(event.id);
    if (!mounted) return;
    showAppSnackBar(
      context,
      message: 'Evento "${event.name}" desarquivado com sucesso.',
      actionLabel: 'Ver Evento',
      onAction: () => widget.store.selectEvent(event.id),
    );
  }

  Future<void> _handlePermanentDelete(PersonalEvent event) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir evento definitivamente?'),
        content: SizedBox(
          width: 440,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tem certeza que deseja remover definitivamente o evento "${event.name}"?',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Text(
                'Esta ação é irreversível. O evento e todas as suas ${event.expenses.length} despesas associadas serão excluídos permanentemente.',
                style: const TextStyle(color: AppTheme.inkSecondary),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.overBudgetCrimson,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir Definitivamente'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await widget.store.deleteEvent(event.id);
      if (!mounted) return;
      showAppSnackBar(
        context,
        message: 'Evento "${event.name}" excluído definitivamente.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final dateFmt = DateFormat.yMMMd('pt_BR');
    final archivedEvents = widget.store.archivedEvents;
    final filtered = _filteredEvents;

    final totalSpentArchived = archivedEvents.fold<double>(
      0,
      (sum, e) => sum + e.totalSpent,
    );
    final totalExpensesArchived = archivedEvents.fold<int>(
      0,
      (sum, e) => sum + e.expenses.length,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Banner explicativo sobre eventos arquivados
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.outlineVariant.withOpacity(0.5),
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppTheme.primary,
                  size: 20,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Eventos arquivados são mantidos para histórico e consulta, mas não entram nos cálculos de KPIs, totais ou orçamentos do painel principal.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.secondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Card principal com cabeçalho, busca e tabela
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Cabeçalho da seção
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Gestão de Eventos Arquivados',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.inkPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            archivedEvents.isEmpty
                                ? 'Nenhum evento arquivado no momento'
                                : '${archivedEvents.length} ${archivedEvents.length == 1 ? 'evento arquivado' : 'eventos arquivados'} · ${currency.format(totalSpentArchived)} em $totalExpensesArchived despesas',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.inkMuted,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      if (archivedEvents.isNotEmpty)
                        SizedBox(
                          width: 280,
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Buscar evento ou local...',
                              prefixIcon: const Icon(Icons.search, size: 20),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, size: 18),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() => _searchQuery = '');
                                      },
                                    )
                                  : null,
                              isDense: true,
                            ),
                            onChanged: (v) => setState(() => _searchQuery = v),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  if (archivedEvents.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 48),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: AppTheme.border.withValues(alpha: 0.5),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.archive_outlined,
                                size: 32,
                                color: AppTheme.inkMuted,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Nenhum evento arquivado',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.inkPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const SizedBox(
                              width: 420,
                              child: Text(
                                'Eventos arquivados a partir dos detalhes do evento ou do painel serão listados aqui para consulta, desarquivamento ou exclusão permanente.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.inkMuted,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (filtered.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Column(
                          children: [
                            const Text(
                              'Nenhum evento corresponde à busca realizada.',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.inkMuted,
                              ),
                            ),
                            const SizedBox(height: 10),
                            OutlinedButton(
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                              child: const Text('Limpar busca'),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        horizontalMargin: 0,
                        columnSpacing: 24,
                        dataRowMinHeight: 52,
                        dataRowMaxHeight: 64,
                        headingTextStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.inkMuted,
                        ),
                        columns: const [
                          DataColumn(label: Text('Evento')),
                          DataColumn(label: Text('Data')),
                          DataColumn(label: Text('Local')),
                          DataColumn(label: Text('Orçamento'), numeric: true),
                          DataColumn(label: Text('Total Gasto'), numeric: true),
                          DataColumn(label: Text('Despesas')),
                          DataColumn(label: Text('Ações')),
                        ],
                        rows: filtered.map((event) {
                          return DataRow(
                            cells: [
                              DataCell(
                                InkWell(
                                  onTap: () =>
                                      widget.store.selectEvent(event.id),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                                      if (event.notes.isNotEmpty)
                                        Text(
                                          event.notes,
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
                              ),
                              DataCell(Text(dateFmt.format(event.eventDate))),
                              DataCell(
                                Text(
                                  event.venue.isNotEmpty ? event.venue : '—',
                                  style: TextStyle(
                                    color: event.venue.isNotEmpty
                                        ? AppTheme.inkSecondary
                                        : AppTheme.inkMuted,
                                  ),
                                ),
                              ),
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
                                  '${event.expenses.length} (${event.paidCount} pagas)',
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    color: AppTheme.inkSecondary,
                                  ),
                                ),
                              ),
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    FilledButton.tonalIcon(
                                      onPressed: () => _handleUnarchive(event),
                                      icon: const Icon(
                                        Icons.unarchive_outlined,
                                        size: 15,
                                      ),
                                      label: const Text('Desarquivar'),
                                      style: FilledButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        textStyle:
                                            const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    OutlinedButton.icon(
                                      onPressed: () =>
                                          _handlePermanentDelete(event),
                                      icon: const Icon(
                                        Icons.delete_forever_outlined,
                                        size: 15,
                                      ),
                                      label: const Text('Excluir'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor:
                                            AppTheme.overBudgetCrimson,
                                        side: const BorderSide(
                                          color: AppTheme.overBudgetCrimson,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        textStyle:
                                            const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    IconButton(
                                      tooltip: 'Ver detalhes',
                                      icon: const Icon(
                                        Icons.chevron_right,
                                        size: 18,
                                      ),
                                      onPressed: () =>
                                          widget.store.selectEvent(event.id),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
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
