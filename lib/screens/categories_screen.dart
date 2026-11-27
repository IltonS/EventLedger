import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/event_models.dart';
import '../state/ledger_store.dart';
import '../theme/app_theme.dart';
import '../widgets/dialogs.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key, required this.store});

  final LedgerStore store;

  Future<void> _handleCreateCategory(BuildContext context) async {
    final result = await showCategoryFormDialog(context);
    if (result == null) return;
    await store.addCategory(
      name: result.name,
      icon: result.icon,
      color: result.color,
    );
  }

  Future<void> _handleEditCategory(
    BuildContext context,
    ExpenseCategory category,
  ) async {
    final result = await showCategoryFormDialog(context, existing: category);
    if (result == null) return;
    await store.updateCategory(
      category.copyWith(
        name: result.name,
        icon: result.icon,
        color: result.color,
      ),
    );
  }

  Future<void> _handleDeleteCategory(
    BuildContext context,
    ExpenseCategory category,
  ) async {
    if (store.categories.length <= 1) {
      showAppSnackBar(
        context,
        message: 'Não é possível excluir a única categoria restante.',
      );
      return;
    }

    final expenseCount = store.getExpenseCountForCategory(category.id);
    final otherCategories =
        store.categories.where((c) => c.id != category.id).toList();

    final replacement = await showDeleteCategoryDialog(
      context,
      category: category,
      expenseCount: expenseCount,
      otherCategories: otherCategories,
    );

    if (replacement == null && expenseCount > 0) return;

    await store.deleteCategory(
      category.id,
      replacement: replacement,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final totalSpentAll = store.totalSpentAllEvents;

    // Determine top category by spending
    ExpenseCategory? topCategory;
    var topCategorySpent = 0.0;
    var usedCategoriesCount = 0;

    for (final cat in store.categories) {
      final spent = store.getTotalSpentForCategory(cat.id);
      final count = store.getExpenseCountForCategory(cat.id);
      if (count > 0) usedCategoriesCount++;
      if (spent > topCategorySpent) {
        topCategorySpent = spent;
        topCategory = cat;
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Categorias de Despesas',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.onSurface,
                      letterSpacing: -0.3,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Gerencie as categorias para classificar os gastos de todos os eventos',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.secondary,
                    ),
                  ),
                ],
              ),
              FilledButton.icon(
                onPressed: () => _handleCreateCategory(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Nova Categoria'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // KPI Summary Cards
          Row(
            children: [
              Expanded(
                child: _KpiCard(
                  title: 'Total de Categorias',
                  value: '${store.categories.length}',
                  subtitle: '$usedCategoriesCount em uso',
                  icon: Icons.category_outlined,
                  color: AppTheme.primary,
                  bgColor: AppTheme.secondaryContainer,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _KpiCard(
                  title: 'Total em Despesas',
                  value: currency.format(totalSpentAll),
                  subtitle: '${store.totalExpenseCount} despesas registradas',
                  icon: Icons.receipt_long_outlined,
                  color: AppTheme.paidGreen,
                  bgColor: AppTheme.paidGreenSurface,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _KpiCard(
                  title: 'Maior Categoria de Gasto',
                  value: topCategory != null ? topCategory.name : '—',
                  subtitle: topCategory != null
                      ? currency.format(topCategorySpent)
                      : 'Sem despesas',
                  icon: topCategory?.icon ?? Icons.bar_chart_outlined,
                  color: topCategory?.color ?? AppTheme.secondary,
                  bgColor: (topCategory?.color ?? AppTheme.secondary)
                      .withOpacity(0.14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Categories Table Card
          Card(
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
                            'Listagem de Categorias',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.onSurface,
                              letterSpacing: -0.2,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Classificações orçamentárias disponíveis nos eventos',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: AppTheme.secondary,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${store.categories.length} categorias cadastradas',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.secondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  if (store.categories.isEmpty)
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
                                Icons.category_outlined,
                                color: AppTheme.secondary,
                                size: 24,
                              ),
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              'Nenhuma categoria encontrada.',
                              style: TextStyle(color: AppTheme.secondary),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Theme(
                      data: Theme.of(context).copyWith(
                        dividerTheme: DividerThemeData(
                          color: AppTheme.outlineVariant.withOpacity(0.25),
                        ),
                      ),
                      child: DataTable(
                        horizontalMargin: 0,
                        columnSpacing: 24,
                        headingRowColor: WidgetStateProperty.all(
                          AppTheme.surfaceContainerLow,
                        ),
                        headingTextStyle: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: AppTheme.secondary,
                        ),
                        columns: const [
                          DataColumn(label: Text('CATEGORIA')),
                          DataColumn(label: Text('DESPESAS')),
                          DataColumn(
                            numeric: true,
                            label: Text('TOTAL GASTO'),
                          ),
                          DataColumn(
                            numeric: true,
                            label: Text('% DO TOTAL'),
                          ),
                          DataColumn(label: Text('AÇÕES')),
                        ],
                        rows: store.categories.map((cat) {
                          final expenseCount =
                              store.getExpenseCountForCategory(cat.id);
                          final spent = store.getTotalSpentForCategory(cat.id);
                          final share = totalSpentAll > 0
                              ? (spent / totalSpentAll).clamp(0.0, 1.0)
                              : 0.0;

                          return DataRow(
                            cells: [
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: cat.color.withOpacity(0.14),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        cat.icon,
                                        size: 18,
                                        color: cat.color,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      cat.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13.5,
                                        color: AppTheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              DataCell(
                                Text(
                                  '$expenseCount ${expenseCount == 1 ? 'item' : 'itens'}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  currency.format(spent),
                                  style: AppTheme.tabularNumber.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: AppTheme.onSurface,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  '${(share * 100).toStringAsFixed(1)}%',
                                  style: AppTheme.tabularNumber.copyWith(
                                    fontSize: 13,
                                    color: AppTheme.secondary,
                                  ),
                                ),
                              ),
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      tooltip: 'Editar Categoria',
                                      icon: const Icon(
                                        Icons.edit_outlined,
                                        size: 18,
                                        color: AppTheme.secondary,
                                      ),
                                      onPressed: () =>
                                          _handleEditCategory(context, cat),
                                    ),
                                    IconButton(
                                      tooltip: 'Excluir Categoria',
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        size: 18,
                                        color: AppTheme.overBudgetCrimson,
                                      ),
                                      onPressed: () =>
                                          _handleDeleteCategory(context, cat),
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

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.bgColor,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.tabularNumber.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.onSurface,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
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
          ],
        ),
      ),
    );
  }
}
