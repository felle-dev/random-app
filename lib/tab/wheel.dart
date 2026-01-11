import 'dart:math';
import 'package:flutter/material.dart';

class WheelTab extends StatefulWidget {
  const WheelTab({super.key});

  @override
  State<WheelTab> createState() => _WheelTabState();
}

class _WheelTabState extends State<WheelTab>
    with SingleTickerProviderStateMixin {
  List<String> items = ['Option 1', 'Option 2', 'Option 3', 'Option 4'];
  String? selectedItem;
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isSpinning = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _spinWheel() {
    if (_isSpinning) return;
    setState(() {
      _isSpinning = true;
      selectedItem = null;
    });

    _controller.forward(from: 0).then((_) {
      final random = Random();
      setState(() {
        selectedItem = items[random.nextInt(items.length)];
        _isSpinning = false;
      });
    });
  }

  void _showAddItemDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Item'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter item name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() => items.add(controller.text));
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _animation.value * 8 * pi,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              theme.colorScheme.primary,
                              theme.colorScheme.secondary,
                              theme.colorScheme.tertiary,
                            ],
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.album,
                            size: 80,
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
                if (selectedItem != null) ...[
                  Text(
                    'Result:',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    selectedItem!,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                FilledButton.icon(
                  onPressed: _isSpinning ? null : _spinWheel,
                  icon: const Icon(Icons.play_arrow),
                  label: Text(_isSpinning ? 'Spinning...' : 'Spin the Wheel'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Wheel Items',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton.filled(
              onPressed: _showAddItemDialog,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(child: Text('${index + 1}')),
              title: Text(item),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () {
                  setState(() => items.removeAt(index));
                },
              ),
            ),
          );
        }),
        const SizedBox(height: 100),
      ],
    );
  }
}
