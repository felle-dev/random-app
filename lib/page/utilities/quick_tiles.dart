import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class QuickTilesPage extends StatefulWidget {
  const QuickTilesPage({super.key});

  @override
  State<QuickTilesPage> createState() => _QuickTilesPageState();
}

class _QuickTilesPageState extends State<QuickTilesPage> {
  static const platform = MethodChannel('com.random.app/quick_tiles');

  final List<QuickTile> availableTiles = [
    QuickTile(
      id: 'lock_screen',
      title: 'Lock Screen',
      subtitle: 'Instantly lock your device',
      icon: Icons.lock_outlined,
      color: Colors.red,
    ),
    QuickTile(
      id: 'volume_control',
      title: 'Volume Control',
      subtitle: 'Quick access to volume settings',
      icon: Icons.volume_up_outlined,
      color: Colors.deepPurple,
    ),
    QuickTile(
      id: 'screenshot',
      title: 'Screenshot',
      subtitle: 'Take a screenshot instantly',
      icon: Icons.screenshot_outlined,
      color: Colors.blue,
    ),
    QuickTile(
      id: 'caffeine',
      title: 'Caffeine',
      subtitle: 'Keep screen awake',
      icon: Icons.coffee_outlined,
      color: Colors.orange,
    ),
  ];

  Set<String> activeTiles = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadActiveTiles();
  }

  Future<void> _loadActiveTiles() async {
    try {
      final result = await platform.invokeMethod('getActiveTiles');
      setState(() {
        activeTiles = Set<String>.from(result ?? []);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint('Failed to load active tiles: $e');
    }
  }

  Future<void> _toggleTile(String tileId, bool isActive) async {
    try {
      // Check accessibility for both screenshot and lock screen tiles
      if ((tileId == 'screenshot' || tileId == 'lock_screen') && isActive) {
        final bool accessibilityEnabled = await _checkAccessibility();

        if (!accessibilityEnabled) {
          if (mounted) {
            _showAccessibilityDialog(tileId);
          }
          return;
        }
      }

      if (isActive) {
        await platform.invokeMethod('addTile', {'tileId': tileId});
        setState(() {
          activeTiles.add(tileId);
        });
        if (mounted) {
          String message = 'Tile added! Pull down quick settings to see it.';
          if (tileId == 'screenshot' || tileId == 'lock_screen') {
            message =
                '${tileId == 'screenshot' ? 'Screenshot' : 'Lock screen'} tile added! Make sure accessibility is enabled.';
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              action: SnackBarAction(label: 'OK', onPressed: () {}),
            ),
          );
        }
      } else {
        await platform.invokeMethod('removeTile', {'tileId': tileId});
        setState(() {
          activeTiles.remove(tileId);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tile removed from quick settings')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update tile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      debugPrint('Failed to toggle tile: $e');
    }
  }

  Future<bool> _checkAccessibility() async {
    try {
      final result = await platform.invokeMethod('checkAccessibility');
      return result as bool? ?? false;
    } catch (e) {
      debugPrint('Failed to check accessibility: $e');
      return false;
    }
  }

  void _showAccessibilityDialog(String tileId) {
    final String featureName = tileId == 'screenshot'
        ? 'Screenshot'
        : 'Lock screen';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.accessibility_new),
            SizedBox(width: 8),
            Text('Enable Accessibility'),
          ],
        ),
        content: Text(
          '$featureName functionality requires accessibility permission. '
          'Would you like to enable it now?\n\n'
          'In Settings, find "Random" under Accessibility and turn it on.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _openAccessibilitySettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _openAccessibilitySettings() async {
    try {
      await platform.invokeMethod('openAccessibilitySettings');
    } catch (e) {
      debugPrint('Failed to open accessibility settings: $e');
    }
  }

  void _showTileInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info_outline),
            SizedBox(width: 8),
            Text('About Quick Tiles'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Quick Settings Tiles provide instant access to app features from your notification shade.',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 16),
              Text(
                'How to use:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('1. Enable tiles you want to use'),
              Text('2. Swipe down from the top of your screen'),
              Text('3. Tap the pencil/edit icon'),
              Text('4. Drag the tiles to your quick settings'),
              SizedBox(height: 16),
              Text(
                'Permissions Required:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Lock Screen: Accessibility Service'),
              Text('• Screenshot: Accessibility Service (Android 9.0+)'),
              SizedBox(height: 16),
              Text(
                'Troubleshooting:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'If you cannot enable accessibility service:',
                style: TextStyle(fontSize: 13),
              ),
              SizedBox(height: 4),
              Text(
                '1. Go to App Info (long-press app icon → App info)',
                style: TextStyle(fontSize: 12),
              ),
              Text(
                '2. Tap the 3-dot menu (top right corner)',
                style: TextStyle(fontSize: 12),
              ),
              Text(
                '3. Select "Allow restricted settings"',
                style: TextStyle(fontSize: 12),
              ),
              Text(
                '4. Now try enabling accessibility again',
                style: TextStyle(fontSize: 12),
              ),
              SizedBox(height: 16),
              Text(
                'Note: Quick Settings Tiles require Android 7.0+. The "Allow restricted settings" option may not be available on all Android versions.',
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick Setting Tiles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showTileInfo,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Active Tiles Count
                Text(
                  'Active Tiles: ${activeTiles.length}/${availableTiles.length}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Available Tiles List
                Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    color: theme.colorScheme.surface,
                  ),
                  child: Column(
                    children: [
                      for (int i = 0; i < availableTiles.length; i++) ...[
                        _QuickTileItem(
                          tile: availableTiles[i],
                          isActive: activeTiles.contains(availableTiles[i].id),
                          onToggle: (value) {
                            _toggleTile(availableTiles[i].id, value);
                          },
                        ),
                        if (i < availableTiles.length - 1)
                          Divider(
                            height: 1,
                            indent: 72,
                            color: theme.colorScheme.outlineVariant,
                          ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
    );
  }
}

class _QuickTileItem extends StatelessWidget {
  final QuickTile tile;
  final bool isActive;
  final Function(bool) onToggle;

  const _QuickTileItem({
    required this.tile,
    required this.isActive,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: tile.color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(tile.icon, color: tile.color),
      ),
      title: Text(tile.title),
      subtitle: Text(tile.subtitle),
      trailing: Switch(value: isActive, onChanged: onToggle),
    );
  }
}

class QuickTile {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  QuickTile({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}
