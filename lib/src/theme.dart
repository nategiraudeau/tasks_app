import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tasks_app/src/android_ripple.dart';
import 'package:tasks_app/src/ios_ripple.dart';

class AppTheme {
  static final Color mainColor = Colors.greenAccent[400];

  static final MaterialColor inProgress = Colors.blue;

  static final Color incomplete = Colors.redAccent[400];

  static final themeData = ThemeData(
    fontFamily: 'Gellix',
    scaffoldBackgroundColor: Colors.white,
    backgroundColor: Colors.white,
    appBarTheme: AppBarTheme(
      elevation: 0.0,
      color: Colors.white70,
      centerTitle: true,
      textTheme: TextTheme(
        headline6: TextStyle(
          fontFamily: 'Gellix',
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
          fontSize: 24,
          color: Colors.black,
        ),
      ),
    ),
    textTheme: TextTheme(
      headline2: TextStyle(
        fontWeight: FontWeight.w800,
      ),
      headline3: TextStyle(
        fontWeight: FontWeight.w700,
        letterSpacing: 0.17,
      ),
      headline4: TextStyle(
        fontWeight: FontWeight.w700,
        letterSpacing: 0.13,
      ),
      headline5: TextStyle(
        fontWeight: FontWeight.w700,
        letterSpacing: 0.1,
      ),
      headline6: TextStyle(
        fontWeight: FontWeight.w600,
      ),
      subtitle1: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 19,
      ),
      subtitle2: TextStyle(
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
        fontSize: 14,
      ),
      bodyText1: TextStyle(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        fontSize: 15,
      ),
    ),
    splashFactory: Platform.isAndroid
        ? AndroidRipple.splashFactory
        : IOSRipple.splashFactory,
    dividerTheme: DividerThemeData(
      color: Colors.black.withOpacity(0.05),
      thickness: 2,
    ),
    cardTheme: CardTheme(
      elevation: 50,
      clipBehavior: Clip.antiAlias,
      shadowColor: Colors.black38.withBlue(50),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      margin: EdgeInsets.zero,
    ),
    primarySwatch: Colors.grey,
    primaryColor: Colors.greenAccent[400],
    disabledColor: Colors.blueGrey[900].withGreen(100),
    highlightColor: Colors.transparent,
  );

  static final dark1 = Color(0xff131517);
  static final dark2 = Color(0xff222529);

  static final darkThemeData = ThemeData.from(
    colorScheme: ColorScheme(
      primary: themeData.primaryColor,
      primaryVariant: Color(0xff00d46d),
      onPrimary: Colors.white,
      secondary: Colors.white,
      secondaryVariant: Colors.grey[100],
      onSecondary: Colors.black,
      background: dark1,
      onBackground: Colors.white.withOpacity(0.9),
      surface: dark2,
      onSurface: Colors.white,
      error: Colors.redAccent[400],
      onError: Colors.white,
      brightness: Brightness.dark,
    ),
  ).copyWith(
    textTheme: themeData.textTheme.copyWith(),
    cardTheme: themeData.cardTheme.copyWith(
      color: dark2,
      elevation: 0.0,
    ),
    primaryColor: mainColor,
    dividerTheme: themeData.dividerTheme.copyWith(
      color: Colors.white.withOpacity(0.03),
    ),
    splashFactory: Platform.isAndroid
        ? AndroidRipple.splashFactory
        : IOSRipple.splashFactory,
    highlightColor: Colors.transparent,
    appBarTheme: themeData.appBarTheme.copyWith(
      color: dark1.withOpacity(0.7),
      textTheme: themeData.appBarTheme.textTheme.copyWith(
        headline6: themeData.appBarTheme.textTheme.headline6.copyWith(
          color: Colors.white,
        ),
      ),
    ),
  );
}
