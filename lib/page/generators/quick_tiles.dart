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
      // Special handling for screenshot tile
      if (tileId == 'screenshot' && isActive) {
        // Check if accessibility is enabled
        final bool accessibilityEnabled = await _checkAccessibility();

        if (!accessibilityEnabled) {
          if (mounted) {
            _showAccessibilityDialog();
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                tileId == 'screenshot'
                    ? 'Screenshot tile added! Make sure accessibility is enabled.'
                    : 'Tile added! Pull down quick settings to see it.',
              ),
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

  void _showAccessibilityDialog() {
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
        content: const Text(
          'Screenshot functionality requires accessibility permission. '
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
                'Note: Screenshot tile requires Accessibility permission (Android 9.0+) and Quick Settings Tiles require Android 7.0+.',
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
                // Info Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.dashboard_customize_outlined,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Add shortcuts to your notification shade for quick access',
                          style: TextStyle(
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

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
                const SizedBox(height: 24),

                // Accessibility Notice (only show if screenshot tile exists)
                if (availableTiles.any((tile) => tile.id == 'screenshot'))
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200, width: 1),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.accessibility_new,
                          color: Colors.blue.shade700,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Screenshot tile requires Accessibility permission',
                            style: TextStyle(
                              color: Colors.blue.shade900,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),

                // Instructions Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: theme.colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Quick Setup',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildInstructionStep('1', 'Enable tiles above'),
                      _buildInstructionStep(
                        '2',
                        'Swipe down notification shade',
                      ),
                      _buildInstructionStep('3', 'Tap edit/pencil icon'),
                      _buildInstructionStep(
                        '4',
                        'Drag tiles to quick settings',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
    );
  }

  Widget _buildInstructionStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
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
