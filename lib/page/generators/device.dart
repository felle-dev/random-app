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
  String _selectedBrand = 'Random';
  final List<String> _history = [];

  // Realistic device naming patterns by brand
  final Map<String, List<String>> _devicePatterns = {
    'Samsung': [
      'Galaxy S24',
      'Galaxy S24+',
      'Galaxy S24 Ultra',
      'Galaxy S23 FE',
      'Galaxy A54 5G',
      'Galaxy A34 5G',
      'Galaxy A15',
      'Galaxy M54',
      'Galaxy F54',
      'Galaxy Z Fold5',
      'Galaxy Z Flip5',
      'Galaxy Tab S9',
      'Galaxy Watch6',
    ],
    'Apple': [
      'iPhone 15 Pro Max',
      'iPhone 15 Pro',
      'iPhone 15 Plus',
      'iPhone 15',
      'iPhone 14 Pro',
      'iPhone 14',
      'iPhone SE',
      'iPad Pro 12.9',
      'iPad Air',
      'iPad mini',
      'Apple Watch Series 9',
      'Apple Watch Ultra 2',
    ],
    'Xiaomi': [
      'Xiaomi 14 Pro',
      'Xiaomi 14',
      'Xiaomi 13T Pro',
      'Redmi Note 13 Pro+',
      'Redmi Note 13 Pro',
      'Redmi Note 13',
      'Redmi 13C',
      'POCO X6 Pro',
      'POCO F6',
      'POCO M6 Pro',
      'Mi Pad 6',
    ],
    'Google': [
      'Pixel 8 Pro',
      'Pixel 8',
      'Pixel 8a',
      'Pixel 7a',
      'Pixel Fold',
      'Pixel Tablet',
      'Pixel Watch 2',
      'Pixel Buds Pro',
    ],
    'OnePlus': [
      'OnePlus 12',
      'OnePlus 12R',
      'OnePlus 11',
      'OnePlus Nord 3',
      'OnePlus Nord CE 3',
      'OnePlus Pad',
      'OnePlus Watch 2',
    ],
    'Oppo': [
      'Oppo Find X7 Pro',
      'Oppo Find X6 Pro',
      'Oppo Reno 11 Pro',
      'Oppo Reno 11',
      'Oppo A79 5G',
      'Oppo A58',
      'Oppo Pad Air',
    ],
    'Vivo': [
      'Vivo X100 Pro',
      'Vivo X90 Pro',
      'Vivo V29 Pro',
      'Vivo V29',
      'Vivo Y100',
      'Vivo Y56',
      'iQOO 12',
      'iQOO Neo 9 Pro',
      'iQOO Z9',
    ],
    'Realme': [
      'Realme GT 5 Pro',
      'Realme GT 5',
      'Realme 12 Pro+',
      'Realme 12 Pro',
      'Realme 12',
      'Realme C67',
      'Realme Narzo 70 Pro',
    ],
    'Motorola': [
      'Motorola Edge 50 Pro',
      'Motorola Edge 40 Neo',
      'Moto G84',
      'Moto G54',
      'Moto G34',
      'Motorola Razr 40 Ultra',
      'Motorola ThinkPhone',
    ],
    'Nothing': [
      'Nothing Phone (2)',
      'Nothing Phone (2a)',
      'Nothing Phone (1)',
      'Nothing Ear (2)',
      'CMF Phone 1',
      'CMF Watch Pro',
      'CMF Buds Pro',
    ],
  };

  @override
  void initState() {
    super.initState();
    _generateDeviceName();
  }

  void _generateDeviceName() {
    final random = Random();
    String deviceName = '';

    if (_selectedBrand == 'Random') {
      // Pick a random brand
      final brands = _devicePatterns.keys.toList();
      final randomBrand = brands[random.nextInt(brands.length)];
      final devices = _devicePatterns[randomBrand]!;
      deviceName = devices[random.nextInt(devices.length)];
    } else {
      // Use selected brand
      final devices = _devicePatterns[_selectedBrand]!;
      deviceName = devices[random.nextInt(devices.length)];
    }

    setState(() {
      _generatedDeviceName = deviceName;
      if (_history.length >= 10) {
        _history.removeAt(0);
      }
      _history.add(deviceName);
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
    final brands = ['Random', ..._devicePatterns.keys.toList()];

    return Scaffold(
      appBar: AppBar(title: const Text('Device Name Generator')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Generated Device Name Section
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
                        Icons.smartphone_outlined,
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

          // Brand Selection Section
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
                        'Select Brand',
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
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: brands.map((brand) {
                      return ChoiceChip(
                        label: Text(brand),
                        selected: _selectedBrand == brand,
                        onSelected: (selected) {
                          setState(() {
                            _selectedBrand = brand;
                          });
                          _generateDeviceName();
                        },
                      );
                    }).toList(),
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
                  ..._history.reversed.map((deviceName) {
                    final isLast = deviceName == _history.reversed.last;
                    return Column(
                      children: [
                        Material(
                          color: Colors.transparent,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  theme.colorScheme.primaryContainer,
                              child: Icon(
                                Icons.phone_android,
                                size: 20,
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                            title: Text(deviceName),
                            trailing: IconButton(
                              icon: const Icon(Icons.copy),
                              onPressed: () => _copyToClipboard(deviceName),
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
