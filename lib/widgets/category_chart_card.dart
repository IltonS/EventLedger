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
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.inkPrimary,
              ),
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
