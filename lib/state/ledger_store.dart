import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../models/event_models.dart';

enum WorkspaceView { dashboard, allExpenses, eventDetail }

enum PaymentFilter { all, paid, unpaid }

class LedgerStore extends ChangeNotifier {
  LedgerStore();

  List<PersonalEvent> _events = [];
  WorkspaceView _activeView = WorkspaceView.dashboard;
  String? _selectedEventId;
  bool _isLoaded = false;

  List<PersonalEvent> get events => List.unmodifiable(_events);
  WorkspaceView get activeView => _activeView;
  String? get selectedEventId => _selectedEventId;
  bool get isLoaded => _isLoaded;

  PersonalEvent? get selectedEvent {
    if (_selectedEventId == null) return null;
    for (final event in _events) {
      if (event.id == _selectedEventId) return event;
    }
    return null;
  }

  double get totalBudgetAllEvents =>
      _events.fold<double>(0, (sum, e) => sum + e.budget);

  double get totalSpentAllEvents =>
      _events.fold<double>(0, (sum, e) => sum + e.totalSpent);

  double get totalPaidAllEvents =>
      _events.fold<double>(0, (sum, e) => sum + e.paidAmount);

  double get totalUnpaidAllEvents =>
      _events.fold<double>(0, (sum, e) => sum + e.unpaidAmount);

  int get totalExpenseCount =>
      _events.fold<int>(0, (sum, e) => sum + e.expenses.length);

  Map<ExpenseCategory, double> get aggregatedCategoryTotals {
    final map = <ExpenseCategory, double>{};
    for (final event in _events) {
      for (final entry in event.categoryTotals.entries) {
        map[entry.key] = (map[entry.key] ?? 0) + entry.value;
      }
    }
    return map;
  }

