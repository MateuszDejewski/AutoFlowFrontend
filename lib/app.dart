import 'package:flutter/material.dart';

import 'screens/mock_picker_screen.dart';
import 'theme/app_colors.dart';

class AutoFlowApp extends StatelessWidget {
  const AutoFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AutoFlow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.canvas,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.teal,
          surface: Colors.white,
        ),
        fontFamily: 'Roboto',
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF6F8F8),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          hintStyle: const TextStyle(color: Color(0xFFA1ABB2)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE6EAEC)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE6EAEC)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.teal, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFD84F4F)),
          ),
        ),
      ),
      home: const MockPickerScreen(),
    );
  }
}
