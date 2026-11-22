import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../models/event_models.dart';

enum WorkspaceView {
  dashboard,
  allExpenses,
  categories,
  eventDetail,
  archivedEvents,
}

enum PaymentFilter { all, paid, unpaid }

/// Summary of a data import/merge operation.
class ImportResult {
  const ImportResult({
    required this.added,
    required this.replaced,
    required this.categoriesAdded,
  });

  final int added;
  final int replaced;
  final int categoriesAdded;
}

class LedgerStore extends ChangeNotifier {
  LedgerStore({
    List<PersonalEvent>? initialEvents,
    List<ExpenseCategory>? initialCategories,
  }) {
    if (initialEvents != null) {
      _events = List.from(initialEvents);
    }
    if (initialCategories != null) {
      _categories = List.from(initialCategories);
    }
  }

  List<PersonalEvent> _events = [];
  List<ExpenseCategory> _categories =
      List.from(ExpenseCategory.defaultCategories);
  WorkspaceView _activeView = WorkspaceView.dashboard;
  String? _selectedEventId;
  bool _isLoaded = false;

  List<PersonalEvent> get events =>
      List.unmodifiable(_events.where((e) => !e.isArchived));
  List<PersonalEvent> get archivedEvents =>
      List.unmodifiable(_events.where((e) => e.isArchived));
  List<PersonalEvent> get allEvents => List.unmodifiable(_events);
  List<ExpenseCategory> get categories => List.unmodifiable(_categories);
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
      events.fold<double>(0, (sum, e) => sum + e.budget);

  bool get hasAnyEventWithBudget => events.any((e) => e.budget > 0);

  double get totalSpentAllEvents =>
      events.fold<double>(0, (sum, e) => sum + e.totalSpent);

  double get totalPaidAllEvents =>
      events.fold<double>(0, (sum, e) => sum + e.paidAmount);

  double get totalUnpaidAllEvents =>
      events.fold<double>(0, (sum, e) => sum + e.unpaidAmount);

  int get totalExpenseCount =>
      events.fold<int>(0, (sum, e) => sum + e.expenses.length);

