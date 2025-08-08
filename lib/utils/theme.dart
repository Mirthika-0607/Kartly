import 'package:flutter/material.dart';

class AppColors {
  // Color Palette from Color Hunt
  static const Color darkBlue = Color(0xFF213448); // Primary color for headers, buttons
  static const Color teal = Color(0xFF547792); // Secondary color for icons, accents
  static const Color lightBlue = Color(0xFF94B4C1); // Backgrounds, cards
  static const Color beige = Color(0xFFECEFCA); // Scaffold, text fields

  // Method to get ThemeData with the color palette
  static ThemeData getTheme() {
    return ThemeData(
      primaryColor: darkBlue,
      scaffoldBackgroundColor: beige,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkBlue,
          foregroundColor: beige,
          surfaceTintColor: teal,
        ),
      ),
      cardColor: lightBlue,
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: darkBlue), // Primary text
        bodyMedium: TextStyle(color: teal), // Secondary text
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBlue,
        foregroundColor: beige,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(
          borderSide: BorderSide(color: teal),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: darkBlue, width: 2),
        ),
        fillColor: lightBlue,
        filled: true,
      ),
      iconTheme: const IconThemeData(color: teal),
    );
  }

  // Utility methods for specific elements
  static ButtonStyle primaryButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: darkBlue,
      foregroundColor: beige,
      surfaceTintColor: teal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  static ButtonStyle secondaryButtonStyle() {
    return OutlinedButton.styleFrom(
      foregroundColor: darkBlue,
      side: const BorderSide(color: teal),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      textStyle: const TextStyle(fontSize: 16),
    );
  }

  static TextStyle primaryTextStyle() {
    return const TextStyle(
      color: darkBlue,
      fontSize: 16,
      fontWeight: FontWeight.w500,
    );
  }

  static TextStyle secondaryTextStyle() {
    return const TextStyle(
      color: teal,
      fontSize: 14,
    );
  }

  static InputDecoration textFieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: teal),
      border: const OutlineInputBorder(
        borderSide: BorderSide(color: teal),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: darkBlue, width: 2),
      ),
      fillColor: lightBlue,
      filled: true,
    );
  }

  static BoxDecoration cardDecoration() {
    return BoxDecoration(
      color: lightBlue,
      borderRadius: BorderRadius.circular(8),
      boxShadow: const [
        BoxShadow(
          color: teal,
          blurRadius: 4,
          offset: Offset(0, 2),
        ),
      ],
    );
  }
}