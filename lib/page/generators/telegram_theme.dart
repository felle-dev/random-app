import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:material_color_utilities/material_color_utilities.dart';

// Constants
class Constants {
  static const String urlAbout =
      'https://github.com/mi-g-alex/Telegram-Monet/blob/main/README.md';
  static const String urlTelegram = 'https://t.me/tgmonet';
  static const String urlGithub = 'https://github.com/mi-g-alex/Telegram-Monet';

  static const String inputFileTelegramLight = 'monet_light.attheme';
  static const String inputFileTelegramDark = 'monet_dark.attheme';
  static const String inputFileTelegramXLight = 'monet_x_light.tgx-theme';
  static const String inputFileTelegramXDark = 'monet_x_dark.tgx-theme';

  static const String outputFileTelegramLight = 'Light Theme.attheme';
  static const String outputFileTelegramDark = 'Dark Theme.attheme';
  static const String outputFileTelegramAmoled = 'Amoled Theme.attheme';
  static const String outputFileTelegramXLight = 'Light Theme.tgx-theme';
  static const String outputFileTelegramXDark = 'Dark Theme.tgx-theme';
  static const String outputFileTelegramXAmoled = 'Amoled Theme.tgx-theme';

  static const String sharedIsAmoled = 'isAmoledMode';
  static const String sharedUseGradient = 'useGradient';
  static const String sharedUseGradientAvatars = 'useGradientAvatars';
  static const String sharedUseColorfulNickname = 'useColorNick';
  static const String sharedUseOldChatStyle = 'useOldChatStyle';
}

// Material You Color Extractor
class MaterialYouColors {
  final ColorScheme colorScheme;

  MaterialYouColors(this.colorScheme);

  int _toSignedInt(int value) {
    return value.toSigned(32);
  }

  int _colorToArgb(Color color) {
    return _toSignedInt(color.value);
  }

  TonalPalette _createPalette(Color color) {
    final hct = Hct.fromInt(color.value);
    return TonalPalette.of(hct.hue, hct.chroma);
  }

  Color _getTone(TonalPalette palette, int tone) {
    return Color(palette.get(tone));
  }

