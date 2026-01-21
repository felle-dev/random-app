import 'package:flutter/material.dart';
import 'package:random/page/generators/device.dart';
import 'package:random/page/generators/password.dart';
import 'package:random/page/generators/random_number.dart';
import 'package:random/page/generators/dice_roller.dart';
import 'package:random/page/generators/coin_flip.dart';
import 'package:random/page/generators/spinning_wheel.dart';
import 'package:random/page/generators/username.dart';
import 'package:random/page/generators/quick_tiles.dart';
import 'package:random/page/generators/pomodoro_timer.dart';

class GeneratorsTab extends StatelessWidget {
  const GeneratorsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.only(left: 20, right: 20),
      children: [
        // Generators Section
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
                      Icons.auto_awesome_outlined,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Generators',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: theme.colorScheme.outlineVariant),
              _GeneratorListTile(
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
              Divider(
                height: 1,
                indent: 72,
                color: theme.colorScheme.outlineVariant,
              ),
              _GeneratorListTile(
                title: 'Username Generator',
                subtitle: 'Generate random usernames',
                icon: Icons.person_outline,
                color: Colors.teal,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UsernameGeneratorPage(),
                    ),
                  );
                },
              ),
              _GeneratorListTile(
                title: 'Device Name Generator',
                subtitle: 'Generate Random Device Names',
                icon: Icons.phone_android_outlined,
                color: Colors.teal,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DeviceGeneratorPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Random Tools Section
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
                      Icons.casino_outlined,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Random Tools',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: theme.colorScheme.outlineVariant),
              _GeneratorListTile(
                title: 'Random Number',
                subtitle: 'Generate random numbers',
                icon: Icons.numbers,
                color: Colors.blue,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RandomNumberPage(),
                    ),
                  );
                },
              ),
              Divider(
                height: 1,
                indent: 72,
                color: theme.colorScheme.outlineVariant,
              ),
              _GeneratorListTile(
                title: 'Dice Roller',
                subtitle: 'Roll virtual dice',
                icon: Icons.casino_outlined,
                color: Colors.orange,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DiceRollerPage(),
                    ),
                  );
                },
              ),
              Divider(
                height: 1,
                indent: 72,
                color: theme.colorScheme.outlineVariant,
              ),
              _GeneratorListTile(
                title: 'Coin Flip',
                subtitle: 'Flip a virtual coin',
                icon: Icons.monetization_on_outlined,
                color: Colors.amber,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CoinFlipPage(),
                    ),
                  );
                },
              ),
              Divider(
                height: 1,
                indent: 72,
                color: theme.colorScheme.outlineVariant,
              ),
              _GeneratorListTile(
                title: 'Spinning Wheel',
                subtitle: 'Spin the wheel to decide',
                icon: Icons.album_outlined,
                color: Colors.pink,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SpinningWheelPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Utilities Section
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
                      Icons.build_outlined,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Utilities',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: theme.colorScheme.outlineVariant),
              Divider(
                height: 1,
                indent: 72,
                color: theme.colorScheme.outlineVariant,
              ),
              _GeneratorListTile(
                title: 'Quick Tiles',
                subtitle: 'Manage quick setting tiles',
                icon: Icons.dashboard_customize_outlined,
                color: Colors.indigo,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const QuickTilesPage(),
                    ),
                  );
                },
              ),
              Divider(
                height: 1,
                indent: 72,
                color: theme.colorScheme.outlineVariant,
              ),
              _GeneratorListTile(
                title: 'Pomodoro Timer',
                subtitle: 'Focus and productivity timer',
                icon: Icons.timer_outlined,
                color: Colors.red,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PomodoroTimerPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 100),
      ],
    );
  }
}

class _GeneratorListTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _GeneratorListTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color),
          ),
          title: Text(title),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.chevron_right),
        ),
      ),
    );
  }
}
