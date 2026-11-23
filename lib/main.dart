import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'screens/all_expenses_screen.dart';
import 'screens/archived_events_screen.dart';
import 'screens/categories_screen.dart';
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

  void _showMessage(BuildContext context, String message) =>
      showAppSnackBar(context, message: message);

  Future<void> _handleExport(BuildContext context) async {
    const jsonType = XTypeGroup(label: 'JSON', extensions: ['json']);
    try {
      final location = await getSaveLocation(
        suggestedName: 'event_ledger_data.json',
        acceptedTypeGroups: const [jsonType],
        confirmButtonText: 'Exportar',
      );
      if (location == null) return;
      await _store.exportToFile(location.path);
      if (!context.mounted) return;
      _showMessage(context, 'Dados exportados com sucesso.');
    } catch (e) {
      if (!context.mounted) return;
      _showMessage(context, 'Não foi possível exportar os dados.');
    }
  }

  Future<void> _handleImport(BuildContext context) async {
    const jsonType = XTypeGroup(label: 'JSON', extensions: ['json']);
    try {
      final file = await openFile(
        acceptedTypeGroups: const [jsonType],
        confirmButtonText: 'Importar',
      );
      if (file == null) return;
      final result = await _store.importFromJson(await file.readAsString());
      if (!context.mounted) return;
      _showMessage(
        context,
        'Importação concluída: ${result.added} adicionado(s), '
        '${result.replaced} substituído(s).',
      );
    } on FormatException catch (e) {
      if (!context.mounted) return;
      _showMessage(context, e.message);
    } catch (_) {
      if (!context.mounted) return;
      _showMessage(context, 'Não foi possível importar o arquivo.');
    }
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

        final compact = MediaQuery.sizeOf(context).width < 768;

        return Scaffold(
          bottomNavigationBar: compact ? _buildBottomNav() : null,
          body: Row(
            children: [
              if (!compact)
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
                      compact: compact,
                      onCreateEvent: () => _handleCreateEvent(context),
                      onImport: () => _handleImport(context),
                      onExport: () => _handleExport(context),
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

  Widget _buildBottomNav() {
    final view = _store.activeView;
    final firstEvent = _store.events.isEmpty ? null : _store.events.first.id;
    final eventId = _store.selectedEventId ?? firstEvent;
    final index = switch (view) {
      WorkspaceView.dashboard => 0,
      WorkspaceView.allExpenses => 1,
      WorkspaceView.eventDetail => 2,
      WorkspaceView.categories => 3,
      WorkspaceView.archivedEvents => 4,
    };
    return NavigationBarTheme(
      data: NavigationBarThemeData(
        backgroundColor: AppTheme.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppTheme.paidBadgeBg,
        height: 64,
        labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(
              fontSize: 11,
              fontWeight: states.contains(WidgetState.selected)
                  ? FontWeight.w700
                  : FontWeight.w500,
              color: states.contains(WidgetState.selected)
                  ? AppTheme.paidBadgeFg
                  : AppTheme.inkMuted,
            )),
        iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(
              size: 22,
              color: states.contains(WidgetState.selected)
                  ? AppTheme.accent
                  : AppTheme.iconNeutral,
            )),
      ),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppTheme.border)),
        ),
        child: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: (i) {
            switch (i) {
              case 0:
                _store.selectDashboard();
              case 1:
                _store.selectAllExpenses();
              case 2:
                if (eventId != null) _store.selectEvent(eventId);
              case 3:
                _store.selectCategories();
              case 4:
                _store.selectArchivedEvents();
            }
          },
          destinations: const [
            NavigationDestination(
                icon: Icon(Icons.dashboard_outlined), label: 'Painel'),
            NavigationDestination(
                icon: Icon(Icons.receipt_long_outlined), label: 'Despesas'),
            NavigationDestination(
                icon: Icon(Icons.event_available_outlined), label: 'Evento'),
            NavigationDestination(
                icon: Icon(Icons.category_outlined), label: 'Categorias'),
            NavigationDestination(
                icon: Icon(Icons.archive_outlined), label: 'Arquivados'),
          ],
        ),
      ),
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
      case WorkspaceView.categories:
        return CategoriesScreen(store: _store);
      case WorkspaceView.archivedEvents:
        return ArchivedEventsScreen(store: _store);
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
    required this.compact,
    required this.onCreateEvent,
    required this.onImport,
    required this.onExport,
  });

  final bool compact;
  final LedgerStore store;
  final VoidCallback onCreateEvent;
  final VoidCallback onImport;
  final VoidCallback onExport;

  String get _breadcrumb {
    switch (store.activeView) {
      case WorkspaceView.dashboard:
        return 'Espaço de Trabalho / Painel de Despesas';
      case WorkspaceView.allExpenses:
        return 'Espaço de Trabalho / Todas as Despesas';
      case WorkspaceView.categories:
        return 'Espaço de Trabalho / Gestão de Categorias';
      case WorkspaceView.archivedEvents:
        return 'Espaço de Trabalho / Eventos Arquivados';
      case WorkspaceView.eventDetail:
        return 'Eventos Pessoais / ${store.selectedEvent?.name ?? 'Evento'}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: EdgeInsets.symmetric(horizontal: compact ? 16 : 32),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        children: [
          Flexible(
            child: Text(
              _breadcrumb,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.inkSecondary,
              ),
            ),
          ),
          const Spacer(),
          if (compact) ...[
            IconButton(
              tooltip: 'Importar',
              onPressed: onImport,
              icon: const Icon(Icons.file_upload_outlined, size: 20),
            ),
            IconButton(
              tooltip: 'Exportar',
              onPressed: onExport,
              icon: const Icon(Icons.file_download_outlined, size: 20),
            ),
            const SizedBox(width: 4),
            IconButton.filled(
              tooltip: 'Novo Evento',
              onPressed: onCreateEvent,
              icon: const Icon(Icons.add, size: 20),
            ),
          ] else ...[
            OutlinedButton.icon(
              onPressed: onImport,
              icon: const Icon(Icons.file_upload_outlined, size: 18),
              label: const Text('Importar'),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: onExport,
              icon: const Icon(Icons.file_download_outlined, size: 18),
              label: const Text('Exportar'),
            ),
            const SizedBox(width: 12),
            FilledButton.icon(
              onPressed: onCreateEvent,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Novo Evento'),
            ),
          ],
        ],
      ),
    );
  }
}
