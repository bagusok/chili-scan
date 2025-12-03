import 'package:chili_scan_app/common/constants/colors.dart';
import 'package:flutter/material.dart';

final themeLight = ThemeData.light().copyWith(
  scaffoldBackgroundColor: backgroundColor,
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.white,
    elevation: 0,
    iconTheme: const IconThemeData(color: Colors.black),
  ),
);
