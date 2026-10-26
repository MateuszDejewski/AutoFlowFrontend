import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../data/sample_inventory.dart';
import '../models/order_part.dart';
import '../models/part.dart';
import '../navigation/manager_navigation.dart';
import '../widgets/manager_app_bar.dart';
import '../widgets/manager_navigation_bar.dart';
import '../widgets/manager_summary_card.dart';
import '../widgets/order_part_history_card.dart';
import '../widgets/part_catalog_card.dart';
import '../widgets/part_form_sheet.dart';
import '../widgets/record_order_part_sheet.dart';
import 'manager_calendar_screen.dart';

enum _InventoryViewTab { catalog, usageHistory }

class InventoryRecordsScreen extends StatefulWidget {
  const InventoryRecordsScreen({super.key});

  @override
  State<InventoryRecordsScreen> createState() => _InventoryRecordsScreenState();
}

class _InventoryRecordsScreenState extends State<InventoryRecordsScreen> {
  final List<Part> _parts = [...sampleParts];
  final List<OrderPart> _usageHistory = [...sampleOrderParts];
  final TextEditingController _searchController = TextEditingController();
  _InventoryViewTab _selectedTab = _InventoryViewTab.catalog;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Part> get _filteredParts {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _parts;
    return _parts.where((part) {
      return part.name.toLowerCase().contains(query) ||
          part.partNumber.toLowerCase().contains(query);
    }).toList();
  }

