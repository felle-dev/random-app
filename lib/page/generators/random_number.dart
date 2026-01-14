import 'dart:math';
import 'package:flutter/material.dart';

class RandomNumberPage extends StatefulWidget {
  const RandomNumberPage({super.key});

  @override
  State<RandomNumberPage> createState() => _RandomNumberPageState();
}

class _RandomNumberPageState extends State<RandomNumberPage> {
  int _min = 1;
  int _max = 100;
  int? _result;
  final _minController = TextEditingController(text: '1');
  final _maxController = TextEditingController(text: '100');

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  void _generate() {
    if (_min >= _max) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Minimum must be less than maximum'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final random = Random();
    setState(() {
      _result = _min + random.nextInt(_max - _min + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Random Number')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Result Section
          if (_result != null) ...[
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
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.tag_outlined,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Generated Number',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: theme.colorScheme.outlineVariant),
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      '$_result',
                      style: theme.textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Settings Section
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
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.tune_outlined,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Range Settings',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: theme.colorScheme.outlineVariant),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      TextField(
                        controller: _minController,
                        decoration: const InputDecoration(
                          labelText: 'Minimum',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.remove_circle_outline),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {
                            _min = int.tryParse(value) ?? 1;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _maxController,
                        decoration: const InputDecoration(
                          labelText: 'Maximum',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.add_circle_outline),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {
                            _max = int.tryParse(value) ?? 100;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Generate Button
          FilledButton.icon(
            onPressed: _generate,
            icon: const Icon(Icons.casino),
            label: const Text('Generate Random Number'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}
