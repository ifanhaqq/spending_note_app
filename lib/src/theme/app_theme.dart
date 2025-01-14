import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme => ThemeData(
        primarySwatch: Colors.grey,
        scaffoldBackgroundColor: const Color(0XFF3C3D37),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0XFF1E201E),
          foregroundColor: Color(0XFFECDFCC),
        ),
        textTheme: const TextTheme(
            bodyMedium: TextStyle(fontSize: 16, color: Colors.white)),
      );
}
