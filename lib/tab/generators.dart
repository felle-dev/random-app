import 'package:flutter/material.dart';
import 'package:random/page/generators/password.dart';
import 'package:random/page/generators/random_number.dart';
import 'package:random/page/generators/dice_roller.dart';
import 'package:random/page/generators/coin_flip.dart';

class GeneratorsTab extends StatelessWidget {
  const GeneratorsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Quick Tools',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _GeneratorCard(
          title: 'Password Generator',
          subtitle: 'Create secure passwords',
          icon: Icons.lock_outline,
          color: Colors.purple,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PasswordGeneratorPage(),
              ),
            );
          },
        ),
        _GeneratorCard(
          title: 'Random Number',
          subtitle: 'Generate random numbers',
          icon: Icons.numbers,
          color: Colors.blue,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RandomNumberPage()),
            );
          },
        ),
        _GeneratorCard(
          title: 'Dice Roller',
          subtitle: 'Roll virtual dice',
          icon: Icons.casino_outlined,
          color: Colors.orange,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DiceRollerPage()),
            );
          },
        ),
        _GeneratorCard(
          title: 'Coin Flip',
          subtitle: 'Flip a virtual coin',
          icon: Icons.monetization_on_outlined,
          color: Colors.amber,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CoinFlipPage()),
            );
          },
        ),
        const SizedBox(height: 100),
      ],
    );
  }
}

class _GeneratorCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _GeneratorCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
