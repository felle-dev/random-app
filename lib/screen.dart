import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:random/tab/generators.dart';
import 'package:random/tab/wheel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;
  late PageController _pageController;
  bool _isBottomNavVisible = true;

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

  String get _currentTitle {
    switch (_navIndex) {
      case 0:
        return 'Generators';
      case 1:
        return 'Wheel';
      default:
        return 'Random';
    }
  }

  void _onPageChanged(int index) {
    setState(() => _navIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 120.0,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  _currentTitle,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
                expandedTitleScale: 1.5,
              ),
              backgroundColor: theme.colorScheme.surface,
              foregroundColor: theme.colorScheme.onSurface,
            ),
          ];
        },
        body: PageView(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          children: const [GeneratorsTab(), WheelTab()],
        ),
      ),
      extendBody: true,
      bottomNavigationBar: AnimatedSlide(
        duration: const Duration(milliseconds: 300),
        offset: _isBottomNavVisible ? Offset.zero : const Offset(0, 1),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: _isBottomNavVisible ? 1.0 : 0.0,
          child: Container(
            margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: theme.colorScheme.outline.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: NavigationBar(
                    selectedIndex: _navIndex,
                    onDestinationSelected: (index) {
                      _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    elevation: 0,
                    height: 70,
                    backgroundColor: Colors.transparent,
                    indicatorColor: theme.colorScheme.primaryContainer
                        .withOpacity(0.8),
                    labelBehavior:
                        NavigationDestinationLabelBehavior.alwaysShow,
                    destinations: const [
                      NavigationDestination(
                        icon: Icon(Icons.auto_awesome_outlined),
                        selectedIcon: Icon(Icons.auto_awesome),
                        label: 'Generators',
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.album_outlined),
                        selectedIcon: Icon(Icons.album),
                        label: 'Wheel',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
