import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../state/ledger_store.dart';
import '../theme/app_theme.dart';

class DesktopSidebar extends StatelessWidget {
  const DesktopSidebar({
    super.key,
    required this.store,
    required this.onCreateEvent,
  });

  final LedgerStore store;
  final VoidCallback onCreateEvent;

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Container(
      width: 264,
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(right: BorderSide(color: AppTheme.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Row(
              children: [
                Text(
                  'EventLedger',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.inkPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _NavTile(
                  icon: Icons.dashboard_outlined,
                  label: 'Painel de Despesas',
                  selected: store.activeView == WorkspaceView.dashboard,
                  onTap: store.selectDashboard,
                ),
                const SizedBox(height: 4),
                _NavTile(
                  icon: Icons.receipt_long_outlined,
                  label: 'Todas as Despesas',
                  trailingText: '${store.totalExpenseCount}',
                  selected: store.activeView == WorkspaceView.allExpenses,
                  onTap: store.selectAllExpenses,
                ),
                const SizedBox(height: 4),
                _NavTile(
                  icon: Icons.category_outlined,
                  label: 'Categorias',
                  trailingText: '${store.categories.length}',
                  selected: store.activeView == WorkspaceView.categories,
                  onTap: store.selectCategories,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Eventos Pessoais',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.inkMuted,
                  ),
                ),
                IconButton(
                  tooltip: 'Criar Evento',
                  onPressed: onCreateEvent,
                  icon: const Icon(Icons.add, size: 18),
                  style: IconButton.styleFrom(
                    foregroundColor: AppTheme.accent,
                    padding: const EdgeInsets.all(6),
                    minimumSize: const Size(28, 28),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: store.events.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Text(
                      'Nenhum evento cadastrado. Crie um evento para começar.',
                      style: TextStyle(fontSize: 13, color: AppTheme.inkMuted),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                    itemCount: store.events.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 4),
                    itemBuilder: (context, index) {
                      final event = store.events[index];
                      final isSelected =
                          store.activeView == WorkspaceView.eventDetail &&
                              store.selectedEventId == event.id;
                      return Material(
                        color: isSelected
                            ? AppTheme.accent.withValues(alpha: 0.08)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () => store.selectEvent(event.id),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  event.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? AppTheme.accent
                                        : AppTheme.inkPrimary,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '${currency.format(event.totalSpent)} · ${event.expenses.length} ${event.expenses.length == 1 ? 'item' : 'itens'}',
                                  style: AppTheme.tabularNumber.copyWith(
                                    fontSize: 12,
                                    color: AppTheme.inkMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(14),
            child: FilledButton.icon(
              onPressed: onCreateEvent,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Novo Evento'),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.trailingText,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final String? trailingText;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppTheme.accent.withValues(alpha: 0.08)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: selected ? AppTheme.accent : AppTheme.inkSecondary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    color: selected ? AppTheme.accent : AppTheme.inkPrimary,
                  ),
                ),
              ),
              if (trailingText != null)
                Text(
                  trailingText!,
                  style: AppTheme.tabularNumber.copyWith(
                    fontSize: 12,
                    color: AppTheme.inkMuted,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
