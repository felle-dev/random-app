import 'package:flutter/material.dart';
import 'package:random/page/generators/device.dart';
import 'package:random/page/generators/email.dart';
import 'package:random/page/generators/identity.dart';
import 'package:random/page/generators/password.dart';
import 'package:random/page/generators/phone.dart';
import 'package:random/page/generators/username.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GeneratorItem {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color containerColor;
  final Widget Function() pageBuilder;
  bool isPinned;

  GeneratorItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.containerColor,
    required this.pageBuilder,
    this.isPinned = false,
  });
}

class GeneratorsTab extends StatefulWidget {
  const GeneratorsTab({super.key});

  @override
  State<GeneratorsTab> createState() => _GeneratorsTabState();
}

class _GeneratorsTabState extends State<GeneratorsTab> {
  late List<GeneratorItem> _generators;
  static const String _pinnedKey = 'pinned_generators';

  @override
  void initState() {
    super.initState();
    _initializeGenerators();
  }

  void _initializeGenerators() {
    _generators = [];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_generators.isEmpty) {
      final colorScheme = Theme.of(context).colorScheme;
      _generators = [
        GeneratorItem(
          id: 'password',
          title: 'Password',
          subtitle: 'Secure passwords',
          icon: Icons.lock_outline,
          containerColor: colorScheme.primaryContainer,
          pageBuilder: () => const PasswordGeneratorPage(),
        ),
        GeneratorItem(
          id: 'email',
          title: 'Email',
          subtitle: 'Random emails',
          icon: Icons.email_outlined,
          containerColor: colorScheme.secondaryContainer,
          pageBuilder: () => const EmailGeneratorPage(),
        ),
        GeneratorItem(
          id: 'username',
          title: 'Username',
          subtitle: 'Random usernames',
          icon: Icons.person_outline,
          containerColor: colorScheme.tertiaryContainer,
          pageBuilder: () => const UsernameGeneratorPage(),
        ),
        GeneratorItem(
          id: 'device',
          title: 'Device Name',
          subtitle: 'Random device',
          icon: Icons.phone_android_outlined,
          containerColor: colorScheme.errorContainer,
          pageBuilder: () => const DeviceGeneratorPage(),
        ),
        GeneratorItem(
          id: 'identity',
          title: 'Identity',
          subtitle: 'Fake identities',
          icon: Icons.badge_outlined,
          containerColor: colorScheme.surfaceContainerHighest,
          pageBuilder: () => const RandomIdentityGeneratorPage(),
        ),
        GeneratorItem(
          id: 'phone',
          title: 'Number',
          subtitle: 'Fake numbers',
          icon: Icons.phone_outlined,
          containerColor: colorScheme.primaryContainer,
          pageBuilder: () => const PhoneGeneratorPage(),
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
      for (var generator in _generators) {
        generator.isPinned = pinnedIds.contains(generator.id);
      }
    });
  }

  // Save pinned state to SharedPreferences
  Future<void> _savePinnedState() async {
    final prefs = await SharedPreferences.getInstance();
    final pinnedIds = _generators
        .where((g) => g.isPinned)
        .map((g) => g.id)
        .toList();
    await prefs.setStringList(_pinnedKey, pinnedIds);
  }

  List<GeneratorItem> get _pinnedGenerators =>
      _generators.where((g) => g.isPinned).toList();

  List<GeneratorItem> get _unpinnedGenerators =>
      _generators.where((g) => !g.isPinned).toList();

  void _togglePin(GeneratorItem item) {
    setState(() {
      item.isPinned = !item.isPinned;
    });
    _savePinnedState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final pinnedItems = _pinnedGenerators;
    final unpinnedItems = _unpinnedGenerators;

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
                  return _GeneratorListCard(
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
                    'All Generators',
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
                  return _GeneratorListCard(
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

class _GeneratorListCard extends StatelessWidget {
  final GeneratorItem item;
  final VoidCallback onTap;
  final VoidCallback onTogglePin;

  const _GeneratorListCard({
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
