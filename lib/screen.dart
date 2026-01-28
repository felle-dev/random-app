import 'package:flutter/material.dart';
import 'package:random/tab/generators.dart';
import 'package:random/tab/games.dart';
import 'package:random/tab/utilities.dart';
import 'package:random/config/app_strings.dart';
import 'package:random/config/app_dimensions.dart';
import 'package:random/config/app_languages.dart';
import 'package:random/widgets/custom_floating_nav_bar.dart';
import 'package:random/utils/language_provider.dart';
import 'package:provider/provider.dart';

/// Main screen that hosts the tabbed navigation interface. 
/// Displays three main sections: Generators, Utilities, and Games,
/// accessible through a floating navigation bar and swipeable pages.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _navIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Returns the appropriate title based on the currently selected tab.
  String get _currentTitle {
    switch (_navIndex) {
      case 0:
        return AppStrings.navGenerators;
      case 1:
        return AppStrings.navUtilities;
      case 2:
        return AppStrings.navGames;
      default:
        return AppStrings.appTitle;
    }
  }

  /// Updates the navigation index when the page is swiped.
  void _onPageChanged(int index) {
    setState(() => _navIndex = index);
  }

  /// Animates to the selected page when a navigation item is tapped.
  void _onNavTap(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(
        milliseconds: AppDimensions.animationDurationSlow,
      ),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: AppDimensions.appBarExpandedHeight,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  _currentTitle,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                titlePadding: const EdgeInsets.only(
                  left: AppDimensions.paddingMedium,
                  bottom: AppDimensions.paddingMedium,
                ),
                expandedTitleScale: AppDimensions.appBarExpandedTitleScale,
              ),
              backgroundColor: theme.colorScheme.surface,
              foregroundColor: theme.colorScheme.onSurface,
              actions: [
                PopupMenuButton<String>(
                  icon: const Icon(Icons.language),
                  tooltip: AppStrings.languageTooltip,
                  onSelected: (String languageCode) {
                    languageProvider.changeLanguage(languageCode);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Language changed to ${AppLanguages.getLanguageName(languageCode)}',
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem(
                      value: AppLanguages.english,
                      child: Row(
                        children: [
                          Text(AppStrings.languageEnglish),
                          if (languageProvider.currentLanguage ==
                              AppLanguages.english)
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Icon(
                                Icons.check,
                                size: 16,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: AppLanguages.german,
                      child: Row(
                        children: [
                          Text(AppStrings.languageGerman),
                          if (languageProvider.currentLanguage ==
                              AppLanguages.german)
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Icon(
                                Icons.check,
                                size: 16,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: AppLanguages.indonesian,
                      child: Row(
                        children: [
                          Text(AppStrings.languageIndonesian),
                          if (languageProvider.currentLanguage ==
                              AppLanguages.indonesian)
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Icon(
                                Icons.check,
                                size: 16,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.info_outline),
                  onPressed: () => _showAboutDialog(context),
                  tooltip: AppStrings.aboutTooltip,
                ),
              ],
            ),
          ];
        },
        body: PageView(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          children: const [GeneratorsTab(), UtilitiesTab(), GamesToolsTab()],
        ),
      ),
      extendBody: true,
      bottomNavigationBar: CustomFloatingNavBar(
        currentIndex: _navIndex,
        onTap: _onNavTap,
      ),
    );
  }

  /// Displays a dialog with app information and license details.
  void _showAboutDialog(BuildContext context) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.aboutTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.aboutDescription,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppDimensions.paddingMedium),
            Text(
              AppStrings.aboutDetails,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.btnClose),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(context);
              showLicensePage(
                context: context,
                applicationName: AppStrings.appTitle,
                applicationVersion: AppStrings.appVersion,
              );
            },
            icon: const Icon(
              Icons.description_outlined,
              size: AppDimensions.iconSmall,
            ),
            label: Text(AppStrings.btnLicenses),
          ),
        ],
      ),
    );
  }
}
