import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/event_models.dart';
import '../theme/app_theme.dart';

class EventFormResult {
  const EventFormResult({
    required this.name,
    required this.eventDate,
    required this.venue,
    required this.budget,
    required this.notes,
  });

  final String name;
  final DateTime eventDate;
  final String venue;
  final double budget;
  final String notes;
}

class ExpenseFormResult {
  const ExpenseFormResult({
    required this.title,
    required this.vendor,
    required this.amount,
    required this.category,
    required this.date,
    required this.isPaid,
    required this.notes,
  });

  final String title;
  final String vendor;
  final double amount;
  final ExpenseCategory category;
  final DateTime date;
  final bool isPaid;
  final String notes;
}

class CategoryFormResult {
  const CategoryFormResult({
    required this.name,
    required this.icon,
    required this.color,
  });

  final String name;
  final IconData icon;
  final Color color;
}

Future<EventFormResult?> showEventFormDialog(
  BuildContext context, {
  PersonalEvent? existing,
}) {
  return showDialog<EventFormResult>(
    context: context,
    builder: (context) => _EventFormDialog(existing: existing),
  );
}

Future<ExpenseFormResult?> showExpenseFormDialog(
  BuildContext context, {
  ExpenseItem? existing,
  required List<ExpenseCategory> categories,
}) {
  return showDialog<ExpenseFormResult>(
    context: context,
    builder: (context) => _ExpenseFormDialog(
      existing: existing,
      categories: categories,
    ),
  );
}

Future<CategoryFormResult?> showCategoryFormDialog(
  BuildContext context, {
  ExpenseCategory? existing,
}) {
  return showDialog<CategoryFormResult>(
    context: context,
    builder: (context) => _CategoryFormDialog(existing: existing),
  );
}

Future<ExpenseCategory?> showDeleteCategoryDialog(
  BuildContext context, {
  required ExpenseCategory category,
  required int expenseCount,
  required List<ExpenseCategory> otherCategories,
}) {
  ExpenseCategory selectedReplacement = otherCategories.first;

  return showDialog<ExpenseCategory>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: const Text('Excluir Categoria'),
        content: SizedBox(
          width: 440,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Tem certeza de que deseja excluir a categoria "${category.name}"?',
                style: const TextStyle(fontSize: 14),
              ),
              if (expenseCount > 0) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.unpaidAmber.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.unpaidAmber.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: AppTheme.unpaidAmber,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Esta categoria está associada a $expenseCount despesa(s). Selecione para qual categoria deseja movê-las:',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.inkPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<ExpenseCategory>(
                  initialValue: selectedReplacement,
                  decoration: const InputDecoration(
                    labelText: 'Transferir despesas para',
                  ),
                  items: otherCategories.map((c) {
                    return DropdownMenuItem(
                      value: c,
                      child: Row(
                        children: [
                          Icon(c.icon, size: 16, color: c.color),
                          const SizedBox(width: 8),
                          Text(c.name),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() => selectedReplacement = val);
                    }
                  },
                ),
              ] else ...[
                const SizedBox(height: 12),
                const Text(
                  'Nenhuma despesa está utilizando esta categoria no momento.',
                  style: TextStyle(fontSize: 13, color: AppTheme.inkMuted),
                ),
              ],
            ],
          ),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.overBudgetCrimson,
            ),
            onPressed: () => Navigator.of(context).pop(selectedReplacement),
            child: const Text('Excluir Categoria'),
          ),
        ],
      ),
    ),
  );
}

double? _parseCurrencyInput(String raw) {
  final cleaned = raw.trim().replaceAll(' ', '');
  if (cleaned.contains(',') && cleaned.contains('.')) {
    return double.tryParse(cleaned.replaceAll('.', '').replaceAll(',', '.'));
  }
  if (cleaned.contains(',')) {
    return double.tryParse(cleaned.replaceAll(',', '.'));
  }
  return double.tryParse(cleaned);
}

class _EventFormDialog extends StatefulWidget {
  const _EventFormDialog({this.existing});

  final PersonalEvent? existing;

  @override
  State<_EventFormDialog> createState() => _EventFormDialogState();
}

