import 'package:flutter/material.dart';

class AppColors {
  // Premium Blue Theme
  static const Color primary = Color(0xFF1A73E8); // Deep Ocean Blue
  static const Color secondary = Color(0xFF4285F4); // Royal Blue
  static const Color accent = Color(0xFF00D1FF); // Neon Blue
  
  static const Color lightBackground = Color(0xFFF8FAFF);
  static const Color lightSurface = Colors.white;
  
  static const Color darkBackground = Color(0xFF0A192F);
  static const Color darkSurface = Color(0xFF112240);
  
  static const Color income = Color(0xFF00C853); // Emerald Green
  static const Color expense = Color(0xFFFF5252); // Coral Red
  
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1A73E8), Color(0xFF00D1FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient incomeGradient = LinearGradient(
    colors: [Color(0xFF00C853), Color(0xFFB2FF59)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
