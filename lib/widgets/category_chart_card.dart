import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/event_models.dart';
import '../theme/app_theme.dart';
import 'app_widgets.dart';

class CategoryExpenseChartCard extends StatelessWidget {
  const CategoryExpenseChartCard({
    super.key,
    this.title = 'Gastos por Categoria',
    required this.categoryTotals,
    required this.totalSpent,
    this.emptyMessage =
        'Adicione despesas para visualizar os totais por categoria.',
  });

  final String title;
  final Map<ExpenseCategory, double> categoryTotals;
  final double totalSpent;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final categoryEntries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.pie_chart_outline,
                    size: 20, color: AppTheme.accent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.inkPrimary,
                    ),
                  ),
                ),
                Text(
                  '${categoryEntries.length} ${categoryEntries.length == 1 ? 'categoria' : 'categorias'}',
                  style:
                      const TextStyle(fontSize: 12, color: AppTheme.inkMuted),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (categoryEntries.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    emptyMessage,
                    style: const TextStyle(color: AppTheme.inkMuted),
                  ),
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Row(
                              children: [
                                Container(
                                  width: 26,
                                  height: 26,
                                  decoration: BoxDecoration(
                                    color:
                                        entry.key.color.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Icon(
                                    entry.key.icon,
                                    size: 15,
                                    color: entry.key.color,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    entry.key.label,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Row(
                            children: [
                              Text(
                                currency.format(entry.value),
                                style: AppTheme.tabularNumber.copyWith(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.divider,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '${(share * 100).toStringAsFixed(0)}%',
                                  style: AppTheme.tabularNumber.copyWith(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.inkMuted,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      LedgerProgressBar(value: share, color: entry.key.color),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
