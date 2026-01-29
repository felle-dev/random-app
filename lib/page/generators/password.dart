import 'package:flutter/material.dart';
import 'package:random/controllers/password_generator_controller.dart';
import 'package:random/config/app_strings.dart';
import 'package:random/config/app_dimensions.dart';
import 'package:random/config/password_constants.dart';
import 'package:random/utils/clipboard_helper.dart';
import 'package:random/widgets/password_result_card.dart';
import 'package:random/widgets/password_options_card.dart';
import 'package:random/widgets/generation_history_card.dart';

class PasswordGeneratorPage extends StatefulWidget {
  const PasswordGeneratorPage({super.key});

  @override
  State<PasswordGeneratorPage> createState() => _PasswordGeneratorPageState();
}

class _PasswordGeneratorPageState extends State<PasswordGeneratorPage> {
  final PasswordGeneratorController _controller = PasswordGeneratorController();

  String _password = '';
  int _length = PasswordConstants.defaultLength;
  bool _includeUppercase = true;
  bool _includeLowercase = true;
  bool _includeNumbers = true;
  bool _includeSymbols = true;
  final List<String> _history = [];

  @override
  void initState() {
    super.initState();
    _generatePassword();
  }

  void _generatePassword() {
    final newPassword = _controller.generatePassword(
      length: _length,
      includeUppercase: _includeUppercase,
      includeLowercase: _includeLowercase,
      includeNumbers: _includeNumbers,
      includeSymbols: _includeSymbols,
    );

    if (newPassword.isEmpty) return;

    setState(() {
      _password = newPassword;
      if (_history.length >= 10) {
        _history.removeAt(0);
      }
      _history.add(newPassword);
    });
  }

  void _copyToClipboard(String text) {
    ClipboardHelper.copyToClipboard(
      context,
      text,
      message: AppStrings.copiedPassword,
    );
  }

  String get _strengthLabel => _controller.getStrengthLabel(
    length: _length,
    includeUppercase: _includeUppercase,
    includeLowercase: _includeLowercase,
    includeNumbers: _includeNumbers,
    includeSymbols: _includeSymbols,
  );

  Color get _strengthColor {
    final colorScheme = Theme.of(context).colorScheme;

    switch (_strengthLabel) {
      case 'Very Strong':
        return Colors.green;
      case 'Strong':
        return Colors.lightGreen;
      case 'Medium':
        return Colors.orange;
      default:
        return colorScheme.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.passwordGeneratorTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        children: [
          PasswordResultCard(
            password: _password,
            strengthLabel: _strengthLabel,
            strengthColor: _strengthColor,
            onCopy: () => _copyToClipboard(_password),
            onGenerate: _generatePassword,
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          PasswordOptionsCard(
            length: _length,
            includeUppercase: _includeUppercase,
            includeLowercase: _includeLowercase,
            includeNumbers: _includeNumbers,
            includeSymbols: _includeSymbols,
            onLengthChanged: (value) {
              setState(() => _length = value);
              _generatePassword();
            },
            onUppercaseChanged: (value) {
              setState(() => _includeUppercase = value);
              _generatePassword();
            },
            onLowercaseChanged: (value) {
              setState(() => _includeLowercase = value);
              _generatePassword();
            },
            onNumbersChanged: (value) {
              setState(() => _includeNumbers = value);
              _generatePassword();
            },
            onSymbolsChanged: (value) {
              setState(() => _includeSymbols = value);
              _generatePassword();
            },
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          GenerationHistoryCard(
            history: _history,
            onClear: () => setState(() => _history.clear()),
            onCopy: _copyToClipboard,
            iconData: Icons.key,
          ),
          const SizedBox(height: AppDimensions.spacing100),
        ],
      ),
    );
  }
}
