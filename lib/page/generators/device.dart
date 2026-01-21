import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

class DeviceGeneratorPage extends StatefulWidget {
  const DeviceGeneratorPage({super.key});

  @override
  State<DeviceGeneratorPage> createState() => _DeviceGeneratorPageState();
}

class _DeviceGeneratorPageState extends State<DeviceGeneratorPage> {
  String _generatedDeviceName = '';
  bool _includeNumbers = true;
  bool _includeAdjective = true;
  bool _capitalize = true;
  String _separator = '';
  final List<String> _history = [];

  final List<String> _adjectives = [
    'Xiaomi',
    'Redmi',
    'POCO',
    'Mi',
    'Samsung',
    'Galaxy',
    'Oppo',
    'Reno',
    'Find',
    'Vivo',
    'iQOO',
    'OnePlus',
    'Nord',
    'Realme',
    'Narzo',
    'Apple',
    'iPhone',
    'Google',
    'Pixel',
    'Huawei',
    'Honor',
    'Nokia',
    'Motorola',
    'Moto',
    'Sony',
    'Xperia',
    'Asus',
    'ROG',
    'Zenfone',
    'Lenovo',
    'Legion',
    'LG',
    'HTC',
    'Meizu',
    'ZTE',
    'Nubia',
    'Tecno',
    'Infinix',
    'Itel',
    'Nothing',
    'CMF',
    'BlackBerry',
    'Sharp',
    'Panasonic',
    'Alcatel',
    'TCL',
    'Coolpad',
    'Gionee',
    'Micromax',
    'Lava',
    'Karbonn',
    'Intex',
    'Xolo',
    'Yu',
    'InFocus',
    'Wiko',
    'BLU',
    'Cat',
    'Doogee',
    'Ulefone',
    'Oukitel',
    'Blackview',
    'Umidigi',
    'Cubot',
    'Elephone',
    'Leagoo',
    'Homtom',
    'Vernee',
    'AGM',
    'Ruggear',
    'Sonim',
    'Kyocera',
    'Casio',
    'Fujitsu',
    'NEC',
    'Fairphone',
    'Essential',
    'Razer',
    'Red',
    'Magic',
    'Black',
    'Shark',
    'Legion',
    'HP',
    'Dell',
    'Acer',
    'Toshiba',
    'Fujitsu',
    'Pantech',
    'Fly',
    'Prestigio',
    'Explay',
    'Highscreen',
    'Vertex',
    'BQ',
    'Dexp',
    'Digma',
    'Supra',
    'Texet',
    'Jinga',
  ];

