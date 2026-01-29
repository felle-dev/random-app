import 'package:flutter/material.dart';
import 'package:random/page/generators/device.dart';
import 'package:random/page/generators/email.dart';
import 'package:random/page/generators/identity.dart';
import 'package:random/page/generators/loremipsum.dart';
import 'package:random/page/generators/password.dart';
import 'package:random/page/generators/phone.dart';
import 'package:random/page/generators/username.dart';
import 'package:random/models/generator_item.dart';
import 'package:random/config/app_strings.dart';
import 'package:random/config/app_dimensions.dart';
import 'package:random/utils/preferences_helper.dart';
import 'package:random/widgets/generator_list_card.dart';

class GeneratorsTab extends StatefulWidget {
  const GeneratorsTab({super.key});

  @override
  State<GeneratorsTab> createState() => _GeneratorsTabState();
}

class _GeneratorsTabState extends State<GeneratorsTab> {
  late List<GeneratorItem> _generators;

  @override
  void initState() {
    super.initState();
    _initializeGenerators();
  }

  void _initializeGenerators() {
    _generators = [];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final colorScheme = Theme.of(context).colorScheme;
    final shouldLoadPinned = _generators.isEmpty;

    final Map<String, bool> pinnedState = {};
    for (var generator in _generators) {
      pinnedState[generator.id] = generator.isPinned;
    }

    _generators = [
      GeneratorItem(
        id: 'password',
        title: AppStrings.generatorPassword,
        subtitle: AppStrings.generatorPasswordSubtitle,
        icon: Icons.lock_outline,
        containerColor: colorScheme.primaryContainer,
        pageBuilder: () => const PasswordGeneratorPage(),
      ),
      GeneratorItem(
        id: 'email',
        title: AppStrings.generatorEmail,
        subtitle: AppStrings.generatorEmailSubtitle,
        icon: Icons.email_outlined,
        containerColor: colorScheme.secondaryContainer,
        pageBuilder: () => const EmailGeneratorPage(),
      ),
      GeneratorItem(
        id: 'username',
        title: AppStrings.generatorUsername,
        subtitle: AppStrings.generatorUsernameSubtitle,
        icon: Icons.person_outline,
        containerColor: colorScheme.tertiaryContainer,
        pageBuilder: () => const UsernameGeneratorPage(),
      ),
      GeneratorItem(
        id: 'device',
        title: AppStrings.generatorDevice,
        subtitle: AppStrings.generatorDeviceSubtitle,
        icon: Icons.phone_android_outlined,
        containerColor: colorScheme.errorContainer,
        pageBuilder: () => const DeviceGeneratorPage(),
      ),
      GeneratorItem(
        id: 'identity',
        title: AppStrings.generatorIdentity,
        subtitle: AppStrings.generatorIdentitySubtitle,
        icon: Icons.badge_outlined,
        containerColor: colorScheme.errorContainer,
        pageBuilder: () => const RandomIdentityGeneratorPage(),
      ),
      GeneratorItem(
        id: 'phone',
        title: AppStrings.generatorPhone,
        subtitle: AppStrings.generatorPhoneSubtitle,
        icon: Icons.phone_outlined,
        containerColor: colorScheme.primaryContainer,
        pageBuilder: () => const PhoneGeneratorPage(),
      ),
      GeneratorItem(
        id: 'lorem_ipsum',
        title: AppStrings.generatorLoremIpsum,
        subtitle: AppStrings.generatorLoremIpsumSubtitle,
        icon: Icons.text_fields,
        containerColor: colorScheme.secondaryContainer,
        pageBuilder: () => const LoremIpsumGeneratorPage(),
      ),
    ];

    for (var generator in _generators) {
      if (pinnedState.containsKey(generator.id)) {
        generator.isPinned = pinnedState[generator.id]!;
      }
    }

    if (shouldLoadPinned) {
      _loadPinnedState();
    }
  }

  Future<void> _loadPinnedState() async {
    final pinnedIds = await PreferencesHelper.getPinnedGenerators();

    setState(() {
      for (var generator in _generators) {
        generator.isPinned = pinnedIds.contains(generator.id);
      }
    });
  }

  Future<void> _savePinnedState() async {
    final pinnedIds = _generators
        .where((g) => g.isPinned)
        .map((g) => g.id)
        .toList();
    await PreferencesHelper.savePinnedGenerators(pinnedIds);
  }

  List<GeneratorItem> get _pinnedGenerators =>
      _generators.where((g) => g.isPinned).toList();

  List<GeneratorItem> get _unpinnedGenerators =>
      _generators.where((g) => !g.isPinned).toList();

  void _togglePin(GeneratorItem item) {
    setState(() {
      item.isPinned = !item.isPinned;
    });
    _savePinnedState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final pinnedItems = _pinnedGenerators;
    final unpinnedItems = _unpinnedGenerators;

    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: CustomScrollView(
        slivers: [
          // Pinned section
          if (pinnedItems.isNotEmpty) ...[
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.paddingMedium,
                AppDimensions.paddingMedium,
                AppDimensions.paddingMedium,
                AppDimensions.paddingSmall,
              ),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Icon(
                      Icons.push_pin,
                      size: AppDimensions.iconXSmall,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: AppDimensions.spacing8),
                    Text(
                      AppStrings.pinned,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingMedium,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final item = pinnedItems[index];
                  return GeneratorListCard(
                    key: ValueKey(item.id),
                    item: item,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => item.pageBuilder(),
                        ),
                      );
                    },
                    onTogglePin: () => _togglePin(item),
                  );
                }, childCount: pinnedItems.length),
              ),
            ),
          ],

          // Unpinned section
          if (unpinnedItems.isNotEmpty) ...[
            if (pinnedItems.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.paddingMedium,
                  AppDimensions.paddingLarge,
                  AppDimensions.paddingMedium,
                  AppDimensions.paddingSmall,
                ),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    AppStrings.allGenerators,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingMedium,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final item = unpinnedItems[index];
                  return GeneratorListCard(
                    key: ValueKey(item.id),
                    item: item,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => item.pageBuilder(),
                        ),
                      );
                    },
                    onTogglePin: () => _togglePin(item),
                  );
                }, childCount: unpinnedItems.length),
              ),
            ),
          ],

          const SliverToBoxAdapter(
            child: SizedBox(height: AppDimensions.spacing100),
          ),
        ],
      ),
    );
  }
}
