import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../config/app_strings.dart';
import '../../../config/device_info_constants.dart';
import '../../../controllers/device_info_controller.dart';
import '../../../widgets/battery_health_card.dart';
import '../../../widgets/battery_not_available_card.dart';
import '../../../widgets/device_information_card.dart';

class DeviceInfoPage extends StatefulWidget {
  const DeviceInfoPage({super.key});

  @override
  State<DeviceInfoPage> createState() => _DeviceInfoPageState();
}

class _DeviceInfoPageState extends State<DeviceInfoPage> {
  late DeviceInfoController _controller;

  @override
  void initState() {
    super.initState();
    _controller = DeviceInfoController();
    _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _copyAllDeviceInfo() {
    final allData = _controller.deviceData.entries
        .map((e) => '${e.key}: ${e.value}')
        .join('\n');
    Clipboard.setData(ClipboardData(text: allData));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text(AppStrings.deviceInfoCopied)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.deviceInfoTitle)),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, child) {
          if (_controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final batteryLevel = _controller.hasBatteryInfo
              ? int.tryParse(
                      _controller.batteryData[AppStrings.deviceInfoBatteryLevel]
                              ?.replaceAll('%', '') ??
                          '0',
                    ) ??
                    0
              : 0;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Battery Health Section
              if (_controller.hasBatteryInfo) ...[
                BatteryHealthCard(
                  batteryData: _controller.batteryData,
                  chargingCycles: _controller.chargingCycles,
                  batteryLevel: batteryLevel,
                ),
                const SizedBox(height: 16),
              ] else ...[
                const BatteryNotAvailableCard(),
                const SizedBox(height: 16),
              ],

              // Device Information Section
              DeviceInformationCard(
                deviceData: _controller.deviceData,
                onCopyAll: _copyAllDeviceInfo,
              ),
              const SizedBox(height: 16),

              // Refresh Button
              OutlinedButton.icon(
                onPressed: _controller.refresh,
                icon: const Icon(Icons.refresh),
                label: const Text(AppStrings.deviceInfoRefresh),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 100),
            ],
          );
        },
      ),
    );
  }
}
