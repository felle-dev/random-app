import 'dart:math';
import 'package:flutter/material.dart';

class DiceRollerPage extends StatefulWidget {
  const DiceRollerPage({super.key});

  @override
  State<DiceRollerPage> createState() => _DiceRollerPageState();
}

class _DiceRollerPageState extends State<DiceRollerPage>
    with SingleTickerProviderStateMixin {
  int _numberOfDice = 1;
  int _sides = 6;
  List<int> _results = [];
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isRolling = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _rollDice() {
    if (_isRolling) return;
    setState(() {
      _isRolling = true;
      _results = [];
    });

    _controller.forward(from: 0).then((_) {
      final random = Random();
      setState(() {
        _results = List.generate(
          _numberOfDice,
          (index) => random.nextInt(_sides) + 1,
        );
        _isRolling = false;
      });
      _controller.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = _results.isEmpty ? 0 : _results.reduce((a, b) => a + b);

    return Scaffold(
      appBar: AppBar(title: const Text('Dice Roller')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Animation Section
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
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _animation.value * pi * 2,
                    child: Icon(
                      Icons.casino,
                      size: 80,
                      color: theme.colorScheme.primary,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Results Section
          if (_results.isNotEmpty) ...[
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
                          Icons.stars_outlined,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Results',
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
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          alignment: WrapAlignment.center,
                          children: _results.map((result) {
                            return Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  '$result',
                                  style: theme.textTheme.headlineMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: theme
                                            .colorScheme
                                            .onPrimaryContainer,
                                      ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        if (_results.length > 1) ...[
                          const SizedBox(height: 16),
                          Text(
                            'Total: $total',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ],
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
                        'Dice Settings',
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Number of Dice: $_numberOfDice',
                        style: theme.textTheme.titleMedium,
                      ),
                      Slider(
                        value: _numberOfDice.toDouble(),
                        min: 1,
                        max: 10,
                        divisions: 9,
                        onChanged: (value) =>
                            setState(() => _numberOfDice = value.toInt()),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Sides: $_sides',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children: [4, 6, 8, 10, 12, 20].map((sides) {
                          return ChoiceChip(
                            label: Text('D$sides'),
                            selected: _sides == sides,
                            onSelected: (selected) {
                              if (selected) setState(() => _sides = sides);
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Roll Button
          FilledButton.icon(
            onPressed: _isRolling ? null : _rollDice,
            icon: const Icon(Icons.casino),
            label: Text(_isRolling ? 'Rolling...' : 'Roll Dice'),
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
