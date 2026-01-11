import 'dart:math';

import 'package:flutter/material.dart';

class CoinFlipPage extends StatefulWidget {
  const CoinFlipPage({super.key});

  @override
  State<CoinFlipPage> createState() => _CoinFlipPageState();
}

class _CoinFlipPageState extends State<CoinFlipPage>
    with SingleTickerProviderStateMixin {
  String? _result;
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFlipping = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flipCoin() {
    if (_isFlipping) return;
    setState(() {
      _isFlipping = true;
      _result = null;
    });

    _controller.forward(from: 0).then((_) {
      final random = Random();
      setState(() {
        _result = random.nextBool() ? 'Heads' : 'Tails';
        _isFlipping = false;
      });
      _controller.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Coin Flip')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateY(_animation.value * pi * 4),
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                theme.colorScheme.primary,
                                theme.colorScheme.secondary,
                              ],
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.monetization_on,
                              size: 80,
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                  if (_result != null) ...[
                    Text(
                      _result!,
                      style: theme.textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                  FilledButton.icon(
                    onPressed: _isFlipping ? null : _flipCoin,
                    icon: const Icon(Icons.sync),
                    label: Text(_isFlipping ? 'Flipping...' : 'Flip Coin'),
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
        ),
      ),
    );
  }
}