class _EventFormDialogState extends State<_EventFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _venueController;
  late final TextEditingController _budgetController;
  late final TextEditingController _notesController;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existing?.name ?? '');
    _venueController =
        TextEditingController(text: widget.existing?.venue ?? '');
    _budgetController = TextEditingController(
      text: widget.existing != null
          ? widget.existing!.budget.toStringAsFixed(2).replaceAll('.', ',')
          : '3000,00',
    );
    _notesController =
        TextEditingController(text: widget.existing?.notes ?? '');
    _selectedDate = widget.existing?.eventDate ??
        DateTime.now().add(const Duration(days: 14));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _venueController.dispose();
    _budgetController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      locale: const Locale('pt', 'BR'),
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;
    final dateText = DateFormat.yMMMd('pt_BR').format(_selectedDate);

    return AlertDialog(
      title: Text(isEditing ? 'Editar Evento' : 'Criar Evento Pessoal'),
      content: SizedBox(
        width: 460,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Evento',
                  hintText: 'ex.: Aniversário de 30 anos da Maya',
                ),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Informe o nome do evento'
                    : null,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _venueController,
                      decoration: const InputDecoration(
                        labelText: 'Local / Espaço',
                        hintText: 'ex.: Salão Buffet Paulista',
                      ),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                              ? 'Informe o local'
                              : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _budgetController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Orçamento Previsto (R\$)',
                        prefixText: 'R\$ ',
                      ),
                      validator: (value) {
                        final parsed = _parseCurrencyInput(value ?? '');
                        if (parsed == null || parsed <= 0) {
                          return 'Informe um orçamento maior que 0';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(8),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Data do Evento',
                    suffixIcon: Icon(Icons.calendar_today_outlined, size: 16),
                  ),
                  child: Text(dateText),
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Observações do Evento',
                  hintText: 'ex.: Quantidade estimada de convidados, horários...',
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState?.validate() != true) return;
            Navigator.of(context).pop(
              EventFormResult(
                name: _nameController.text.trim(),
                eventDate: _selectedDate,
                venue: _venueController.text.trim(),
                budget: _parseCurrencyInput(_budgetController.text)!,
                notes: _notesController.text.trim(),
              ),
            );
          },
          child: Text(isEditing ? 'Salvar Alterações' : 'Criar Evento'),
        ),
      ],
    );
  }
}

class _ExpenseFormDialog extends StatefulWidget {
  const _ExpenseFormDialog({
    this.existing,
    required this.categories,
  });

  final ExpenseItem? existing;
  final List<ExpenseCategory> categories;

  @override
  State<_ExpenseFormDialog> createState() => _ExpenseFormDialogState();
}

class _ExpenseFormDialogState extends State<_ExpenseFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _vendorController;
  late final TextEditingController _amountController;
  late final TextEditingController _notesController;
  late ExpenseCategory _category;
  late DateTime _date;
  late bool _isPaid;

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.existing?.title ?? '');
    _vendorController =
        TextEditingController(text: widget.existing?.vendor ?? '');
    _amountController = TextEditingController(
      text: widget.existing != null
          ? widget.existing!.amount.toStringAsFixed(2).replaceAll('.', ',')
          : '',
    );
    _notesController =
        TextEditingController(text: widget.existing?.notes ?? '');

    if (widget.existing != null) {
      _category = widget.categories.firstWhere(
        (c) => c.id == widget.existing!.category.id,
        orElse: () => widget.categories.isNotEmpty
            ? widget.categories.first
            : widget.existing!.category,
      );
    } else {
      _category = widget.categories.isNotEmpty
          ? widget.categories.first
          : ExpenseCategory.defaultCategories.first;
    }

    _date = widget.existing?.date ?? DateTime.now();
    _isPaid = widget.existing?.isPaid ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _vendorController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      locale: const Locale('pt', 'BR'),
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;
    final dateText = DateFormat.yMMMd('pt_BR').format(_date);

    return AlertDialog(
      title: Text(isEditing ? 'Editar Despesa' : 'Adicionar Despesa'),
      content: SizedBox(
        width: 480,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Descrição da Despesa',
                  hintText: 'ex.: Bolo de Aniversário e Doces',
                ),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Informe a descrição da despesa'
                    : null,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<ExpenseCategory>(
                      value: _category,
                      decoration: const InputDecoration(labelText: 'Categoria'),
                      items: widget.categories
                          .map(
                            (cat) => DropdownMenuItem(
                              value: cat,
                              child: Row(
                                children: [
                                  Icon(cat.icon, size: 16, color: cat.color),
                                  const SizedBox(width: 8),
                                  Text(cat.name),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _category = value);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _amountController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Valor (R\$)',
                        prefixText: 'R\$ ',
                      ),
                      validator: (value) {
                        final parsed = _parseCurrencyInput(value ?? '');
                        if (parsed == null || parsed <= 0) {
                          return 'Informe um valor maior que 0';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _vendorController,
                      decoration: const InputDecoration(
                        labelText: 'Fornecedor',
                        hintText: 'ex.: Confeitaria Doce Lar',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(8),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Data da Despesa',
                          suffixIcon:
                              Icon(Icons.calendar_today_outlined, size: 16),
                        ),
                        child: Text(dateText),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.canvas,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.border),
                ),
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Marcar como Pago',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    _isPaid
                        ? 'Incluída no total já pago'
                        : 'Contabilizada no saldo pendente a pagar',
                    style:
                        const TextStyle(fontSize: 12, color: AppTheme.inkMuted),
                  ),
                  value: _isPaid,
                  onChanged: (value) => setState(() => _isPaid = value),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState?.validate() != true) return;
            Navigator.of(context).pop(
              ExpenseFormResult(
                title: _titleController.text.trim(),
                vendor: _vendorController.text.trim(),
                amount: _parseCurrencyInput(_amountController.text)!,
                category: _category,
                date: _date,
                isPaid: _isPaid,
                notes: _notesController.text.trim(),
              ),
            );
          },
          child: Text(isEditing ? 'Salvar Despesa' : 'Adicionar Despesa'),
        ),
      ],
    );
  }
}

