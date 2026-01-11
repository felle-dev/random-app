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

  void _generate() {
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
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  if (_result != null) ...[
                    Text(
                      '$_result',
                      style: theme.textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Minimum',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => _min = int.tryParse(value) ?? 1,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Maximum',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => _max = int.tryParse(value) ?? 100,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _generate,
                    icon: const Icon(Icons.casino),
                    label: const Text('Generate'),
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
        ],
      ),
    );
  }
}