  List<OrderPart> get _filteredUsageHistory {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _usageHistory;
    return _usageHistory.where((entry) {
      return entry.partName.toLowerCase().contains(query) ||
          entry.partNumber.toLowerCase().contains(query) ||
          entry.orderId.toLowerCase().contains(query) ||
          entry.vehicleLabel.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> _showPartFormSheet({Part? existingPart}) async {
    final savedPart = await showModalBottomSheet<Part>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PartFormSheet(existingPart: existingPart),
    );
    if (savedPart == null || !mounted) return;

    setState(() {
      if (existingPart == null) {
        _parts.insert(0, savedPart);
      } else {
        final index = _parts.indexWhere((p) => p.id == existingPart.id);
        if (index != -1) _parts[index] = savedPart;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          existingPart == null
              ? 'Dodano nową część do ewidencji.'
              : 'Zaktualizowano dane części.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _recordPartUsage(Part part) async {
    if (part.stockQuantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Brak wystarczającego stanu magazynowego.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final usage = await showModalBottomSheet<OrderPart>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RecordOrderPartSheet(part: part),
    );
    if (usage == null || !mounted) return;

    setState(() {
      final index = _parts.indexWhere((p) => p.id == part.id);
      if (index != -1) {
        _parts[index] = _parts[index].copyWith(
          stockQuantity: _parts[index].stockQuantity - usage.quantity,
        );
      }
      _usageHistory.insert(0, usage);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Zarejestrowano użycie ${usage.quantity} szt. (${part.partNumber}) w zleceniu ${usage.orderId}.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalStockUnits = _parts.fold<int>(
      0,
      (sum, part) => sum + part.stockQuantity,
    );

    return Scaffold(
      appBar: ManagerAppBar(
        badgeLabel: 'MAGAZYN',
        icon: Icons.inventory_2_outlined,
        trailingAction: Padding(
          padding: const EdgeInsets.only(right: 12),
          child: FilledButton.icon(
            onPressed: _showPartFormSheet,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text(
              'Nowa część',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.teal,
              foregroundColor: Colors.white,
              visualDensity: VisualDensity.compact,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 840),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ewidencja części i historia zużycia',
                        style: TextStyle(
                          color: AppColors.ink,
                          fontSize: 24,
                          height: 1.2,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Zarządzaj katalogiem części zamiennych, stanami magazynowymi oraz rejestrem części użytych w zleceniach.',
                        style: TextStyle(color: AppColors.muted, fontSize: 13),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ManagerSummaryCard(
                              icon: Icons.category_outlined,
                              label: 'POZYCJE W KATALOGU',
                              value: '${_parts.length}',
                              tint: AppColors.teal,
                              background: const Color(0xFFE8F3F1),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ManagerSummaryCard(
                              icon: Icons.layers_outlined,
                              label: 'ŁĄCZNIE SZTUK NA STANIE',
                              value: '$totalStockUnits',
                              tint: const Color(0xFF356BB2),
                              background: const Color(0xFFE8F1FF),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ManagerSummaryCard(
                              icon: Icons.history_edu_rounded,
                              label: 'WPISY ZUŻYCIA',
                              value: '${_usageHistory.length}',
                              tint: const Color(0xFF70559A),
                              background: const Color(0xFFF0ECF8),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: _selectedTab == _InventoryViewTab.catalog
                              ? 'Szukaj po nazwie części lub numerze katalogowym…'
                              : 'Szukaj po numerze zlecenia, pojeździe lub części…',
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: AppColors.muted,
                          ),
                          suffixIcon: _searchController.text.isEmpty
                              ? null
                              : IconButton(
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {});
                                  },
                                  icon: const Icon(
                                    Icons.close_rounded,
                                    size: 18,
                                  ),
                                ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 13,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildTabSelector(),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: _selectedTab == _InventoryViewTab.catalog
                      ? _buildCatalogList()
                      : _buildUsageHistoryList(),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: ManagerNavigationBar(
        selectedIndex: 1,
        onDestinationSelected: (index) {
          if (index == 0) {
            navigateToManagerScreen(
              context,
              screen: const ManagerCalendarScreen(),
            );
          }
        },
      ),
    );
  }

  Widget _buildTabSelector() {
    return Row(
      children: [
        ChoiceChip(
          label: const Text('Stany magazynowe (Part)'),
          selected: _selectedTab == _InventoryViewTab.catalog,
          onSelected: (_) =>
              setState(() => _selectedTab = _InventoryViewTab.catalog),
          showCheckmark: false,
          labelStyle: TextStyle(
            color: _selectedTab == _InventoryViewTab.catalog
                ? Colors.white
                : AppColors.muted,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
          selectedColor: AppColors.teal,
          backgroundColor: Colors.white,
          side: BorderSide(
            color: _selectedTab == _InventoryViewTab.catalog
                ? AppColors.teal
                : const Color(0xFFE6EAEC),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        const SizedBox(width: 8),
        ChoiceChip(
          label: const Text('Historia zużycia (OrderPart)'),
          selected: _selectedTab == _InventoryViewTab.usageHistory,
          onSelected: (_) =>
              setState(() => _selectedTab = _InventoryViewTab.usageHistory),
          showCheckmark: false,
          labelStyle: TextStyle(
            color: _selectedTab == _InventoryViewTab.usageHistory
                ? Colors.white
                : AppColors.muted,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
          selectedColor: AppColors.teal,
          backgroundColor: Colors.white,
          side: BorderSide(
            color: _selectedTab == _InventoryViewTab.usageHistory
                ? AppColors.teal
                : const Color(0xFFE6EAEC),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ],
    );
  }

  Widget _buildCatalogList() {
    final items = _filteredParts;
    if (items.isEmpty) {
      return _buildEmptyListState('Nie znaleziono części w katalogu.');
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final part = items[index];
        return PartCatalogCard(
          part: part,
          onEdit: () => _showPartFormSheet(existingPart: part),
          onIssueToOrder: () => _recordPartUsage(part),
        );
      },
    );
  }

  Widget _buildUsageHistoryList() {
    final records = _filteredUsageHistory;
    if (records.isEmpty) {
      return _buildEmptyListState('Brak wpisów w historii zużycia części.');
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      itemCount: records.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final record = records[index];
        return OrderPartHistoryCard(record: record);
      },
    );
  }

  Widget _buildEmptyListState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.inventory_2_outlined,
              size: 40,
              color: AppColors.muted,
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
