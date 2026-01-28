import 'package:flutter/material.dart';
import 'package:random/page/random/random_number.dart';
import 'package:random/page/random/dice_roller.dart';
import 'package:random/page/random/coin_flip.dart';
import 'package:random/page/random/spinning_wheel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RandomToolItem {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color containerColor;
  final Widget Function() pageBuilder;
  bool isPinned;

  RandomToolItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.containerColor,
    required this.pageBuilder,
    this.isPinned = false,
  });
}

class RandomToolsTab extends StatefulWidget {
  const RandomToolsTab({super.key});

  @override
  State<RandomToolsTab> createState() => _RandomToolsTabState();
}

class _RandomToolsTabState extends State<RandomToolsTab> {
  late List<RandomToolItem> _tools;
  static const String _pinnedKey = 'pinned_random_tools';

  @override
  void initState() {
    super.initState();
    _tools = [];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_tools.isEmpty) {
      final colorScheme = Theme.of(context).colorScheme;
      _tools = [
        RandomToolItem(
          id: 'random_number',
          title: 'Random Number',
          subtitle: 'Generate numbers',
          icon: Icons.numbers,
          containerColor: colorScheme.primaryContainer,
          pageBuilder: () => const RandomNumberPage(),
        ),
        RandomToolItem(
          id: 'dice_roller',
          title: 'Dice Roller',
          subtitle: 'Roll virtual dice',
          icon: Icons.casino_outlined,
          containerColor: colorScheme.secondaryContainer,
          pageBuilder: () => const DiceRollerPage(),
        ),
        RandomToolItem(
          id: 'coin_flip',
          title: 'Coin Flip',
          subtitle: 'Flip a virtual coin',
          icon: Icons.monetization_on_outlined,
          containerColor: colorScheme.tertiaryContainer,
          pageBuilder: () => const CoinFlipPage(),
        ),
        RandomToolItem(
          id: 'spinning_wheel',
          title: 'Spinning Wheel',
          subtitle: 'Spin to decide',
          icon: Icons.album_outlined,
          containerColor: colorScheme.errorContainer,
          pageBuilder: () => const SpinningWheelPage(),
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
      for (var tool in _tools) {
        tool.isPinned = pinnedIds.contains(tool.id);
      }
    });
  }

  // Save pinned state to SharedPreferences
  Future<void> _savePinnedState() async {
    final prefs = await SharedPreferences.getInstance();
    final pinnedIds = _tools.where((t) => t.isPinned).map((t) => t.id).toList();
    await prefs.setStringList(_pinnedKey, pinnedIds);
  }

  List<RandomToolItem> get _pinnedTools =>
      _tools.where((t) => t.isPinned).toList();

  List<RandomToolItem> get _unpinnedTools =>
      _tools.where((t) => !t.isPinned).toList();

  void _togglePin(RandomToolItem item) {
    setState(() {
      item.isPinned = !item.isPinned;
    });
    _savePinnedState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final pinnedItems = _pinnedTools;
    final unpinnedItems = _unpinnedTools;

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
                  return _RandomToolListCard(
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
                    'All Tools',
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
                  return _RandomToolListCard(
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

class _RandomToolListCard extends StatelessWidget {
  final RandomToolItem item;
  final VoidCallback onTap;
  final VoidCallback onTogglePin;

  const _RandomToolListCard({
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