  Future<void> initialize() async {
    try {
      final file = await _storageFile();
      if (await file.exists()) {
        final raw = await file.readAsString();
        final decoded = jsonDecode(raw) as List<dynamic>;
        _events = decoded
            .map((e) => PersonalEvent.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        _events = _seedSampleEvents();
        await _persist();
      }
    } catch (_) {
      _events = _seedSampleEvents();
    }

    if (_events.isNotEmpty) {
      _selectedEventId = _events.first.id;
    }
    _isLoaded = true;
    notifyListeners();
  }

  void selectDashboard() {
    _activeView = WorkspaceView.dashboard;
    notifyListeners();
  }

  void selectAllExpenses() {
    _activeView = WorkspaceView.allExpenses;
    notifyListeners();
  }

  void selectEvent(String eventId) {
    _selectedEventId = eventId;
    _activeView = WorkspaceView.eventDetail;
    notifyListeners();
  }

  Future<void> addEvent({
    required String name,
    required DateTime eventDate,
    required String venue,
    required double budget,
    String notes = '',
  }) async {
    final newEvent = PersonalEvent(
      id: 'evt_${DateTime.now().microsecondsSinceEpoch}',
      name: name.trim(),
      eventDate: eventDate,
      venue: venue.trim(),
      budget: budget,
      notes: notes.trim(),
      expenses: const [],
    );
    _events = [newEvent, ..._events];
    _selectedEventId = newEvent.id;
    _activeView = WorkspaceView.eventDetail;
    notifyListeners();
    await _persist();
  }

  Future<void> updateEvent(PersonalEvent updated) async {
    _events = [
      for (final event in _events)
        if (event.id == updated.id) updated else event,
    ];
    notifyListeners();
    await _persist();
  }

  Future<void> deleteEvent(String eventId) async {
    _events = _events.where((e) => e.id != eventId).toList();
    if (_selectedEventId == eventId) {
      _selectedEventId = _events.isNotEmpty ? _events.first.id : null;
      _activeView = WorkspaceView.dashboard;
    }
    notifyListeners();
    await _persist();
  }

  Future<void> addExpense({
    required String eventId,
    required String title,
    required String vendor,
    required double amount,
    required ExpenseCategory category,
    required DateTime date,
    required bool isPaid,
    String notes = '',
  }) async {
    final newExpense = ExpenseItem(
      id: 'exp_${DateTime.now().microsecondsSinceEpoch}',
      title: title.trim(),
      vendor: vendor.trim(),
      amount: amount,
      category: category,
      date: date,
      isPaid: isPaid,
      notes: notes.trim(),
    );

    _events = [
      for (final event in _events)
        if (event.id == eventId)
          event.copyWith(expenses: [newExpense, ...event.expenses])
        else
          event,
    ];
    notifyListeners();
    await _persist();
  }

  Future<void> updateExpense({
    required String eventId,
    required ExpenseItem updated,
  }) async {
    _events = [
      for (final event in _events)
        if (event.id == eventId)
          event.copyWith(
            expenses: [
              for (final item in event.expenses)
                if (item.id == updated.id) updated else item,
            ],
          )
        else
          event,
    ];
    notifyListeners();
    await _persist();
  }

  Future<void> toggleExpensePaid({
    required String eventId,
    required String expenseId,
  }) async {
    _events = [
      for (final event in _events)
        if (event.id == eventId)
          event.copyWith(
            expenses: [
              for (final item in event.expenses)
                if (item.id == expenseId)
                  item.copyWith(isPaid: !item.isPaid)
                else
                  item,
            ],
          )
        else
          event,
    ];
    notifyListeners();
    await _persist();
  }

  Future<void> deleteExpense({
    required String eventId,
    required String expenseId,
  }) async {
    _events = [
      for (final event in _events)
        if (event.id == eventId)
          event.copyWith(
            expenses:
                event.expenses.where((item) => item.id != expenseId).toList(),
          )
        else
          event,
    ];
    notifyListeners();
    await _persist();
  }

  Future<File> _storageFile() async {
    final dir = await getApplicationSupportDirectory();
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return File(
      '${dir.path}${Platform.pathSeparator}event_ledger_ptbr_data.json',
    );
  }

  Future<void> _persist() async {
    try {
      final file = await _storageFile();
      final jsonList = _events.map((e) => e.toJson()).toList();
      await file.writeAsString(jsonEncode(jsonList));
    } catch (_) {
      // Ignora erros de gravação em plataformas sem suporte local.
    }
  }

  List<PersonalEvent> _seedSampleEvents() {
    return [
      PersonalEvent(
        id: 'evt_aniversario_30',
        name: 'Aniversário de 30 anos da Maya',
        eventDate: DateTime(2026, 12, 12),
        venue: 'Espaço Jardim Paulista',
        budget: 7500.00,
        notes: '45 convidados, coquetel e jantar à noite',
        expenses: [
          ExpenseItem(
            id: 'exp_101',
            title: 'Reserva e Locação do Salão',
            vendor: 'Espaço Jardim Eventos',
            amount: 2600.00,
            category: ExpenseCategory.venue,
            date: DateTime(2026, 11, 2),
            isPaid: true,
          ),
          ExpenseItem(
            id: 'exp_102',
            title: 'Buffet Completo e Mesa de Doces',
            vendor: 'Sabor da Casa Gastronomia',
            amount: 2350.00,
            category: ExpenseCategory.catering,
            date: DateTime(2026, 11, 14),
            isPaid: true,
          ),
          ExpenseItem(
            id: 'exp_103',
            title: 'Trio Acústico ao Vivo (3h)',
            vendor: 'Som & Cordas SP',
            amount: 1100.00,
            category: ExpenseCategory.entertainment,
            date: DateTime(2026, 11, 18),
            isPaid: false,
          ),
          ExpenseItem(
            id: 'exp_104',
            title: 'Arranjos Florais e Velas',
            vendor: 'Atelier Botânico Flor',
            amount: 680.00,
            category: ExpenseCategory.decorations,
            date: DateTime(2026, 11, 19),
            isPaid: false,
          ),
          ExpenseItem(
            id: 'exp_105',
            title: 'Convites e Cardápios Impressos',
            vendor: 'Gráfica Papel Fino',
            amount: 290.00,
            category: ExpenseCategory.invitations,
            date: DateTime(2026, 11, 10),
            isPaid: true,
          ),
        ],
      ),
      PersonalEvent(
        id: 'evt_bodas_prata',
        name: 'Jantar de Bodas de Prata',
        eventDate: DateTime(2026, 12, 28),
        venue: 'Restaurante Porto Alegre',
        budget: 4800.00,
        notes: 'Jantar em família para 18 pessoas',
        expenses: [
          ExpenseItem(
            id: 'exp_201',
            title: 'Menu Degustação e Bebidas',
            vendor: 'Restaurante Porto',
            amount: 2950.00,
            category: ExpenseCategory.catering,
            date: DateTime(2026, 11, 15),
            isPaid: false,
          ),
          ExpenseItem(
            id: 'exp_202',
            title: 'Cobertura Fotográfica',
            vendor: 'Clara Sato Fotografia',
            amount: 1200.00,
            category: ExpenseCategory.photography,
            date: DateTime(2026, 11, 17),
            isPaid: true,
          ),
          ExpenseItem(
            id: 'exp_203',
            title: 'Taças Personalizadas',
            vendor: 'Oficina Cristal',
            amount: 420.00,
            category: ExpenseCategory.gifts,
            date: DateTime(2026, 11, 19),
            isPaid: true,
          ),
        ],
      ),
      PersonalEvent(
        id: 'evt_aniversario_leo',
        name: 'Festa de 8 anos do Léo',
        eventDate: DateTime(2027, 1, 16),
        venue: 'Salão do Condomínio',
        budget: 2200.00,
        notes: 'Festa infantil à tarde com tema de ciências',
        expenses: [
          ExpenseItem(
            id: 'exp_301',
            title: 'Taxa de Reserva do Salão',
            vendor: 'Administração do Condomínio',
            amount: 450.00,
            category: ExpenseCategory.venue,
            date: DateTime(2026, 11, 12),
            isPaid: true,
          ),
          ExpenseItem(
            id: 'exp_302',
            title: 'Salgados, Sucos e Bolo Temático',
            vendor: 'Confeitaria Doce Lar',
            amount: 820.00,
            category: ExpenseCategory.catering,
            date: DateTime(2026, 11, 20),
            isPaid: false,
          ),
          ExpenseItem(
            id: 'exp_303',
            title: 'Kits de Experimentos (Lembrancinhas)',
            vendor: 'Brincar & Descobrir',
            amount: 510.00,
            category: ExpenseCategory.gifts,
            date: DateTime(2026, 11, 20),
            isPaid: false,
          ),
        ],
      ),
    ];
  }
}
