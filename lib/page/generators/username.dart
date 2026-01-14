import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

class UsernameGeneratorPage extends StatefulWidget {
  const UsernameGeneratorPage({super.key});

  @override
  State<UsernameGeneratorPage> createState() => _UsernameGeneratorPageState();
}

class _UsernameGeneratorPageState extends State<UsernameGeneratorPage> {
  String _generatedUsername = '';
  bool _includeNumbers = true;
  bool _includeAdjective = true;
  bool _capitalize = true;
  String _separator = '';
  final List<String> _history = [];

  final List<String> _adjectives = [
    'Cool',
    'Epic',
    'Swift',
    'Brave',
    'Noble',
    'Wise',
    'Clever',
    'Mighty',
    'Silent',
    'Golden',
    'Shadow',
    'Mystic',
    'Thunder',
    'Crimson',
    'Azure',
    'Cosmic',
    'Stellar',
    'Lunar',
    'Solar',
    'Wild',
    'Free',
    'Bold',
    'Dark',
    'Bright',
    'Quick',
    'Super',
    'Ultra',
    'Mega',
    'Alpha',
    'Prime',
  ];

  final List<String> _nouns = [
    'Wolf',
    'Eagle',
    'Dragon',
    'Phoenix',
    'Tiger',
    'Lion',
    'Falcon',
    'Hawk',
    'Bear',
    'Panther',
    'Knight',
    'Warrior',
    'Hunter',
    'Ranger',
    'Mage',
    'Ninja',
    'Samurai',
    'Viking',
    'Titan',
    'Legend',
    'Hero',
    'Champion',
    'Master',
    'Wizard',
    'Storm',
    'Thunder',
    'Blaze',
    'Frost',
    'Shadow',
    'Star',
  ];

  final List<String> _separators = ['', '_', '-', '.'];

  @override
  void initState() {
    super.initState();
    _generateUsername();
  }

  void _generateUsername() {
    final random = Random();
    String username = '';

    if (_includeAdjective) {
      String adjective = _adjectives[random.nextInt(_adjectives.length)];
      if (!_capitalize) adjective = adjective.toLowerCase();
      username += adjective;
    }

    if (_includeAdjective && username.isNotEmpty) {
      username += _separator;
    }

    String noun = _nouns[random.nextInt(_nouns.length)];
    if (!_capitalize) noun = noun.toLowerCase();
    username += noun;

    if (_includeNumbers) {
      username += _separator;
      username += (random.nextInt(9000) + 1000).toString();
    }

    setState(() {
      _generatedUsername = username;
      if (_history.length >= 10) {
        _history.removeAt(0);
      }
      _history.add(username);
    });
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied "$text" to clipboard'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Username Generator')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Generated Username Section
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
                        Icons.person_outline,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Generated Username',
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
                        _generatedUsername,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FilledButton.icon(
                            onPressed: () =>
                                _copyToClipboard(_generatedUsername),
                            icon: const Icon(Icons.copy),
                            label: const Text('Copy'),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          FilledButton.tonalIcon(
                            onPressed: _generateUsername,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Generate'),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Options Section
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
              crossAxisAlignment: CrossAxisAlignment.start,
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
                        'Options',
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
                  title: const Text('Include Adjective'),
                  subtitle: const Text('Add descriptive word'),
                  value: _includeAdjective,
                  onChanged: (value) {
                    setState(() {
                      _includeAdjective = value;
                    });
                    _generateUsername();
                  },
                ),
                Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: theme.colorScheme.outlineVariant,
                ),
                SwitchListTile(
                  title: const Text('Include Numbers'),
                  subtitle: const Text('Add random numbers'),
                  value: _includeNumbers,
                  onChanged: (value) {
                    setState(() {
                      _includeNumbers = value;
                    });
                    _generateUsername();
                  },
                ),
                Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: theme.colorScheme.outlineVariant,
                ),
                SwitchListTile(
                  title: const Text('Capitalize'),
                  subtitle: const Text('Use capital letters'),
                  value: _capitalize,
                  onChanged: (value) {
                    setState(() {
                      _capitalize = value;
                    });
                    _generateUsername();
                  },
                ),
                Divider(height: 1, color: theme.colorScheme.outlineVariant),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Separator', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children: _separators.map((sep) {
                          return ChoiceChip(
                            label: Text(sep.isEmpty ? 'None' : sep),
                            selected: _separator == sep,
                            onSelected: (selected) {
                              setState(() {
                                _separator = sep;
                              });
                              _generateUsername();
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
          const SizedBox(height: 16),

          // History Section
          if (_history.isNotEmpty)
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
                          Icons.history,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Recent History',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _history.clear();
                            });
                          },
                          child: const Text('Clear'),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: theme.colorScheme.outlineVariant),
                  ..._history.reversed.map((username) {
                    final isLast = username == _history.reversed.last;
                    return Column(
                      children: [
                        Material(
                          color: Colors.transparent,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  theme.colorScheme.primaryContainer,
                              child: Icon(
                                Icons.person,
                                size: 20,
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                            title: Text(
                              username,
                              style: const TextStyle(fontFamily: 'monospace'),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.copy),
                              onPressed: () => _copyToClipboard(username),
                            ),
                          ),
                        ),
                        if (!isLast)
                          Divider(
                            height: 1,
                            indent: 72,
                            color: theme.colorScheme.outlineVariant,
                          ),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}
