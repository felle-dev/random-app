import 'package:flutter/material.dart';
import 'package:random/page/utilities/exif_eraser.dart';
import 'package:random/page/utilities/info.dart';
import 'package:random/page/utilities/quick_tiles.dart';
import 'package:random/page/utilities/unit_converter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UtilityItem {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color containerColor;
  final Widget Function() pageBuilder;
  bool isPinned;

  UtilityItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.containerColor,
    required this.pageBuilder,
    this.isPinned = false,
  });
}

class UtilitiesTab extends StatefulWidget {
  const UtilitiesTab({super.key});

  @override
  State<UtilitiesTab> createState() => _UtilitiesTabState();
}

class _UtilitiesTabState extends State<UtilitiesTab> {
  late List<UtilityItem> _utilities;
  static const String _pinnedKey = 'pinned_utilities';

  @override
  void initState() {
    super.initState();
    _utilities = [];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_utilities.isEmpty) {
      final colorScheme = Theme.of(context).colorScheme;
      _utilities = [
        UtilityItem(
          id: 'exif_eraser',
          title: 'EXIF Eraser',
          subtitle: 'Remove metadata',
          icon: Icons.photo_camera_back_outlined,
          containerColor: colorScheme.secondaryContainer,
          pageBuilder: () => const ExifEraserPage(),
        ),
        UtilityItem(
          id: 'quick_tiles',
          title: 'Quick Tiles',
          subtitle: 'Manage settings',
          icon: Icons.dashboard_customize_outlined,
          containerColor: colorScheme.primaryContainer,
          pageBuilder: () => const QuickTilesPage(),
        ),
        UtilityItem(
          id: 'unit_converter',
          title: 'Unit Converter',
          subtitle: 'Convert units',
          icon: Icons.compare_arrows_outlined,
          containerColor: colorScheme.tertiaryContainer,
          pageBuilder: () => const UnitConverterPage(),
        ),
        UtilityItem(
          id: 'device_info',
          title: 'Device Info',
          subtitle: 'Phone specs',
          icon: Icons.info_outline,
          containerColor: colorScheme.primaryContainer,
          pageBuilder: () => const DeviceInfoPage(),
        ),
      ];
      _loadPinnedState();
    }
  }

  // Load pinned state from SharedPreferences
  Future<void> _loadPinnedState() async {
    final prefs = await SharedPreferences.getInstance();
    final pinnedIds = prefs.getStringList(_pinnedKey) ?? [];

    setState(() {
      for (var utility in _utilities) {
        utility.isPinned = pinnedIds.contains(utility.id);
      }
    });
  }

  // Save pinned state to SharedPreferences
  Future<void> _savePinnedState() async {
    final prefs = await SharedPreferences.getInstance();
    final pinnedIds = _utilities
        .where((u) => u.isPinned)
        .map((u) => u.id)
        .toList();
    await prefs.setStringList(_pinnedKey, pinnedIds);
  }

  List<UtilityItem> get _pinnedUtilities =>
      _utilities.where((u) => u.isPinned).toList();

  List<UtilityItem> get _unpinnedUtilities =>
      _utilities.where((u) => !u.isPinned).toList();

  void _togglePin(UtilityItem item) {
    setState(() {
      item.isPinned = !item.isPinned;
    });
    _savePinnedState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final pinnedItems = _pinnedUtilities;
    final unpinnedItems = _unpinnedUtilities;

    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: CustomScrollView(
        slivers: [
          // Pinned section
          if (pinnedItems.isNotEmpty) ...[
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Icon(Icons.push_pin, size: 16, color: colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Pinned',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final item = pinnedItems[index];
                  return _UtilityListCard(
                    key: ValueKey(item.id),
                    item: item,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => item.pageBuilder(),
                        ),
                      );
                    },
                    onTogglePin: () => _togglePin(item),
                  );
                }, childCount: pinnedItems.length),
              ),
            ),
          ],

          // Unpinned section
          if (unpinnedItems.isNotEmpty) ...[
            if (pinnedItems.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'All Utilities',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final item = unpinnedItems[index];
                  return _UtilityListCard(
                    key: ValueKey(item.id),
                    item: item,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => item.pageBuilder(),
                        ),
                      );
                    },
                    onTogglePin: () => _togglePin(item),
                  );
                }, childCount: unpinnedItems.length),
              ),
            ),
          ],

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

class _UtilityListCard extends StatelessWidget {
  final UtilityItem item;
  final VoidCallback onTap;
  final VoidCallback onTogglePin;

  const _UtilityListCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onTogglePin,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final onColor = _getOnColor(colorScheme, item.containerColor);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(48),
          child: Ink(
            decoration: BoxDecoration(
              color: item.containerColor,
              borderRadius: BorderRadius.circular(48),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Icon
                  Container(
                    width: 56,
                    height: 56,
                    child: Icon(item.icon, size: 28, color: onColor),
                  ),
                  // Title and subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: onColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.subtitle,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: onColor.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Pin button
                  IconButton(
                    onPressed: onTogglePin,
                    icon: Icon(
                      item.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                      color: item.isPinned
                          ? colorScheme.primary
                          : onColor.withOpacity(0.6),
                    ),
                    tooltip: item.isPinned ? 'Unpin' : 'Pin',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getOnColor(ColorScheme colorScheme, Color containerColor) {
    if (containerColor == colorScheme.primaryContainer) {
      return colorScheme.onPrimaryContainer;
    } else if (containerColor == colorScheme.secondaryContainer) {
      return colorScheme.onSecondaryContainer;
    } else if (containerColor == colorScheme.tertiaryContainer) {
      return colorScheme.onTertiaryContainer;
    } else if (containerColor == colorScheme.errorContainer) {
      return colorScheme.onErrorContainer;
    } else {
      return colorScheme.onSurfaceVariant;
    }
  }
}
