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

        return LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 768;
            final isTablet =
                constraints.maxWidth >= 768 && constraints.maxWidth < 1100;

            if (isMobile) {
              return _buildMobileScaffold(context);
            }

            return _buildDesktopOrTabletScaffold(context, isTablet: isTablet);
          },
        );
      },
    );
  }

  Widget _buildDesktopOrTabletScaffold(BuildContext context,
      {required bool isTablet}) {
    return Scaffold(
      body: Row(
        children: [
          DesktopSidebar(
            store: _store,
            isCompact: isTablet,
            onCreateEvent: () => _handleCreateEvent(context),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _DesktopTopBar(
                  store: _store,
                  isTablet: isTablet,
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
  }

  Widget _buildMobileScaffold(BuildContext context) {
    final isEventDetail = _store.activeView == WorkspaceView.eventDetail;

    int currentNavIndex = 0;
    switch (_store.activeView) {
      case WorkspaceView.dashboard:
        currentNavIndex = 0;
        break;
      case WorkspaceView.allExpenses:
        currentNavIndex = 1;
        break;
      case WorkspaceView.categories:
        currentNavIndex = 2;
        break;
      case WorkspaceView.archivedEvents:
        currentNavIndex = 3;
        break;
      case WorkspaceView.eventDetail:
        currentNavIndex = 0;
        break;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceContainerLowest,
        elevation: 0,
        scrolledUnderElevation: 1,
        titleSpacing: isEventDetail ? 0 : 16,
        leading: isEventDetail
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: AppTheme.onSurface),
                onPressed: _store.selectDashboard,
              )
            : null,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isEventDetail) ...[
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
            ],
            Text(
              isEventDetail
                  ? (_store.selectedEvent?.name ?? 'Detalhes do Evento')
                  : 'EventLedger',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppTheme.onSurface,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Importar',
            icon: const Icon(Icons.file_upload_outlined, size: 20),
            onPressed: () => _handleImport(context),
          ),
          IconButton(
            tooltip: 'Exportar',
            icon: const Icon(Icons.file_download_outlined, size: 20),
            onPressed: () => _handleExport(context),
          ),
          IconButton(
            tooltip: 'Novo Evento',
            icon:
                const Icon(Icons.add_circle, color: AppTheme.primary, size: 26),
            onPressed: () => _handleCreateEvent(context),
          ),
        ],
      ),
      body: _buildActiveScreen(context),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentNavIndex,
        backgroundColor: AppTheme.surfaceContainerLow,
        indicatorColor: AppTheme.primaryFixed,
        onDestinationSelected: (idx) {
          switch (idx) {
            case 0:
              _store.selectDashboard();
              break;
            case 1:
              _store.selectAllExpenses();
              break;
            case 2:
              _store.selectCategories();
              break;
            case 3:
              _store.selectArchivedEvents();
              break;
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Painel',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded),
            label: 'Despesas',
          ),
          NavigationDestination(
            icon: Icon(Icons.category_outlined),
            selectedIcon: Icon(Icons.category_rounded),
            label: 'Categorias',
          ),
          NavigationDestination(
            icon: Icon(Icons.archive_outlined),
            selectedIcon: Icon(Icons.archive_rounded),
            label: 'Arquivados',
          ),
        ],
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
    required this.onCreateEvent,
    required this.onImport,
    required this.onExport,
    this.isTablet = false,
  });

  final LedgerStore store;
  final VoidCallback onCreateEvent;
  final VoidCallback onImport;
  final VoidCallback onExport;
  final bool isTablet;

  String get _breadcrumbCategory {
    switch (store.activeView) {
      case WorkspaceView.dashboard:
      case WorkspaceView.allExpenses:
      case WorkspaceView.categories:
      case WorkspaceView.archivedEvents:
        return 'Espaço de Trabalho';
      case WorkspaceView.eventDetail:
        return 'Eventos Pessoais';
    }
  }

  String get _breadcrumbTitle {
    switch (store.activeView) {
      case WorkspaceView.dashboard:
        return 'Painel de Despesas';
      case WorkspaceView.allExpenses:
        return 'Todas as Despesas';
      case WorkspaceView.categories:
        return 'Gestão de Categorias';
      case WorkspaceView.archivedEvents:
        return 'Eventos Arquivados';
      case WorkspaceView.eventDetail:
        return store.selectedEvent?.name ?? 'Evento';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 16 : 28),
      decoration: const BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        border: Border(
          bottom: BorderSide(color: Color(0x226F7A70)),
        ),
      ),
      child: Row(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _breadcrumbCategory,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.secondary,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  '/',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.outlineVariant,
                  ),
                ),
              ),
              Text(
                _breadcrumbTitle,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.onSurface,
                ),
              ),
            ],
          ),
          const Spacer(),
          if (!isTablet) ...[
            OutlinedButton.icon(
              onPressed: onImport,
              icon: const Icon(Icons.file_upload_outlined, size: 17),
              label: const Text('Importar'),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: onExport,
              icon: const Icon(Icons.file_download_outlined, size: 17),
              label: const Text('Exportar'),
            ),
          ] else ...[
            IconButton(
              tooltip: 'Importar',
              icon: const Icon(Icons.file_upload_outlined, size: 19),
              onPressed: onImport,
            ),
            IconButton(
              tooltip: 'Exportar',
              icon: const Icon(Icons.file_download_outlined, size: 19),
              onPressed: onExport,
            ),
          ],
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: onCreateEvent,
            icon: const Icon(Icons.add, size: 18),
            label: Text(isTablet ? 'Novo' : 'Novo Evento'),
          ),
        ],
      ),
    );
  }
}