class _CategoryFormDialog extends StatefulWidget {
  const _CategoryFormDialog({this.existing});

  final ExpenseCategory? existing;

  @override
  State<_CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends State<_CategoryFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late IconData _selectedIcon;
  late Color _selectedColor;

  static const List<Color> _paletteColors = [
    Color(0xFF2563EB), // Blue
    Color(0xFFD97706), // Amber
    Color(0xFF7C3AED), // Purple
    Color(0xFF0D9488), // Teal
    Color(0xFFDB2777), // Pink
    Color(0xFF4F46E5), // Indigo
    Color(0xFF0284C7), // Sky
    Color(0xFF475569), // Slate
    Color(0xFF16A34A), // Green
    Color(0xFFEA580C), // Orange
    Color(0xFFE11D48), // Rose
    Color(0xFF0891B2), // Cyan
  ];

  static const List<IconData> _paletteIcons = [
    Icons.location_city_outlined,
    Icons.restaurant_outlined,
    Icons.celebration_outlined,
    Icons.music_note_outlined,
    Icons.card_giftcard_outlined,
    Icons.camera_alt_outlined,
    Icons.mail_outline,
    Icons.receipt_long_outlined,
    Icons.shopping_bag_outlined,
    Icons.sports_bar_outlined,
    Icons.cake_outlined,
    Icons.flight_outlined,
    Icons.hotel_outlined,
    Icons.local_shipping_outlined,
    Icons.palette_outlined,
    Icons.diamond_outlined,
    Icons.brush_outlined,
    Icons.coffee_outlined,
    Icons.pets_outlined,
    Icons.directions_car_outlined,
    Icons.videocam_outlined,
    Icons.local_florist_outlined,
    Icons.movie_outlined,
    Icons.star_outline,
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existing?.name ?? '');
    _selectedIcon = widget.existing?.icon ?? Icons.receipt_long_outlined;
    _selectedColor = widget.existing?.color ?? const Color(0xFF2563EB);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;

    return AlertDialog(
      title: Text(isEditing ? 'Editar Categoria' : 'Nova Categoria de Despesa'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Live preview badge
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.canvas,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _selectedColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _selectedIcon,
                          color: _selectedColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Pré-visualização da Categoria',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppTheme.inkMuted,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _nameController.text.trim().isEmpty
                                  ? 'Nome da Categoria'
                                  : _nameController.text.trim(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.inkPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    labelText: 'Nome da Categoria',
                    hintText: 'ex.: Transporte, Som & Iluminação, Lembrancinhas',
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Informe o nome da categoria'
                      : null,
                ),
                const SizedBox(height: 18),
                const Text(
                  'Cor Temática',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.inkSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _paletteColors.map((color) {
                    final isSelected = _selectedColor.value == color.value;
                    return InkWell(
                      onTap: () => setState(() => _selectedColor = color),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.inkPrimary
                                : Colors.transparent,
                            width: 2.5,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: color.withOpacity(0.4),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : null,
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16,
                              )
                            : null,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Ícone Representativo',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.inkSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _paletteIcons.map((icon) {
                    final isSelected = _selectedIcon.codePoint == icon.codePoint;
                    return InkWell(
                      onTap: () => setState(() => _selectedIcon = icon),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? _selectedColor.withOpacity(0.15)
                              : AppTheme.canvas,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? _selectedColor
                                : AppTheme.border,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Icon(
                          icon,
                          size: 20,
                          color: isSelected
                              ? _selectedColor
                              : AppTheme.inkSecondary,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState?.validate() != true) return;
            Navigator.of(context).pop(
              CategoryFormResult(
                name: _nameController.text.trim(),
                icon: _selectedIcon,
                color: _selectedColor,
              ),
            );
          },
          child: Text(isEditing ? 'Salvar Categoria' : 'Criar Categoria'),
        ),
      ],
    );
  }
}
