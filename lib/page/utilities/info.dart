import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:battery_plus/battery_plus.dart';

class DeviceInfoPage extends StatefulWidget {
  const DeviceInfoPage({super.key});

  @override
  State<DeviceInfoPage> createState() => _DeviceInfoPageState();
}

class _DeviceInfoPageState extends State<DeviceInfoPage> {
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  final Battery _battery = Battery();

  // Platform channel for battery cycles
  static const platform = MethodChannel('com.random.app/battery_info');

  Map<String, String> _deviceData = {};
  Map<String, String> _batteryData = {};
  bool _isLoading = true;
  int _chargingCycles = 0;

  @override
  void initState() {
    super.initState();
    _loadDeviceInfo();
    _loadBatteryInfo();
    _loadChargingCycles();
  }

  Future<void> _loadDeviceInfo() async {
    Map<String, String> deviceData = {};

    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await _deviceInfo.androidInfo;
        deviceData = {
          'Brand': androidInfo.brand,
          'Model': androidInfo.model,
          'Device': androidInfo.device,
          'Manufacturer': androidInfo.manufacturer,
          'Product': androidInfo.product,
          'Android Version': androidInfo.version.release,
          'SDK Version': androidInfo.version.sdkInt.toString(),
          'Security Patch': androidInfo.version.securityPatch ?? 'N/A',
          'Board': androidInfo.board,
          'Hardware': androidInfo.hardware,
          'Supported ABIs': androidInfo.supportedAbis.join(', '),
          'Is Physical Device': androidInfo.isPhysicalDevice.toString(),
        };
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await _deviceInfo.iosInfo;
        deviceData = {
          'Name': iosInfo.name,
          'Model': iosInfo.model,
          'System Name': iosInfo.systemName,
          'System Version': iosInfo.systemVersion,
          'Local Model': iosInfo.localizedModel,
          'Identifier': iosInfo.identifierForVendor ?? 'N/A',
          'Is Physical Device': iosInfo.isPhysicalDevice.toString(),
        };
      } else if (Platform.isWindows) {
        WindowsDeviceInfo windowsInfo = await _deviceInfo.windowsInfo;
        deviceData = {
          'Computer Name': windowsInfo.computerName,
          'Number of Cores': windowsInfo.numberOfCores.toString(),
          'System Memory (GB)': (windowsInfo.systemMemoryInMegabytes / 1024)
              .toStringAsFixed(2),
          'Product Name': windowsInfo.productName,
          'Display Version': windowsInfo.displayVersion,
          'Platform ID': windowsInfo.platformId.toString(),
          'Major Version': windowsInfo.majorVersion.toString(),
          'Minor Version': windowsInfo.minorVersion.toString(),
          'Build Number': windowsInfo.buildNumber.toString(),
        };
      } else if (Platform.isLinux) {
        LinuxDeviceInfo linuxInfo = await _deviceInfo.linuxInfo;
        deviceData = {
          'Name': linuxInfo.name,
          'Version': linuxInfo.version ?? 'N/A',
          'ID': linuxInfo.id,
          'ID Like': linuxInfo.idLike?.join(', ') ?? 'N/A',
          'Version Codename': linuxInfo.versionCodename ?? 'N/A',
          'Version ID': linuxInfo.versionId ?? 'N/A',
          'Pretty Name': linuxInfo.prettyName,
          'Build ID': linuxInfo.buildId ?? 'N/A',
          'Variant': linuxInfo.variant ?? 'N/A',
          'Variant ID': linuxInfo.variantId ?? 'N/A',
          'Machine ID': linuxInfo.machineId ?? 'N/A',
        };
      } else if (Platform.isMacOS) {
        MacOsDeviceInfo macInfo = await _deviceInfo.macOsInfo;
        deviceData = {
          'Computer Name': macInfo.computerName,
          'Host Name': macInfo.hostName,
          'Model': macInfo.model,
          'Kernel Version': macInfo.kernelVersion,
          'OS Release': macInfo.osRelease,
          'Major Version': macInfo.majorVersion.toString(),
          'Minor Version': macInfo.minorVersion.toString(),
          'Patch Version': macInfo.patchVersion.toString(),
          'System GUID': macInfo.systemGUID ?? 'N/A',
        };
      }
    } catch (e) {
      deviceData = {'Error': 'Failed to get device info: $e'};
    }

    setState(() {
      _deviceData = deviceData;
      _isLoading = false;
    });
  }

  Future<void> _loadBatteryInfo() async {
    Map<String, String> batteryData = {};

    try {
      final batteryLevel = await _battery.batteryLevel;
      final batteryState = await _battery.batteryState;

      String stateText = '';
      switch (batteryState) {
        case BatteryState.charging:
          stateText = 'Charging';
          break;
        case BatteryState.full:
          stateText = 'Full';
          break;
        case BatteryState.discharging:
          stateText = 'Discharging';
          break;
        case BatteryState.unknown:
          stateText = 'Unknown';
          break;
        default:
          stateText = 'Unknown';
      }

      batteryData = {
        'Battery Level': '$batteryLevel%',
        'Battery State': stateText,
        'Health Status': _getBatteryHealth(batteryLevel),
      };
    } catch (e) {
      batteryData = {'Error': 'Battery info not available on this platform'};
    }

    setState(() {
      _batteryData = batteryData;
    });
  }

  Future<void> _loadChargingCycles() async {
    try {
      if (Platform.isAndroid) {
        final result = await _readAndroidBatteryCycles();
        setState(() {
          _chargingCycles = result;
        });
      } else if (Platform.isMacOS) {
        final result = await _readMacOSBatteryCycles();
        setState(() {
          _chargingCycles = result;
        });
      } else {
        setState(() {
          _chargingCycles = -1;
        });
      }
    } catch (e) {
      setState(() {
        _chargingCycles = -1;
      });
    }
  }

  Future<int> _readAndroidBatteryCycles() async {
    try {
      final int cycles = await platform.invokeMethod('getBatteryCycles');
      return cycles;
    } on PlatformException catch (e) {
      print("Failed to get battery cycles: '${e.message}'.");
      return -1;
    }
  }

  Future<int> _readMacOSBatteryCycles() async {
    try {
      final result = await Process.run('system_profiler', ['SPPowerDataType']);
      final output = result.stdout.toString();

      final cycleMatch = RegExp(r'Cycle Count:\s*(\d+)').firstMatch(output);
      if (cycleMatch != null) {
        return int.parse(cycleMatch.group(1)!);
      }
    } catch (e) {
      // Command failed or not available
    }
    return -1;
  }

  String _getBatteryHealth(int level) {
    if (level >= 80) return 'Good';
    if (level >= 50) return 'Fair';
    if (level >= 20) return 'Low';
    return 'Critical';
  }

  Color _getBatteryColor(int level, ThemeData theme) {
    if (level >= 50) return theme.colorScheme.primary;
    if (level >= 20) return Colors.orange;
    return theme.colorScheme.error;
  }

  void _copyAllDeviceInfo() {
    final allData = _deviceData.entries
        .map((e) => '${e.key}: ${e.value}')
        .join('\n');
    Clipboard.setData(ClipboardData(text: allData));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Device info copied!')));
  }

  Widget _buildBatteryIndicator(int level, ThemeData theme) {
    return Container(
      width: 80,
      height: 120,
      decoration: BoxDecoration(
        border: Border.all(color: _getBatteryColor(level, theme), width: 3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Container(
            height: 8,
            width: 30,
            margin: const EdgeInsets.only(top: -3),
            decoration: BoxDecoration(
              color: _getBatteryColor(level, theme),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(4),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Column(
                children: [
                  const Spacer(),
                  Container(
                    height: (100 - 8) * (level / 100),
                    decoration: BoxDecoration(
                      color: _getBatteryColor(level, theme),
                      borderRadius: BorderRadius.circular(4),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Device Info')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final hasBatteryInfo = !_batteryData.containsKey('Error');
    final batteryLevel = hasBatteryInfo
        ? int.tryParse(
                _batteryData['Battery Level']?.replaceAll('%', '') ?? '0',
              ) ??
              0
        : 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Device Info')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (hasBatteryInfo) ...[
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
                          Icons.battery_charging_full,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Battery Health',
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
                    child: Row(
                      children: [
                        _buildBatteryIndicator(batteryLevel, theme),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ..._batteryData.entries.map((entry) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        entry.key,
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: theme
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        entry.value,
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Charging Cycles',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: theme
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _chargingCycles == -1
                                          ? 'N/A'
                                          : _chargingCycles.toString(),
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: theme.colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Battery information is not available on this platform.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

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
                        Platform.isWindows ||
                                Platform.isLinux ||
                                Platform.isMacOS
                            ? Icons.computer_outlined
                            : Icons.phone_android_outlined,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Device Information',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.copy_all, size: 20),
                        onPressed: _copyAllDeviceInfo,
                        tooltip: 'Copy All',
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: theme.colorScheme.outlineVariant),
                ..._deviceData.entries.map((entry) {
                  return Column(
                    children: [
                      ListTile(
                        title: Text(
                          entry.key,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            entry.value,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      if (entry.key != _deviceData.entries.last.key)
                        Divider(
                          height: 1,
                          indent: 16,
                          endIndent: 16,
                          color: theme.colorScheme.outlineVariant,
                        ),
                    ],
                  );
                }).toList(),
              ],
            ),
          ),
          const SizedBox(height: 16),

          OutlinedButton.icon(
            onPressed: () {
              setState(() => _isLoading = true);
              _loadDeviceInfo();
              _loadBatteryInfo();
              _loadChargingCycles();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh Info'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}