  final List<String> _nouns = [
    'Note',
    'Pro',
    'Max',
    'Plus',
    'Ultra',
    'Lite',
    'Mini',
    'Prime',
    'Edge',
    'Fold',
    'Flip',
    'A',
    'S',
    'M',
    'F',
    'C',
    'X',
    'Y',
    'Z',
    'G',
    'K',
    'V',
    'T',
    'P',
    'R',
    'One',
    'Two',
    'Three',
    'Four',
    'Five',
    'Six',
    'Seven',
    'Eight',
    'Nine',
    'Ten',
    'Eleven',
    'Twelve',
    'SE',
    'XR',
    'XS',
    'Ace',
    'Neo',
    'GT',
    'Turbo',
    'Power',
    'Style',
    'Play',
    'Go',
    'View',
    'Spark',
    'Pop',
    'Camon',
    'Hot',
    'Smart',
    'Note',
    'Pad',
    'Tab',
    'Book',
    'Buds',
    'Watch',
    'Band',
    'Fit',
    'Active',
    'Classic',
    'Standard',
    'Premium',
    'Basic',
    'Essential',
    'Fusion',
    'Vision',
    'Horizon',
    'Zenith',
    'Nova',
    'Star',
    'Moon',
    'Sun',
    'Sky',
    'Cloud',
    'Storm',
    'Breeze',
    'Wave',
    'Flow',
    'Pulse',
    'Beat',
    'Rhythm',
    'Tempo',
    'Vibe',
    'Mood',
    'Soul',
    'Spirit',
    'Spark',
    'Flame',
    'Blaze',
    'Flash',
    'Bolt',
    'Strike',
    'Dash',
    'Rush',
    'Swift',
    'Speed',
    'Pace',
    'Drive',
    'Force',
    'Impact',
    'Boost',
    'Charge',
    'Energy',
    'Life',
    'Core',
    'Zen',
    'Pure',
    'Clear',
    'Bright',
    'Light',
    'Shine',
    'Glow',
    'Beam',
    'Ray',
    'Aura',
    'Halo',
    'Crown',
    'King',
    'Queen',
    'Knight',
    'Master',
    'Pro',
    'Expert',
    'Elite',
    'Champion',
    'Hero',
    'Legend',
    'Icon',
    'Symbol',
    'Mark',
    'Sign',
    'Badge',
    'Tag',
    'Label',
    'Brand',
    'Line',
    'Series',
    'Gen',
    'Edition',
    'Version',
    'Model',
    'Type',
    'Class',
    'Grade',
    'Level',
    'Tier',
    'Rank',
    'Zone',
    'Realm',
    'World',
    'Universe',
    'Galaxy',
    'Cosmos',
    'Space',
    'Time',
    'Era',
    'Age',
    'Dawn',
    'Rise',
    'Peak',
    'Summit',
    'Apex',
    'Top',
    'Max',
    'Best',
    'First',
    'Prime',
    'Alpha',
    'Beta',
    'Gamma',
    'Delta',
    'Omega',
    'Zero',
    'Infinity',
    'Beyond',
    'Future',
    'Next',
    'New',
    'Fresh',
    'Modern',
    'Smart',
    'Digital',
    'Tech',
    'Link',
    'Connect',
    'Sync',
    'Share',
    'Cast',
    'Stream',
    'Live',
    'Now',
    'Here',
    'Go',
    'Move',
    'Step',
    'Jump',
    'Leap',
    'Fly',
    'Soar',
    'Rise',
    'Climb',
    'Reach',
    'Touch',
    'Feel',
    'Sense',
    'Find',
    'Seek',
    'Hunt',
    'Quest',
    'Journey',
    'Path',
    'Way',
    'Road',
    'Trail',
    'Track',
    'Route',
    'Course',
    'Run',
    'Race',
    'Game',
    'Win',
    'Victory',
    'Glory',
    'Fame',
    'Star',
    'Shine',
  ];

  final List<String> _separators = ['', '_', '-', '.'];

  @override
  void initState() {
    super.initState();
    _generateDeviceName();
  }

  void _generateDeviceName() {
    final random = Random();
    String DeviceName = '';

    if (_includeAdjective) {
      String adjective = _adjectives[random.nextInt(_adjectives.length)];
      if (!_capitalize) adjective = adjective.toLowerCase();
      DeviceName += adjective;
    }

    if (_includeAdjective && DeviceName.isNotEmpty) {
      DeviceName += _separator;
    }

    String noun = _nouns[random.nextInt(_nouns.length)];
    if (!_capitalize) noun = noun.toLowerCase();
    DeviceName += noun;

    if (_includeNumbers) {
      DeviceName += _separator;
      DeviceName += (random.nextInt(9000) + 1000).toString();
    }

    setState(() {
      _generatedDeviceName = DeviceName;
      if (_history.length >= 10) {
        _history.removeAt(0);
      }
      _history.add(DeviceName);
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
      appBar: AppBar(title: const Text('Device Name Generator')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Generated DeviceName Section
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
                        'Generated Device Name',
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
                        _generatedDeviceName,
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
                                _copyToClipboard(_generatedDeviceName),
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
                            onPressed: _generateDeviceName,
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
                    _generateDeviceName();
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
                    _generateDeviceName();
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
                    _generateDeviceName();
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
                              _generateDeviceName();
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
                  ..._history.reversed.map((DeviceName) {
                    final isLast = DeviceName == _history.reversed.last;
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
                              DeviceName,
                              style: const TextStyle(fontFamily: 'monospace'),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.copy),
                              onPressed: () => _copyToClipboard(DeviceName),
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
