import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:random/screen.dart';

class RandomApp extends StatelessWidget {
  const RandomApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Random',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        fontFamily: 'Outfit',
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontFamily: 'NoyhR'),
          displayMedium: TextStyle(fontFamily: 'NoyhR'),
          displaySmall: TextStyle(fontFamily: 'NoyhR'),
          headlineLarge: TextStyle(fontFamily: 'NoyhR'),
          headlineMedium: TextStyle(fontFamily: 'NoyhR'),
          headlineSmall: TextStyle(fontFamily: 'NoyhR'),
          titleLarge: TextStyle(fontFamily: 'NoyhR'),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: ColorScheme.fromSeed(
            seedColor: Colors.purple,
          ).surface,
          foregroundColor: ColorScheme.fromSeed(
            seedColor: Colors.purple,
          ).onSurface,
          elevation: 0,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: ColorScheme.fromSeed(
            seedColor: Colors.purple,
          ).surfaceContainerLow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.purple,
          brightness: Brightness.dark,
        ),
        fontFamily: 'Outfit',
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontFamily: 'NoyhR'),
          displayMedium: TextStyle(fontFamily: 'NoyhR'),
          displaySmall: TextStyle(fontFamily: 'NoyhR'),
          headlineLarge: TextStyle(fontFamily: 'NoyhR'),
          headlineMedium: TextStyle(fontFamily: 'NoyhR'),
          headlineSmall: TextStyle(fontFamily: 'NoyhR'),
          titleLarge: TextStyle(fontFamily: 'NoyhR'),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: ColorScheme.fromSeed(
            seedColor: Colors.purple,
            brightness: Brightness.dark,
          ).surface,
          foregroundColor: ColorScheme.fromSeed(
            seedColor: Colors.purple,
            brightness: Brightness.dark,
          ).onSurface,
          elevation: 0,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
