import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PasswordGeneratorPage extends StatefulWidget {
  const PasswordGeneratorPage({super.key});

  @override
  State<PasswordGeneratorPage> createState() => _PasswordGeneratorPageState();
}

class _PasswordGeneratorPageState extends State<PasswordGeneratorPage> {
  String _password = '';
  int _length = 16;
  bool _includeUppercase = true;
  bool _includeLowercase = true;
  bool _includeNumbers = true;
  bool _includeSymbols = true;

  void _generatePassword() {
    const uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const lowercase = 'abcdefghijklmnopqrstuvwxyz';
    const numbers = '0123456789';
    const symbols = '!@#\$%^&*()_+-=[]{}|;:,.<>?';

    String chars = '';
    if (_includeUppercase) chars += uppercase;
    if (_includeLowercase) chars += lowercase;
    if (_includeNumbers) chars += numbers;
    if (_includeSymbols) chars += symbols;

    if (chars.isEmpty) return;

    final random = Random.secure();
    setState(() {
      _password = List.generate(
        _length,
        (index) => chars[random.nextInt(chars.length)],
      ).join();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Password Generator')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Generated Password Section
          if (_password.isNotEmpty) ...[
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
                          Icons.key_outlined,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Generated Password',
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
                        SelectableText(
                          _password,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: _password));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Password copied!')),
                            );
                          },
                          icon: const Icon(Icons.copy),
                          label: const Text('Copy Password'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
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
                        'Password Settings',
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
                        'Length: $_length',
                        style: theme.textTheme.titleMedium,
                      ),
                      Slider(
                        value: _length.toDouble(),
                        min: 8,
                        max: 32,
                        divisions: 24,
                        onChanged: (value) =>
                            setState(() => _length = value.toInt()),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Character Types Section
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
                        Icons.category_outlined,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Character Types',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: theme.colorScheme.outlineVariant),
                SwitchListTile(
                  title: const Text('Uppercase (A-Z)'),
                  value: _includeUppercase,
                  onChanged: (value) =>
                      setState(() => _includeUppercase = value),
                ),
                Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: theme.colorScheme.outlineVariant,
                ),
                SwitchListTile(
                  title: const Text('Lowercase (a-z)'),
                  value: _includeLowercase,
                  onChanged: (value) =>
                      setState(() => _includeLowercase = value),
                ),
                Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: theme.colorScheme.outlineVariant,
                ),
                SwitchListTile(
                  title: const Text('Numbers (0-9)'),
                  value: _includeNumbers,
                  onChanged: (value) => setState(() => _includeNumbers = value),
                ),
                Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: theme.colorScheme.outlineVariant,
                ),
                SwitchListTile(
                  title: const Text('Symbols (!@#\$...)'),
                  value: _includeSymbols,
                  onChanged: (value) => setState(() => _includeSymbols = value),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Generate Button
          FilledButton.icon(
            onPressed: _generatePassword,
            icon: const Icon(Icons.refresh),
            label: const Text('Generate Password'),
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
