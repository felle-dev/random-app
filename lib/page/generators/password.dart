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
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  if (_password.isNotEmpty) ...[
                    SelectableText(
                      _password,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: _password));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Password copied!')),
                        );
                      },
                      icon: const Icon(Icons.copy),
                      label: const Text('Copy'),
                    ),
                    const SizedBox(height: 24),
                  ],
                  Text('Length: $_length', style: theme.textTheme.titleMedium),
                  Slider(
                    value: _length.toDouble(),
                    min: 8,
                    max: 32,
                    divisions: 24,
                    onChanged: (value) =>
                        setState(() => _length = value.toInt()),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Uppercase (A-Z)'),
                    value: _includeUppercase,
                    onChanged: (value) =>
                        setState(() => _includeUppercase = value),
                  ),
                  SwitchListTile(
                    title: const Text('Lowercase (a-z)'),
                    value: _includeLowercase,
                    onChanged: (value) =>
                        setState(() => _includeLowercase = value),
                  ),
                  SwitchListTile(
                    title: const Text('Numbers (0-9)'),
                    value: _includeNumbers,
                    onChanged: (value) =>
                        setState(() => _includeNumbers = value),
                  ),
                  SwitchListTile(
                    title: const Text('Symbols (!@#\$...)'),
                    value: _includeSymbols,
                    onChanged: (value) =>
                        setState(() => _includeSymbols = value),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _generatePassword,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Generate Password'),
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