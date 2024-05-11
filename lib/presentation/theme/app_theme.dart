import 'package:flutter/material.dart';

class AppTheme {

  static AppTheme? instance;

  AppTheme._();

  factory AppTheme() {
    return instance ??= AppTheme._();
  }

  Color get purple => const Color(0xFF220941);
}