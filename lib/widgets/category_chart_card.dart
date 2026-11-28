import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/event_models.dart';
import '../theme/app_theme.dart';

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
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.onSurface,
                    letterSpacing: -0.2,
                  ),
                ),
                if (categoryEntries.isNotEmpty)
                  Text(
                    '${categoryEntries.length} ${categoryEntries.length == 1 ? 'categoria' : 'categorias'}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.secondary,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            if (categoryEntries.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 36),
                child: Center(
                  child: Column(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceContainerHigh,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.pie_chart_outline,
                          size: 22,
                          color: AppTheme.secondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        emptyMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppTheme.secondary,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...categoryEntries.map((entry) {
                final share = totalSpent > 0
                    ? (entry.value / totalSpent).clamp(0.0, 1.0)
                    : 0.0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: entry.key.color.withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  entry.key.icon,
                                  size: 15,
                                  color: entry.key.color,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                entry.key.label,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${currency.format(entry.value)} · ${(share * 100).toStringAsFixed(0)}%',
                            style: AppTheme.tabularNumber.copyWith(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.secondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(9999),
                        child: LinearProgressIndicator(
                          value: share,
                          minHeight: 6,
                          backgroundColor: AppTheme.surfaceContainerHighest,
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
    );
  }
}
