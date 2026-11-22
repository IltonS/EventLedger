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
      padding: const EdgeInsets.all(32),
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
                      color: AppTheme.inkPrimary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Gerencie as categorias para classificar os gastos de todos os eventos',
                    style: TextStyle(
                      fontSize: 13.5,
                      color: AppTheme.inkMuted,
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
                  color: AppTheme.accent,
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
                  color: topCategory?.color ?? AppTheme.inkSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Categories Table Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Listagem de Categorias',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.inkPrimary,
                        ),
                      ),
                      Text(
                        '${store.categories.length} categorias cadastradas',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.inkMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (store.categories.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Text(
                          'Nenhuma categoria encontrada.',
                          style: TextStyle(color: AppTheme.inkMuted),
                        ),
                      ),
                    )
                  else
                    DataTable(
                      horizontalMargin: 0,
                      columnSpacing: 24,
                      columns: const [
                        DataColumn(
                          label: Text(
                            'CATEGORIA',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.inkMuted,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'DESPESAS',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.inkMuted,
                            ),
                          ),
                        ),
                        DataColumn(
                          numeric: true,
                          label: Text(
                            'TOTAL GASTO',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.inkMuted,
                            ),
                          ),
                        ),
                        DataColumn(
                          numeric: true,
                          label: Text(
                            '% DO TOTAL',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.inkMuted,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'AÇÕES',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.inkMuted,
                            ),
                          ),
                        ),
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
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: cat.color.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(6),
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
                                      color: AppTheme.inkPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            DataCell(
                              Text(
                                '$expenseCount ${expenseCount == 1 ? 'item' : 'itens'}',
                                style: const TextStyle(
                                  color: AppTheme.inkSecondary,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                currency.format(spent),
                                style: AppTheme.tabularNumber.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.inkPrimary,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                '${(share * 100).toStringAsFixed(1)}%',
                                style: AppTheme.tabularNumber.copyWith(
                                  color: AppTheme.inkSecondary,
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
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

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
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
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
                      color: AppTheme.inkMuted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.tabularNumber.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.inkPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.inkSecondary,
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
