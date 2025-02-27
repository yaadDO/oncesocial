import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dark_mode.dart';
import 'light_mode.dart';

class ThemeCubit extends Cubit<ThemeData> {
  static const String _themeKey = 'isDarkMode';
  bool _isDarkMode = true; // Default to dark mode

  ThemeCubit() : super(darkMode) {
    _loadTheme(); // Load theme when cubit is initialized
  }

  bool get isDarkMode => _isDarkMode;

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _saveTheme();
    emit(_isDarkMode ? darkMode : lightMode);
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    // If no preference is found, default to dark mode (true)
    _isDarkMode = prefs.getBool(_themeKey) ?? true;
    emit(_isDarkMode ? darkMode : lightMode);
  }

  Future<void> _saveTheme() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, _isDarkMode);
  }
}