  Map<String, int> getTelegramColorMap() {
    final primaryPalette = _createPalette(colorScheme.primary);
    final secondaryPalette = _createPalette(colorScheme.secondary);
    final tertiaryPalette = _createPalette(colorScheme.tertiary);
    final neutralPalette = _createPalette(colorScheme.surface);
    final neutralVariantPalette = _createPalette(colorScheme.surfaceVariant);

    return {
      'a1_0': _colorToArgb(_getTone(primaryPalette, 0)),
      'a1_10': _colorToArgb(_getTone(primaryPalette, 10)),
      'a1_50': _colorToArgb(_getTone(primaryPalette, 5)),
      'a1_100': _colorToArgb(_getTone(primaryPalette, 10)),
      'a1_200': _colorToArgb(_getTone(primaryPalette, 20)),
      'a1_300': _colorToArgb(_getTone(primaryPalette, 30)),
      'a1_400': _colorToArgb(_getTone(primaryPalette, 40)),
      'a1_500': _colorToArgb(_getTone(primaryPalette, 50)),
      'a1_600': _colorToArgb(_getTone(primaryPalette, 60)),
      'a1_700': _colorToArgb(_getTone(primaryPalette, 70)),
      'a1_800': _colorToArgb(_getTone(primaryPalette, 80)),
      'a1_900': _colorToArgb(_getTone(primaryPalette, 90)),
      'a1_1000': _colorToArgb(_getTone(primaryPalette, 100)),
      'a2_0': _colorToArgb(_getTone(secondaryPalette, 0)),
      'a2_10': _colorToArgb(_getTone(secondaryPalette, 10)),
      'a2_50': _colorToArgb(_getTone(secondaryPalette, 5)),
      'a2_100': _colorToArgb(_getTone(secondaryPalette, 10)),
      'a2_200': _colorToArgb(_getTone(secondaryPalette, 20)),
      'a2_300': _colorToArgb(_getTone(secondaryPalette, 30)),
      'a2_400': _colorToArgb(_getTone(secondaryPalette, 40)),
      'a2_500': _colorToArgb(_getTone(secondaryPalette, 50)),
      'a2_600': _colorToArgb(_getTone(secondaryPalette, 60)),
      'a2_700': _colorToArgb(_getTone(secondaryPalette, 70)),
      'a2_800': _colorToArgb(_getTone(secondaryPalette, 80)),
      'a2_900': _colorToArgb(_getTone(secondaryPalette, 90)),
      'a2_1000': _colorToArgb(_getTone(secondaryPalette, 100)),
      'a3_0': _colorToArgb(_getTone(tertiaryPalette, 0)),
      'a3_10': _colorToArgb(_getTone(tertiaryPalette, 10)),
      'a3_50': _colorToArgb(_getTone(tertiaryPalette, 5)),
      'a3_100': _colorToArgb(_getTone(tertiaryPalette, 10)),
      'a3_200': _colorToArgb(_getTone(tertiaryPalette, 20)),
      'a3_300': _colorToArgb(_getTone(tertiaryPalette, 30)),
      'a3_400': _colorToArgb(_getTone(tertiaryPalette, 40)),
      'a3_500': _colorToArgb(_getTone(tertiaryPalette, 50)),
      'a3_600': _colorToArgb(_getTone(tertiaryPalette, 60)),
      'a3_700': _colorToArgb(_getTone(tertiaryPalette, 70)),
      'a3_800': _colorToArgb(_getTone(tertiaryPalette, 80)),
      'a3_900': _colorToArgb(_getTone(tertiaryPalette, 90)),
      'a3_1000': _colorToArgb(_getTone(tertiaryPalette, 100)),
      'n1_0': _colorToArgb(_getTone(neutralPalette, 0)),
      'n1_10': _colorToArgb(_getTone(neutralPalette, 10)),
      'n1_50': _colorToArgb(_getTone(neutralPalette, 5)),
      'n1_100': _colorToArgb(_getTone(neutralPalette, 10)),
      'n1_200': _colorToArgb(_getTone(neutralPalette, 20)),
      'n1_300': _colorToArgb(_getTone(neutralPalette, 30)),
      'n1_400': _colorToArgb(_getTone(neutralPalette, 40)),
      'n1_500': _colorToArgb(_getTone(neutralPalette, 50)),
      'n1_600': _colorToArgb(_getTone(neutralPalette, 60)),
      'n1_700': _colorToArgb(_getTone(neutralPalette, 70)),
      'n1_800': _colorToArgb(_getTone(neutralPalette, 80)),
      'n1_900': _colorToArgb(_getTone(neutralPalette, 90)),
      'n1_1000': _colorToArgb(_getTone(neutralPalette, 100)),
      'n2_0': _colorToArgb(_getTone(neutralVariantPalette, 0)),
      'n2_10': _colorToArgb(_getTone(neutralVariantPalette, 10)),
      'n2_50': _colorToArgb(_getTone(neutralVariantPalette, 5)),
      'n2_100': _colorToArgb(_getTone(neutralVariantPalette, 10)),
      'n2_200': _colorToArgb(_getTone(neutralVariantPalette, 20)),
      'n2_300': _colorToArgb(_getTone(neutralVariantPalette, 30)),
      'n2_400': _colorToArgb(_getTone(neutralVariantPalette, 40)),
      'n2_500': _colorToArgb(_getTone(neutralVariantPalette, 50)),
      'n2_600': _colorToArgb(_getTone(neutralVariantPalette, 60)),
      'n2_700': _colorToArgb(_getTone(neutralVariantPalette, 70)),
      'n2_800': _colorToArgb(_getTone(neutralVariantPalette, 80)),
      'n2_900': _colorToArgb(_getTone(neutralVariantPalette, 90)),
      'n2_1000': _colorToArgb(_getTone(neutralVariantPalette, 100)),
      'monetRedDark': _toSignedInt(const Color(0xFFCF6679).value),
      'monetRedLight': _toSignedInt(const Color(0xFFB00020).value),
      'monetRedCall': _toSignedInt(const Color(0xFFFF5252).value),
      'monetGreenCall': _toSignedInt(const Color(0xFF00C853).value),
    };
  }

