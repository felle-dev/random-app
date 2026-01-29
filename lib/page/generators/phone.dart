import 'package:flutter/material.dart';
import 'package:random/controllers/phone_generator_controller.dart';
import 'package:random/config/app_strings.dart';
import 'package:random/config/app_dimensions.dart';
import 'package:random/config/phone_constants.dart';
import 'package:random/utils/clipboard_helper.dart';
import 'package:random/widgets/phone_result_card.dart';
import 'package:random/widgets/country_selector_card.dart';
import 'package:random/widgets/phone_history_card.dart';

class PhoneGeneratorPage extends StatefulWidget {
  const PhoneGeneratorPage({super.key});

  @override
  State<PhoneGeneratorPage> createState() => _PhoneGeneratorPageState();
}

class _PhoneGeneratorPageState extends State<PhoneGeneratorPage> {
  final PhoneGeneratorController _controller = PhoneGeneratorController();

  String _generatedPhone = '';
  String _phoneFormat = '';
  String _selectedCountry = 'US';
  final List<Map<String, String>> _history = [];

  @override
  void initState() {
    super.initState();
    _generatePhone();
  }

  void _generatePhone() {
    final country = PhoneConstants.countries[_selectedCountry]!;
    final result = _controller.generatePhone(country);

    setState(() {
      _generatedPhone = result['number']!;
      _phoneFormat = result['full']!;

      if (_history.length >= 10) {
        _history.removeAt(0);
      }
      _history.add(result);
    });
  }

  void _copyToClipboard(String text, {bool withCode = false}) {
    ClipboardHelper.copyToClipboard(
      context,
      text,
      message: withCode
          ? AppStrings.copiedWithCode
          : AppStrings.copiedWithoutCode,
    );
  }

  @override
  Widget build(BuildContext context) {
    final country = PhoneConstants.countries[_selectedCountry]!;

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.phoneGeneratorTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        children: [
          PhoneResultCard(
            country: country,
            phoneNumber: _generatedPhone,
            fullNumber: _phoneFormat,
            onCopyWithCode: () =>
                _copyToClipboard(_phoneFormat, withCode: true),
            onCopyWithoutCode: () => _copyToClipboard(_generatedPhone),
            onGenerate: _generatePhone,
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          CountrySelectorCard(
            title: AppStrings.selectCountry,
            selectedCountry: _selectedCountry,
            countries: PhoneConstants.countries,
            onCountryChanged: (country) {
              setState(() => _selectedCountry = country);
              _generatePhone();
            },
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          PhoneHistoryCard(
            history: _history,
            onClear: () => setState(() => _history.clear()),
            onCopy: (phone) => _copyToClipboard(phone, withCode: true),
          ),
          const SizedBox(height: AppDimensions.spacing100),
        ],
      ),
    );
  }
}
