import 'package:flutter/material.dart';
import 'package:random/controllers/device_generator_controller.dart';
import 'package:random/config/app_strings.dart';
import 'package:random/config/app_dimensions.dart';
import 'package:random/config/device_constants.dart';
import 'package:random/utils/clipboard_helper.dart';
import 'package:random/widgets/generated_result_card.dart';
import 'package:random/widgets/category_selector_card.dart';
import 'package:random/widgets/generation_history_card.dart';

class DeviceGeneratorPage extends StatefulWidget {
  const DeviceGeneratorPage({super.key});

  @override
  State<DeviceGeneratorPage> createState() => _DeviceGeneratorPageState();
}

class _DeviceGeneratorPageState extends State<DeviceGeneratorPage> {
  final DeviceGeneratorController _controller = DeviceGeneratorController();

  String _generatedDeviceName = '';
  String _selectedCategory = 'Random';
  final List<String> _history = [];

  @override
  void initState() {
    super.initState();
    _generateDeviceName();
  }

  void _generateDeviceName() {
    final deviceName = _controller.generateDeviceName(
      category: _selectedCategory,
    );

    setState(() {
      _generatedDeviceName = deviceName;
      if (_history.length >= 10) {
        _history.removeAt(0);
      }
      _history.add(deviceName);
    });
  }

  void _copyToClipboard(String text) {
    ClipboardHelper.copyToClipboard(
      context,
      text,
      message: '${AppStrings.copied} "$text" ${AppStrings.copiedToClipboard}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.deviceGeneratorTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        children: [
          GeneratedResultCard(
            title: AppStrings.generatedWifiName,
            result: _generatedDeviceName,
            icon: Icons.wifi,
            onCopy: () => _copyToClipboard(_generatedDeviceName),
            onGenerate: _generateDeviceName,
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          CategorySelectorCard(
            title: AppStrings.selectCategory,
            selectedCategory: _selectedCategory,
            categories: DeviceConstants.categories,
            onCategoryChanged: (category) {
              setState(() => _selectedCategory = category);
              _generateDeviceName();
            },
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          GenerationHistoryCard(
            history: _history,
            onClear: () => setState(() => _history.clear()),
            onCopy: _copyToClipboard,
            iconData: Icons.wifi,
          ),
          const SizedBox(height: AppDimensions.spacing100),
        ],
      ),
    );
  }
}