  Map<String, String> getTelegramXColorMap() {
    final telegramMap = getTelegramColorMap();
    return telegramMap.map((key, value) {
      final unsigned = value & 0xFFFFFFFF;
      final hexString = unsigned.toRadixString(16).padLeft(8, '0');
      return MapEntry(key, '#${hexString.substring(2)}');
    });
  }
}

const listToReplaceNewThemeTelegram = [
  "chat_messageLinkOut",
  "chat_messageTextOut",
  "chat_outAdminSelectedText",
  "chat_outAdminText",
  "chat_outAudioCacheSeekbar",
  "chat_outAudioDurationSelectedText",
  "chat_outAudioDurationText",
  "chat_outAudioPerfomerSelectedText",
  "chat_outAudioPerfomerText",
  "chat_outAudioProgress",
  "chat_outAudioSeekbar",
  "chat_outAudioSeekbarFill",
  "chat_outAudioSeekbarSelected",
  "chat_outAudioSelectedProgress",
  "chat_outAudioTitleText",
  "chat_outBubble",
  "chat_outBubbleGradient",
  "chat_outBubbleGradient2",
  "chat_outBubbleGradient3",
  "chat_outBubbleGradientAnimated",
  "chat_outBubbleGradientSelectedOverlay",
  "chat_outBubbleSelected",
  "chat_outBubbleShadow",
  "chat_outContactBackground",
  "chat_outContactIcon",
  "chat_outContactNameText",
  "chat_outContactPhoneSelectedText",
  "chat_outContactPhoneText",
  "chat_outFileBackground",
  "chat_outFileBackgroundSelected",
  "chat_outFileInfoSelectedText",
  "chat_outFileInfoText",
  "chat_outFileNameText",
  "chat_outFileProgress",
  "chat_outFileProgressSelected",
  "chat_outForwardedNameText",
  "chat_outInstant",
  "chat_outInstantSelected",
  "chat_outLinkSelectBackground",
  "chat_outLoader",
  "chat_outLoaderSelected",
  "chat_outLocationIcon",
  "chat_outMediaIcon",
  "chat_outMediaIconSelected",
  "chat_outMenu",
  "chat_outMenuSelected",
  "chat_outPollCorrectAnswer",
  "chat_outPollWrongAnswer",
  "chat_outPreviewInstantText",
  "chat_outPreviewLine",
  "chat_outPsaNameText",
  "chat_outReactionButtonBackground",
  "chat_outReactionButtonText",
  "chat_outReactionButtonTextSelected",
  "chat_outReplyLine",
  "chat_outReplyMediaMessageSelectedText",
  "chat_outReplyMediaMessageText",
  "chat_outReplyMessageText",
  "chat_outReplyNameText",
  "chat_outSentCheck",
  "chat_outSentCheckRead",
  "chat_outSentCheckReadSelected",
  "chat_outSentCheckSelected",
  "chat_outSentClock",
  "chat_outSentClockSelected",
  "chat_outSiteNameText",
  "chat_outTextSelectionCursor",
  "chat_outTextSelectionHighlight",
  "chat_outTimeSelectedText",
  "chat_outTimeText",
  "chat_outUpCall",
  "chat_outVenueInfoSelectedText",
  "chat_outVenueInfoText",
  "chat_outViaBotNameText",
  "chat_outViews",
  "chat_outViewsSelected",
  "chat_outVoiceSeekbar",
  "chat_outVoiceSeekbarFill",
  "chat_outVoiceSeekbarSelected",
];

const listToReplaceNewThemeTelegramX = [
  "bubbleOut_fillingActive",
  "bubbleOut_fillingActiveContent",
  "bubbleOut_fillingPositive",
  "bubbleOut_fillingPositiveContent",
  "bubbleOut_fillingPositive_overlay",
  "bubbleOut_fillingPositiveContent_overlay",
  "bubbleOut_background",
  "bubbleOut_ticks",
  "bubbleOut_ticksRead",
  "bubbleOut_time",
  "bubbleOut_progress",
  "bubbleOut_text",
  "bubbleOut_textLink",
  "bubbleOut_textLinkPressHighlight",
  "bubbleOut_messageAuthor",
  "bubbleOut_messageAuthorPsa",
  "bubbleOut_chatVerticalLine",
  "bubbleOut_inlineOutline",
  "bubbleOut_inlineText",
  "bubbleOut_inlineIcon",
  "bubbleOut_waveformActive",
  "bubbleOut_waveformInactive",
  "bubbleOut_file",
  "bubbleOut_pressed",
  "bubbleOut_separator",
  "bubbleOut_chatNeutralFillingContent",
  "bubbleOut_chatCorrectFilling",
  "bubbleOut_chatCorrectFillingContent",
  "bubbleOut_chatCorrectChosenFilling",
  "bubbleOut_chatCorrectChosenFillingContent",
  "bubbleOut_chatNegativeFilling",
  "bubbleOut_chatNegativeFillingContent",
];

