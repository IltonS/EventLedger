import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:event_ledger_desktop/models/event_models.dart';
import 'package:event_ledger_desktop/screens/archived_events_screen.dart';
import 'package:event_ledger_desktop/state/ledger_store.dart';
import 'package:event_ledger_desktop/theme/app_theme.dart';
import 'package:event_ledger_desktop/widgets/dialogs.dart';

Widget _buildTestApp({required LedgerStore store, required Widget child}) {
  return MaterialApp(
    theme: AppTheme.buildTheme(),
    locale: const Locale('pt', 'BR'),
    supportedLocales: const [Locale('pt', 'BR')],
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: Scaffold(
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) => child,
      ),
    ),
  );
}

void main() {
  importMergeTests();
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await initializeDateFormatting('pt_BR');
  });

  group('PersonalEvent archive model tests', () {
    test('PersonalEvent defaults isArchived to false', () {
      final event = PersonalEvent(
        id: 'evt_1',
        name: 'Casamento',
        eventDate: DateTime(2026, 12, 10),
        venue: 'Espaço Jardim',
        budget: 50000.0,
        expenses: const [],
      );

      expect(event.isArchived, isFalse);
    });

    test('PersonalEvent copyWith updates isArchived', () {
      final event = PersonalEvent(
        id: 'evt_1',
        name: 'Casamento',
        eventDate: DateTime(2026, 12, 10),
        venue: 'Espaço Jardim',
        budget: 50000.0,
        expenses: const [],
      );

      final archived = event.copyWith(isArchived: true);
      expect(archived.isArchived, isTrue);

      final unarchived = archived.copyWith(isArchived: false);
      expect(unarchived.isArchived, isFalse);
    });

    test('PersonalEvent json serialization preserves isArchived', () {
      final event = PersonalEvent(
        id: 'evt_1',
        name: 'Aniversário 30 Anos',
        eventDate: DateTime(2026, 5, 20),
        venue: 'Salão Nobre',
        budget: 15000.0,
        notes: 'Festa surpresa',
        isArchived: true,
        expenses: [
          ExpenseItem(
            id: 'exp_1',
            title: 'Bolo',
            vendor: 'Confeitaria Doce',
            amount: 450.0,
            category: ExpenseCategory.defaultCategories[1],
            date: DateTime(2026, 5, 10),
            isPaid: true,
          ),
        ],
      );

      final json = event.toJson();
      expect(json['isArchived'], isTrue);

      final decoded = PersonalEvent.fromJson(json);
      expect(decoded.id, 'evt_1');
      expect(decoded.name, 'Aniversário 30 Anos');
      expect(decoded.isArchived, isTrue);
      expect(decoded.expenses.length, 1);
      expect(decoded.expenses.first.amount, 450.0);
    });
  });

  group('LedgerStore archive & KPI isolation tests', () {
    test('Archived events are excluded from dashboard KPIs and active events',
        () async {
      final store = LedgerStore();

      // Create two events
      await store.addEvent(
        name: 'Evento Ativo',
        eventDate: DateTime(2026, 6, 15),
        venue: 'Local A',
        budget: 10000.0,
      );
      final activeEventId = store.events.first.id;

      await store.addEvent(
        name: 'Evento Para Arquivar',
        eventDate: DateTime(2026, 7, 20),
        venue: 'Local B',
        budget: 20000.0,
      );
      final toArchiveEventId = store.events.first.id;

      // Add expenses to both
      await store.addExpense(
        eventId: activeEventId,
        title: 'Despesa Ativa Paga',
        vendor: 'Fornecedor A1',
        amount: 2500.0,
        category: store.categories.first,
        date: DateTime(2026, 6, 1),
        isPaid: true,
      );
      await store.addExpense(
        eventId: activeEventId,
        title: 'Despesa Ativa Pendente',
        vendor: 'Fornecedor A2',
        amount: 1500.0,
        category: store.categories.first,
        date: DateTime(2026, 6, 2),
        isPaid: false,
      );

      await store.addExpense(
        eventId: toArchiveEventId,
        title: 'Despesa Arquivada Paga',
        vendor: 'Fornecedor B1',
        amount: 8000.0,
        category: store.categories.first,
        date: DateTime(2026, 7, 1),
        isPaid: true,
      );
      await store.addExpense(
        eventId: toArchiveEventId,
        title: 'Despesa Arquivada Pendente',
        vendor: 'Fornecedor B2',
        amount: 4000.0,
        category: store.categories.first,
        date: DateTime(2026, 7, 2),
        isPaid: false,
      );

      // Verify before archiving
      expect(store.events.length, 2);
      expect(store.archivedEvents.length, 0);
      expect(store.totalBudgetAllEvents, 30000.0);
      expect(store.totalSpentAllEvents, 16000.0);
      expect(store.totalPaidAllEvents, 10500.0);
      expect(store.totalUnpaidAllEvents, 5500.0);
      expect(store.totalExpenseCount, 4);

      // Archive toArchiveEventId
      await store.archiveEvent(toArchiveEventId);

      // Check KPIs: ONLY active event metrics should be counted
      expect(store.events.length, 1);
      expect(store.events.first.id, activeEventId);
      expect(store.archivedEvents.length, 1);
      expect(store.archivedEvents.first.id, toArchiveEventId);

      // KPIs must not include archived events!
      expect(store.totalBudgetAllEvents, 10000.0);
      expect(store.totalSpentAllEvents, 4000.0);
      expect(store.totalPaidAllEvents, 2500.0);
      expect(store.totalUnpaidAllEvents, 1500.0);
      expect(store.totalExpenseCount, 2);

      // Category spending should also exclude archived events
      final catId = store.categories.first.id;
      expect(store.getTotalSpentForCategory(catId), 4000.0);
      expect(store.getExpenseCountForCategory(catId), 2);

      // Unarchive event
      await store.unarchiveEvent(toArchiveEventId);

      // KPIs should now include it again
      expect(store.events.length, 2);
      expect(store.archivedEvents.length, 0);
      expect(store.totalBudgetAllEvents, 30000.0);
      expect(store.totalSpentAllEvents, 16000.0);

      // Archive again and permanently delete
      await store.archiveEvent(toArchiveEventId);
      expect(store.archivedEvents.length, 1);

      await store.deleteEvent(toArchiveEventId);
      expect(store.archivedEvents.length, 0);
      expect(store.events.length, 1);
      expect(store.allEvents.length, 1);
    });
  });

  group('ArchivedEventsScreen widget tests', () {
    testWidgets('Displays empty state when no archived events exist',
        (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final store = LedgerStore();
      await tester.pumpWidget(
        _buildTestApp(store: store, child: ArchivedEventsScreen(store: store)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Gestão de Eventos Arquivados'), findsOneWidget);
      expect(find.text('Nenhum evento arquivado'), findsOneWidget);
    });

    testWidgets('Displays archived events in table', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final event = PersonalEvent(
        id: 'evt_archived_1',
        name: 'Festa de Formatura',
        eventDate: DateTime(2026, 11, 20),
        venue: 'Centro de Convenções',
        budget: 25000.0,
        isArchived: true,
        expenses: const [],
      );

      final store = LedgerStore(initialEvents: [event]);

      await tester.pumpWidget(
        _buildTestApp(store: store, child: ArchivedEventsScreen(store: store)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Festa de Formatura'), findsOneWidget);
      expect(find.text('Centro de Convenções'), findsOneWidget);
      expect(find.text('Desarquivar'), findsOneWidget);
      expect(find.text('Excluir'), findsOneWidget);
    });

    testWidgets('Shows confirmation dialog on delete button click',
        (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final event = PersonalEvent(
        id: 'evt_archived_2',
        name: 'Evento Antigo',
        eventDate: DateTime(2025, 1, 15),
        venue: 'Clube Velho',
        budget: 5000.0,
        isArchived: true,
        expenses: const [],
      );

      final store = LedgerStore(initialEvents: [event]);

      await tester.pumpWidget(
        _buildTestApp(store: store, child: ArchivedEventsScreen(store: store)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Evento Antigo'), findsOneWidget);

      // Scroll into view if needed and tap Excluir
      await tester.ensureVisible(find.text('Excluir'));
      await tester.tap(find.text('Excluir'));
      await tester.pumpAndSettle();

      // Verify confirmation dialog
      expect(find.text('Excluir evento definitivamente?'), findsOneWidget);
      expect(find.text('Cancelar'), findsOneWidget);
      expect(
        find.widgetWithText(FilledButton, 'Excluir Definitivamente'),
        findsOneWidget,
      );
    });

    testWidgets('showAppSnackBar displays close icon and auto-closes',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.buildTheme(),
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showAppSnackBar(
                    context,
                    message: 'Mensagem de teste',
                    actionLabel: 'Desfazer',
                    onAction: () {},
                    duration: const Duration(milliseconds: 500),
                  );
                },
                child: const Text('Disparar'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Disparar'));
      await tester.pump();

      expect(find.text('Mensagem de teste'), findsOneWidget);
      expect(find.text('Desfazer'), findsOneWidget);
      // Close icon should be present
      expect(find.byIcon(Icons.close), findsOneWidget);

      // Advance time past the duration
      await tester.pump(const Duration(milliseconds: 900));
      await tester.pumpAndSettle();

      // SnackBar should be dismissed
      expect(find.text('Mensagem de teste'), findsNothing);
    });
  });
}

void importMergeTests() {
  group('LedgerStore import', () {
    PersonalEvent ev(String id, String name, double budget) => PersonalEvent(
          id: id,
          name: name,
          eventDate: DateTime(2026, 1, 1),
          venue: '',
          budget: budget,
          notes: '',
          expenses: const [],
        );

    test('adds new events and replaces same-name ones', () async {
      final store = LedgerStore(
        initialEvents: [ev('a', 'Festa', 100), ev('b', 'Jantar', 50)],
      );
      final raw = jsonEncode({
        'categories': <dynamic>[],
        'events': [
          ev('x', ' festa ', 999).toJson(),
          ev('y', 'Churrasco', 10).toJson(),
        ],
      });
      final result = await store.importFromJson(raw);
      expect(result.added, 1);
      expect(result.replaced, 1);
      expect(store.allEvents.length, 3);
      final festa = store.allEvents.firstWhere((e) => e.id == 'a');
      expect(festa.budget, 999);
    });

    test('rejects invalid files', () async {
      final store = LedgerStore();
      expect(() => store.importFromJson('nope'), throwsFormatException);
      expect(() => store.importFromJson('{"a":1}'), throwsFormatException);
    });
  });
}
