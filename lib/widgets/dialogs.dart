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
}) {
  return showDialog<ExpenseFormResult>(
    context: context,
    builder: (context) => _ExpenseFormDialog(existing: existing),
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
                        hintText: 'ex.: Salão de Festas',
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
                          labelText: 'Data do Evento',
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
              TextFormField(
                controller: _budgetController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Orçamento Previsto (R\$)',
                  prefixText: 'R\$ ',
                ),
                validator: (value) {
                  final parsed = _parseCurrencyInput(value ?? '');
                  if (parsed == null || parsed < 0) {
                    return 'Informe um orçamento válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Observações (Opcional)',
                  hintText: 'Quantidade de convidados, tema ou lembretes',
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
  const _ExpenseFormDialog({this.existing});

  final ExpenseItem? existing;

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
    _category = widget.existing?.category ?? ExpenseCategory.catering;
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
                      initialValue: _category,
                      decoration:
                          const InputDecoration(labelText: 'Categoria'),
                      items: ExpenseCategory.values
                          .map(
                            (cat) => DropdownMenuItem(
                              value: cat,
                              child: Row(
                                children: [
                                  Icon(cat.icon, size: 16, color: cat.color),
                                  const SizedBox(width: 8),
                                  Text(cat.label),
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
