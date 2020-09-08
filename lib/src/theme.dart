import 'package:flutter/material.dart';

class AppTheme {
  static final Color mainColor = Colors.greenAccent[400];

  static final MaterialColor inProgress = Colors.blue;

  static final Color incomplete = Colors.redAccent[400];

  static final themeData = ThemeData(
    fontFamily: 'Gellix',
    scaffoldBackgroundColor: Colors.white,
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
    splashFactory: InkRipple.splashFactory,
    primarySwatch: Colors.grey,
    primaryColor: Colors.greenAccent[400],
    disabledColor: Colors.blueGrey[900].withGreen(100),
  );
}