class TelegramMonetApp extends StatefulWidget {
  const TelegramMonetApp({super.key});

  @override
  State<TelegramMonetApp> createState() => _TelegramMonetAppState();
}

class _TelegramMonetAppState extends State<TelegramMonetApp> {
  bool isAmoled = false;
  bool isGradient = false;
  bool isAvatarGradient = false;
  bool isNicknameColorful = true;
  bool isAlterOutColor = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isAmoled = prefs.getBool(Constants.sharedIsAmoled) ?? false;
      isGradient = prefs.getBool(Constants.sharedUseGradient) ?? false;
      isAvatarGradient =
          prefs.getBool(Constants.sharedUseGradientAvatars) ?? false;
      isNicknameColorful =
          prefs.getBool(Constants.sharedUseColorfulNickname) ?? true;
      isAlterOutColor = prefs.getBool(Constants.sharedUseOldChatStyle) ?? true;
    });
  }

  Future<void> _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  void _setAmoled(bool value) {
    setState(() => isAmoled = value);
    _saveSetting(Constants.sharedIsAmoled, value);
  }

  void _setGradient(bool value) {
    setState(() => isGradient = value);
    _saveSetting(Constants.sharedUseGradient, value);
  }

  void _setAvatarGradient(bool value) {
    setState(() => isAvatarGradient = value);
    _saveSetting(Constants.sharedUseGradientAvatars, value);
  }

  void _setNicknameColorful(bool value) {
    setState(() => isNicknameColorful = value);
    _saveSetting(Constants.sharedUseColorfulNickname, value);
  }

  void _setAlterOutColor(bool value) {
    setState(() => isAlterOutColor = value);
    _saveSetting(Constants.sharedUseOldChatStyle, value);
  }

  Future<void> _onShareTheme(bool isTelegram, bool isLight) async {
    final inputFileName = _getInputFileName(isTelegram, isLight);
    final outputFileName = _getOutputFileName(isTelegram, isLight);

    await _createTheme(
      isTelegram: isTelegram,
      isLight: isLight,
      inputFileName: inputFileName,
      outputFileName: outputFileName,
    );
  }

  String _getInputFileName(bool isTelegram, bool isLight) {
    if (isTelegram && isLight) return Constants.inputFileTelegramLight;
    if (isTelegram) return Constants.inputFileTelegramDark;
    if (!isTelegram && isLight) return Constants.inputFileTelegramXLight;
    return Constants.inputFileTelegramXDark;
  }

  String _getOutputFileName(bool isTelegram, bool isLight) {
    if (isTelegram && isLight) return Constants.outputFileTelegramLight;
    if (isTelegram && !isAmoled) return Constants.outputFileTelegramDark;
    if (isTelegram) return Constants.outputFileTelegramAmoled;
    if (!isTelegram && isLight) return Constants.outputFileTelegramXLight;
    if (!isTelegram && !isAmoled) return Constants.outputFileTelegramXDark;
    return Constants.outputFileTelegramXAmoled;
  }

  Future<void> _createTheme({
    required bool isTelegram,
    required bool isLight,
    required String inputFileName,
    required String outputFileName,
  }) async {
    try {
      final themeContent = await rootBundle.loadString('assets/$inputFileName');
      List<String> lines = themeContent.split('\n');

      if (isGradient) {
        lines = lines.map((line) {
          return line.replaceAll('noGradient', 'chat_outBubbleGradient');
        }).toList();
      }

      if (isAlterOutColor && isTelegram) {
        final alternateFileName = isLight
            ? Constants.inputFileTelegramDark
            : Constants.inputFileTelegramLight;
        final alternateContent = await rootBundle.loadString(
          'assets/$alternateFileName',
        );
        final alternateLines = alternateContent.split('\n');

        for (final key in listToReplaceNewThemeTelegram) {
          final mainIndex = lines.indexWhere(
            (line) => line.startsWith('$key='),
          );
          final altIndex = alternateLines.indexWhere(
            (line) => line.startsWith('$key='),
          );

          if (mainIndex >= 0 && altIndex >= 0) {
            lines[mainIndex] = alternateLines[altIndex];
          }
        }
      }

      if (isAlterOutColor && !isTelegram) {
        final alternateFileName = isLight
            ? Constants.inputFileTelegramXDark
            : Constants.inputFileTelegramXLight;
        final alternateContent = await rootBundle.loadString(
          'assets/$alternateFileName',
        );
        final alternateLines = alternateContent.split('\n');

        for (final key in listToReplaceNewThemeTelegramX) {
          final mainIndex = lines.indexWhere(
            (line) => line.startsWith('$key:'),
          );
          final altIndex = alternateLines.indexWhere(
            (line) => line.startsWith('$key:'),
          );

          if (mainIndex >= 0 && altIndex >= 0) {
            lines[mainIndex] = alternateLines[altIndex];
          }
        }
      }

      String themeImport = lines.join('\n');

      if (isAmoled) {
        themeImport = themeImport.replaceAll('n1_900', 'n1_1000');
      }

      if (isTelegram && isNicknameColorful) {
        themeImport = themeImport.replaceAll(
          '\nend',
          '\navatar_nameInMessageBlue=a1_400\n'
              'avatar_nameInMessageCyan=a1_400\n'
              'avatar_nameInMessageGreen=a1_400\n'
              'avatar_nameInMessageOrange=a1_400\n'
              'avatar_nameInMessagePink=a1_400\n'
              'avatar_nameInMessageRed=a1_400\n'
              'avatar_nameInMessageViolet=a1_400\nend',
        );
      }

      if (isTelegram && isAvatarGradient) {
        themeImport = themeImport
            .replaceAll(
              'avatar_backgroundBlue=n2_800',
              'avatar_backgroundBlue=n2_700',
            )
            .replaceAll(
              'avatar_backgroundCyan=n2_800',
              'avatar_backgroundCyan=n2_700',
            )
            .replaceAll(
              'avatar_backgroundGreen=n2_800',
              'avatar_backgroundGreen=n2_700',
            )
            .replaceAll(
              'avatar_backgroundOrange=n2_800',
              'avatar_backgroundOrange=n2_700',
            )
            .replaceAll(
              'avatar_backgroundPink=n2_800',
              'avatar_backgroundPink=n2_700',
            )
            .replaceAll(
              'avatar_backgroundRed=n2_800',
              'avatar_backgroundRed=n2_700',
            )
            .replaceAll(
              'avatar_backgroundSaved=n2_800',
              'avatar_backgroundSaved=n2_700',
            )
            .replaceAll(
              'avatar_backgroundViolet=n2_800',
              'avatar_backgroundViolet=n2_700',
            );
      }

      final colorScheme = Theme.of(context).colorScheme;
      final materialYouColors = MaterialYouColors(colorScheme);

      final generatedTheme = isTelegram
          ? _changeTextTelegram(themeImport, materialYouColors)
          : _changeTextTelegramX(themeImport, materialYouColors);

      await _saveAndShareTheme(generatedTheme, outputFileName);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error creating theme: $e')));
      }
    }
  }

  String _changeTextTelegram(String file, MaterialYouColors colors) {
    final colorMap = colors.getTelegramColorMap();
    String themeText = file;

    colorMap.forEach((key, value) {
      themeText = themeText.replaceAll('\$key', value.toString());
    });

    return themeText;
  }

  String _changeTextTelegramX(String file, MaterialYouColors colors) {
    final colorMap = colors.getTelegramXColorMap();
    String themeText = file;

    colorMap.forEach((key, value) {
      themeText = themeText.replaceAll('\$key', value);
    });

    return themeText;
  }

  Future<void> _saveAndShareTheme(String content, String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(content);

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Telegram Monet Theme',
        text: 'Check out this Material You theme for Telegram!',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Theme created and shared successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error sharing theme: $e')));
      }
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info_outline),
            SizedBox(width: 8),
            Text('About'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Generate Material You themed Telegram themes based on your device\'s dynamic colors.',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 16),
              Text(
                'How to use:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('1. Configure your theme settings'),
              Text('2. Choose Light or Dark theme'),
              Text('3. Select Telegram or Telegram X'),
              Text('4. Share the generated theme file'),
              Text('5. Open in Telegram to apply'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dynamic Telegram Theme'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showInfo,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Info Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.palette_outlined,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Generate Material You themes for Telegram apps',
                    style: TextStyle(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Generate Theme Section
          Text(
            'Generate Theme',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

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
                _ThemeGeneratorItem(
                  title: 'Light Theme',
                  subtitle: 'Material You light theme',
                  icon: Icons.light_mode,
                  color: Colors.amber,
                  onTelegramTap: () => _onShareTheme(true, true),
                  onTelegramXTap: () => _onShareTheme(false, true),
                ),
                Divider(
                  height: 1,
                  indent: 72,
                  color: theme.colorScheme.outlineVariant,
                ),
                _ThemeGeneratorItem(
                  title: 'Dark Theme',
                  subtitle: isAmoled
                      ? 'Material You AMOLED theme'
                      : 'Material You dark theme',
                  icon: Icons.dark_mode,
                  color: Colors.indigo,
                  onTelegramTap: () => _onShareTheme(true, false),
                  onTelegramXTap: () => _onShareTheme(false, false),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),         
          // Settings Section
          Text(
            'Theme Settings',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

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
                _SettingItem(
                  text: 'AMOLED Mode',
                  subtitle: 'True black for OLED displays',
                  value: isAmoled,
                  onChanged: _setAmoled,
                ),
                Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: theme.colorScheme.outlineVariant,
                ),
                _SettingItem(
                  text: 'Use Gradient',
                  subtitle: 'Apply gradient to chat bubbles',
                  value: isGradient,
                  onChanged: _setGradient,
                ),
                Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: theme.colorScheme.outlineVariant,
                ),
                _SettingItem(
                  text: 'Gradient Avatars',
                  subtitle: 'Colorful gradient avatars',
                  value: isAvatarGradient,
                  onChanged: _setAvatarGradient,
                ),
                Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: theme.colorScheme.outlineVariant,
                ),
                _SettingItem(
                  text: 'Colorful Nicknames',
                  subtitle: 'Use accent color for names',
                  value: isNicknameColorful,
                  onChanged: _setNicknameColorful,
                ),
                Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: theme.colorScheme.outlineVariant,
                ),
                _SettingItem(
                  text: 'Old Chat Style',
                  subtitle: 'Alternative outgoing bubble colors',
                  value: isAlterOutColor,
                  onChanged: _setAlterOutColor,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Links Section
          Text(
            'More Information',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

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
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _launchUrl(Constants.urlTelegram),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.telegram, color: Colors.blue),
                      ),
                      title: const Text('Telegram Channel'),
                      subtitle: const Text('Join our community'),
                      trailing: const Icon(Icons.open_in_new),
                    ),
                  ),
                ),
                Divider(
                  height: 1,
                  indent: 72,
                  color: theme.colorScheme.outlineVariant,
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _launchUrl(Constants.urlGithub),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.code, color: Colors.grey),
                      ),
                      title: const Text('GitHub Repository'),
                      subtitle: const Text('View source code'),
                      trailing: const Icon(Icons.open_in_new),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

// Theme Generator Item
class _ThemeGeneratorItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTelegramTap;
  final VoidCallback onTelegramXTap;

  const _ThemeGeneratorItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTelegramTap,
    required this.onTelegramXTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: onTelegramTap,
                  child: const Text('Telegram'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.tonal(
                  onPressed: onTelegramXTap,
                  child: const Text('Telegram X'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Setting Item
class _SettingItem extends StatelessWidget {
  final String text;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingItem({
    required this.text,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(text),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }
}
