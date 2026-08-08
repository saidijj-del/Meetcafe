import "package:flutter/material.dart";

class MeetCafeTheme {
  static const Color amber = Color(0xFFD97706);
  static const Color orange = Color(0xFFC2410C);
  static const Color amberDark = Color(0xFF92400E);

  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF59E0B), Color(0xFFC2410C)],
  );

  static const LinearGradient bgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFFBEB), Color(0xFFF5F5F4), Color(0xFFFFFFFF)],
  );

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: amber),
    scaffoldBackgroundColor: Colors.white,
    fontFamily: "SF Pro Display",
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: Color(0xFF292524),
    ),
  );
}

