import 'package:flutter/material.dart';
import 'package:random/page/generators/random_number.dart';
import 'package:random/page/generators/dice_roller.dart';
import 'package:random/page/generators/coin_flip.dart';
import 'package:random/page/generators/spinning_wheel.dart';

class RandomToolsTab extends StatelessWidget {
  const RandomToolsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.0,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            delegate: SliverChildListDelegate([
              _RandomToolCard(
                title: 'Random Number',
                subtitle: 'Generate numbers',
                icon: Icons.numbers,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.primaryContainer,
                    colorScheme.primaryContainer.withOpacity(0.7),
                  ],
                ),
                iconColor: colorScheme.onPrimaryContainer,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RandomNumberPage(),
                    ),
                  );
                },
              ),
              _RandomToolCard(
                title: 'Dice Roller',
                subtitle: 'Roll virtual dice',
                icon: Icons.casino_outlined,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.secondaryContainer,
                    colorScheme.secondaryContainer.withOpacity(0.7),
                  ],
                ),
                iconColor: colorScheme.onSecondaryContainer,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DiceRollerPage(),
                    ),
                  );
                },
              ),
              _RandomToolCard(
                title: 'Coin Flip',
                subtitle: 'Flip a virtual coin',
                icon: Icons.monetization_on_outlined,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.tertiaryContainer,
                    colorScheme.tertiaryContainer.withOpacity(0.7),
                  ],
                ),
                iconColor: colorScheme.onTertiaryContainer,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CoinFlipPage(),
                    ),
                  );
                },
              ),
              _RandomToolCard(
                title: 'Spinning Wheel',
                subtitle: 'Spin to decide',
                icon: Icons.album_outlined,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.errorContainer,
                    colorScheme.errorContainer.withOpacity(0.7),
                  ],
                ),
                iconColor: colorScheme.onErrorContainer,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SpinningWheelPage(),
                    ),
                  );
                },
              ),
            ]),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}

class _RandomToolCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Gradient gradient;
  final Color iconColor;
  final VoidCallback onTap;

  const _RandomToolCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: colorScheme.outlineVariant.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(child: Icon(icon, size: 48, color: iconColor)),
                const Spacer(),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: iconColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: iconColor.withOpacity(0.8),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
