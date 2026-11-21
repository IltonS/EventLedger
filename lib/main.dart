import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'screens/all_expenses_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/event_detail_screen.dart';
import 'state/ledger_store.dart';
import 'theme/app_theme.dart';
import 'widgets/desktop_sidebar.dart';
import 'widgets/dialogs.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR');
  runApp(const EventLedgerDesktopApp());
}

class EventLedgerDesktopApp extends StatelessWidget {
  const EventLedgerDesktopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EventLedger',
      debugShowCheckedModeBanner: false,
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.buildTheme(),
      home: const EventLedgerHomeScreen(),
    );
  }
}

class EventLedgerHomeScreen extends StatefulWidget {
  const EventLedgerHomeScreen({super.key});

  @override
  State<EventLedgerHomeScreen> createState() => _EventLedgerHomeScreenState();
}

class _EventLedgerHomeScreenState extends State<EventLedgerHomeScreen> {
  final LedgerStore _store = LedgerStore();

  @override
  void initState() {
    super.initState();
    _store.initialize();
  }

  @override
  void dispose() {
    _store.dispose();
    super.dispose();
  }

  Future<void> _handleCreateEvent(BuildContext context) async {
    final result = await showEventFormDialog(context);
    if (result == null) return;
    await _store.addEvent(
      name: result.name,
      eventDate: result.eventDate,
      venue: result.venue,
      budget: result.budget,
      notes: result.notes,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _store,
      builder: (context, _) {
        if (!_store.isLoaded) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          body: Row(
            children: [
              DesktopSidebar(
                store: _store,
                onCreateEvent: () => _handleCreateEvent(context),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _DesktopTopBar(
                      store: _store,
                      onCreateEvent: () => _handleCreateEvent(context),
                    ),
                    Expanded(child: _buildActiveScreen(context)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActiveScreen(BuildContext context) {
    switch (_store.activeView) {
      case WorkspaceView.dashboard:
        return DashboardScreen(
          store: _store,
          onCreateEvent: () => _handleCreateEvent(context),
        );
      case WorkspaceView.allExpenses:
        return AllExpensesScreen(store: _store);
      case WorkspaceView.eventDetail:
        final event = _store.selectedEvent;
        if (event == null) {
          return DashboardScreen(
            store: _store,
            onCreateEvent: () => _handleCreateEvent(context),
          );
        }
        return EventDetailScreen(store: _store, event: event);
    }
  }
}

class _DesktopTopBar extends StatelessWidget {
  const _DesktopTopBar({
    required this.store,
    required this.onCreateEvent,
  });

  final LedgerStore store;
  final VoidCallback onCreateEvent;

  String get _breadcrumb {
    switch (store.activeView) {
      case WorkspaceView.dashboard:
        return 'Espaço de Trabalho / Painel de Despesas';
      case WorkspaceView.allExpenses:
        return 'Espaço de Trabalho / Todas as Despesas';
      case WorkspaceView.eventDetail:
        return 'Eventos Pessoais / ${store.selectedEvent?.name ?? 'Evento'}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        children: [
          Text(
            _breadcrumb,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: AppTheme.inkSecondary,
            ),
          ),
          const Spacer(),
          FilledButton.icon(
            onPressed: onCreateEvent,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Novo Evento'),
          ),
        ],
      ),
    );
  }
}