  Map<ExpenseCategory, double> get aggregatedCategoryTotals {
    final map = <ExpenseCategory, double>{};
    for (final event in events) {
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
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          if (decoded['categories'] is List) {
            _categories = (decoded['categories'] as List<dynamic>)
                .map((c) => ExpenseCategory.fromJson(c as Map<String, dynamic>))
                .toList();
          } else {
            _categories = List.from(ExpenseCategory.defaultCategories);
          }
          if (decoded['events'] is List) {
            _events = (decoded['events'] as List<dynamic>)
                .map((e) => PersonalEvent.fromJson(
                      e as Map<String, dynamic>,
                      categories: _categories,
                    ))
                .toList();
          } else {
            _events = [];
          }
        } else if (decoded is List<dynamic>) {
          _categories = List.from(ExpenseCategory.defaultCategories);
          _events = decoded
              .map((e) => PersonalEvent.fromJson(
                    e as Map<String, dynamic>,
                    categories: _categories,
                  ))
              .toList();
        }
      } else {
        _categories = List.from(ExpenseCategory.defaultCategories);
        _events = [];
        await _persist();
      }
    } catch (_) {
      _categories = List.from(ExpenseCategory.defaultCategories);
      _events = [];
    }

    if (_events.isNotEmpty) {
      final active = _events.where((e) => !e.isArchived).toList();
      _selectedEventId = active.isNotEmpty ? active.first.id : null;
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

  void selectCategories() {
    _activeView = WorkspaceView.categories;
    notifyListeners();
  }

  void selectArchivedEvents() {
    _activeView = WorkspaceView.archivedEvents;
    notifyListeners();
  }

  void selectEvent(String eventId) {
    _selectedEventId = eventId;
    _activeView = WorkspaceView.eventDetail;
    notifyListeners();
  }

  ExpenseCategory getCategoryById(String id) {
    for (final cat in _categories) {
      if (cat.id == id) return cat;
    }
    return _categories.isNotEmpty
        ? _categories.last
        : ExpenseCategory.defaultCategories.last;
  }

  int getExpenseCountForCategory(String categoryId) {
    var count = 0;
    for (final event in events) {
      for (final exp in event.expenses) {
        if (exp.category.id == categoryId) {
          count++;
        }
      }
    }
    return count;
  }

  double getTotalSpentForCategory(String categoryId) {
    var total = 0.0;
    for (final event in events) {
      for (final exp in event.expenses) {
        if (exp.category.id == categoryId) {
          total += exp.amount;
        }
      }
    }
    return total;
  }

  Future<void> addCategory({
    required String name,
    required IconData icon,
    required Color color,
  }) async {
    final newCat = ExpenseCategory(
      id: 'cat_${DateTime.now().microsecondsSinceEpoch}',
      name: name.trim(),
      icon: icon,
      color: color,
    );
    _categories = [..._categories, newCat];
    notifyListeners();
    await _persist();
  }

  Future<void> updateCategory(ExpenseCategory updated) async {
    _categories = [
      for (final cat in _categories)
        if (cat.id == updated.id) updated else cat,
    ];
    _events = [
      for (final event in _events)
        event.copyWith(
          expenses: [
            for (final exp in event.expenses)
              if (exp.category.id == updated.id)
                exp.copyWith(category: updated)
              else
                exp,
          ],
        ),
    ];
    notifyListeners();
    await _persist();
  }

  Future<void> deleteCategory(
    String categoryId, {
    ExpenseCategory? replacement,
  }) async {
    if (_categories.length <= 1) return;

    final fallback = replacement ??
        _categories.firstWhere(
          (c) => c.id != categoryId,
          orElse: () => _categories.first,
        );

    _categories = _categories.where((c) => c.id != categoryId).toList();
    _events = [
      for (final event in _events)
        event.copyWith(
          expenses: [
            for (final exp in event.expenses)
              if (exp.category.id == categoryId)
                exp.copyWith(category: fallback)
              else
                exp,
          ],
        ),
    ];
    notifyListeners();
    await _persist();
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

  Future<void> archiveEvent(String eventId) async {
    _events = [
      for (final event in _events)
        if (event.id == eventId) event.copyWith(isArchived: true) else event,
    ];
    if (_selectedEventId == eventId) {
      final active = events;
      _selectedEventId = active.isNotEmpty ? active.first.id : null;
      if (_activeView == WorkspaceView.eventDetail) {
        _activeView = WorkspaceView.dashboard;
      }
    }
    notifyListeners();
    await _persist();
  }

  Future<void> unarchiveEvent(String eventId) async {
    _events = [
      for (final event in _events)
        if (event.id == eventId) event.copyWith(isArchived: false) else event,
    ];
    _selectedEventId = eventId;
    notifyListeners();
    await _persist();
  }

  Future<void> deleteEvent(String eventId) async {
    _events = _events.where((e) => e.id != eventId).toList();
    if (_selectedEventId == eventId) {
      final active = events;
      _selectedEventId = active.isNotEmpty ? active.first.id : null;
      if (_activeView == WorkspaceView.eventDetail) {
        _activeView = WorkspaceView.dashboard;
      }
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

  /// Exports the current data as JSON to [path].
  Future<void> exportToFile(String path) async {
    await File(path).writeAsString(_encodeData());
  }

  /// Reads a JSON file from [path] and merges it into the current data.
  Future<ImportResult> importFromFile(String path) async {
    final raw = await File(path).readAsString();
    return importFromJson(raw);
  }

  /// Merges exported JSON into the current data.
  ///
  /// Events whose name (trimmed, case-insensitive) already exists are replaced
  /// by the imported ones (keeping the local event id); other events are added.
  /// Categories missing locally (by id) are added. Throws [FormatException]
  /// if [raw] is not a valid EventLedger file.
  Future<ImportResult> importFromJson(String raw) async {
    final dynamic decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException {
      throw const FormatException('Arquivo JSON inválido.');
    }

    final List<dynamic> rawEvents;
    List<dynamic> rawCategories = const [];
    if (decoded is Map<String, dynamic> && decoded['events'] is List) {
      rawEvents = decoded['events'] as List<dynamic>;
      if (decoded['categories'] is List) {
        rawCategories = decoded['categories'] as List<dynamic>;
      }
    } else if (decoded is List<dynamic>) {
      rawEvents = decoded;
    } else {
      throw const FormatException('Formato de arquivo não reconhecido.');
    }

    final List<ExpenseCategory> importedCategories;
    final List<PersonalEvent> importedEvents;
    final mergedCategories = List<ExpenseCategory>.from(_categories);
    var categoriesAdded = 0;
    try {
      importedCategories = rawCategories
          .map((c) => ExpenseCategory.fromJson(c as Map<String, dynamic>))
          .toList();
      for (final cat in importedCategories) {
        if (!mergedCategories.any((c) => c.id == cat.id)) {
          mergedCategories.add(cat);
          categoriesAdded++;
        }
      }
      importedEvents = rawEvents
          .map((e) => PersonalEvent.fromJson(
                e as Map<String, dynamic>,
                categories: mergedCategories,
              ))
          .toList();
    } on Object {
      throw const FormatException('Formato de arquivo não reconhecido.');
    }

    String key(String name) => name.trim().toLowerCase();
    final events = List<PersonalEvent>.from(_events);
    var added = 0;
    var replaced = 0;
    for (final incoming in importedEvents) {
      final index = events.indexWhere((e) => key(e.name) == key(incoming.name));
      if (index >= 0) {
        events[index] = incoming.copyWith(id: events[index].id);
        replaced++;
      } else {
        // Avoid id clashes with a differently named local event.
        final clash = events.any((e) => e.id == incoming.id);
        events.insert(
          0,
          clash
              ? incoming.copyWith(
                  id: 'evt_${DateTime.now().microsecondsSinceEpoch}_$added',
                )
              : incoming,
        );
        added++;
      }
    }

    _categories = mergedCategories;
    _events = events;
    notifyListeners();
    await _persist();
    return ImportResult(
      added: added,
      replaced: replaced,
      categoriesAdded: categoriesAdded,
    );
  }

  String _encodeData() => jsonEncode({
        'categories': _categories.map((c) => c.toJson()).toList(),
        'events': _events.map((e) => e.toJson()).toList(),
      });

  Future<File> _storageFile() async {
    final dir = await getApplicationSupportDirectory();
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return File(
      '${dir.path}${Platform.pathSeparator}event_ledger_data.json',
    );
  }

  Future<void> _persist() async {
    try {
      final file = await _storageFile();
      await file.writeAsString(_encodeData());
    } catch (_) {
      // Ignora erros de gravação em plataformas sem suporte local.
    }
  }
}
