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
      width: 272,
      decoration: const BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        border: Border(
          right: BorderSide(color: Color(0x226F7A70)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Brand Plaque with Forest Green Icon badge
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 18),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withOpacity(0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'EventLedger',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.onSurface,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      'Gestão Orçamentária',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.secondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Main Navigation Items (M3 Tonal Pill Selection)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _NavTile(
                  icon: Icons.dashboard_rounded,
                  label: 'Painel de Despesas',
                  selected: store.activeView == WorkspaceView.dashboard,
                  onTap: store.selectDashboard,
                ),
                const SizedBox(height: 4),
                _NavTile(
                  icon: Icons.receipt_long_rounded,
                  label: 'Todas as Despesas',
                  trailingText: '${store.totalExpenseCount}',
                  selected: store.activeView == WorkspaceView.allExpenses,
                  onTap: store.selectAllExpenses,
                ),
                const SizedBox(height: 4),
                _NavTile(
                  icon: Icons.category_rounded,
                  label: 'Categorias',
                  trailingText: '${store.categories.length}',
                  selected: store.activeView == WorkspaceView.categories,
                  onTap: store.selectCategories,
                ),
                const SizedBox(height: 4),
                _NavTile(
                  icon: Icons.archive_rounded,
                  label: 'Eventos Arquivados',
                  trailingText: store.archivedEvents.isNotEmpty
                      ? '${store.archivedEvents.length}'
                      : null,
                  selected: store.activeView == WorkspaceView.archivedEvents,
                  onTap: store.selectArchivedEvents,
                ),
              ],
            ),
          ),

          // Section Title: Eventos Pessoais
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 12, 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'EVENTOS PESSOAIS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: AppTheme.secondary,
                  ),
                ),
                IconButton(
                  tooltip: 'Criar Evento',
                  onPressed: onCreateEvent,
                  icon: const Icon(Icons.add, size: 18),
                  style: IconButton.styleFrom(
                    foregroundColor: AppTheme.primary,
                    backgroundColor: AppTheme.surfaceContainerHigh,
                    padding: const EdgeInsets.all(4),
                    minimumSize: const Size(26, 26),
                  ),
                ),
              ],
            ),
          ),

          // Event list with M3 container styling
          Expanded(
            child: store.events.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Text(
                      'Nenhum evento ativo. Crie um evento para começar.',
                      style:
                          TextStyle(fontSize: 12.5, color: AppTheme.secondary),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
                    itemCount: store.events.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 4),
                    itemBuilder: (context, index) {
                      final event = store.events[index];
                      final isSelected =
                          store.activeView == WorkspaceView.eventDetail &&
                              store.selectedEventId == event.id;
                      return Material(
                        color: isSelected
                            ? AppTheme.secondaryContainer
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => store.selectEvent(event.id),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
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
                                    fontSize: 13,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? AppTheme.onSecondaryFixed
                                        : AppTheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${currency.format(event.totalSpent)} · ${event.expenses.length} ${event.expenses.length == 1 ? 'item' : 'itens'}',
                                  style: AppTheme.tabularNumber.copyWith(
                                    fontSize: 11.5,
                                    color: isSelected
                                        ? AppTheme.onSecondaryContainer
                                        : AppTheme.secondary,
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

          // Pinned bottom action
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton.icon(
              onPressed: onCreateEvent,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Novo Evento'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(46),
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9999),
                ),
              ),
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
      color: selected ? AppTheme.primaryFixed : Colors.transparent,
      borderRadius: BorderRadius.circular(9999),
      child: InkWell(
        borderRadius: BorderRadius.circular(9999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: selected
                    ? AppTheme.onPrimaryFixed
                    : AppTheme.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color:
                        selected ? AppTheme.onPrimaryFixed : AppTheme.onSurface,
                  ),
                ),
              ),
              if (trailingText != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppTheme.primary.withOpacity(0.15)
                        : AppTheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Text(
                    trailingText!,
                    style: AppTheme.tabularNumber.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: selected
                          ? AppTheme.onPrimaryFixed
                          : AppTheme.secondary,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
