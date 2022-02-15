import 'package:flutter/material.dart';

import '../../core/Constants.dart';
import 'package:enum_to_string/enum_to_string.dart';

Color neonGreenColor = Color(0xFF39FF14);




class NcryptThemes {
  final ThemeData ncryptThemeData = new ThemeData(
    brightness: Brightness.dark,
    errorColor: Colors.redAccent,

    primaryColor: Color(0xFF061E22),
    primaryColorDark: Color(0xFF061E22),
    primaryColorLight: Color(0xFF063942),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF061E22),
      foregroundColor: Colors.white
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        primary: Color(0xFF061E22),
        onPrimary: Colors.white,
        padding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0)
      )
    ),

    secondaryHeaderColor: Colors.white,     
    dividerColor: Colors.white,
    shadowColor: Colors.black,
    colorScheme: ColorScheme.fromSwatch(brightness: Brightness.dark).copyWith(
      primary: Colors.cyan,
      secondary: Colors.grey[200],
      surface: Colors.black38
    )
  );

  final ThemeData lightThemeData = new ThemeData(
    brightness: Brightness.light,
    errorColor: Colors.redAccent,

    primaryColor: Colors.cyan[150],
    primaryColorDark: Color(0xFF2e2edff),
    // primaryColorLight: Color.fromRGBO(187, 222, 251, 1.0),
    primaryColorLight: Color(0xFF2e2edff),

    disabledColor: Colors.grey,

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      foregroundColor: Colors.blue,
      splashColor: Colors.blue,
      backgroundColor: Colors.white,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        primary: Colors.white,
        onPrimary: Colors.blue,
        padding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0)
      )
    ),

    secondaryHeaderColor: Colors.black,

    dividerColor: Colors.white,
    shadowColor: Colors.black,
    colorScheme: ColorScheme.fromSwatch().copyWith(
      primary: Colors.cyan[150],
      secondary: Colors.grey[800]
    )
  );


  final ThemeData neoThemeData = new ThemeData(
    brightness: Brightness.dark,
    fontFamily: 'RobotoMono',

    primaryColorDark: Colors.black,
    primaryColorLight: Colors.black,

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Colors.grey[800],
      foregroundColor: Colors.white
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        onPrimary: Colors.white,
        primary: Colors.grey[800],
        padding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0)
      )
    ),

    secondaryHeaderColor: Colors.white,
    dividerColor: Colors.white,
    shadowColor: Colors.black,
    colorScheme: ColorScheme.dark().copyWith(
      primary: Colors.grey[200],
      secondary: Colors.grey[600],
      surface: Colors.black38,
    )
  );


  ThemeData getTheme(String themeString) {
    Enum theme = EnumToString.fromString(Themes.values, themeString);
    switch(theme) { 
      case Themes.DARK_THEME: return ncryptThemeData;
      case Themes.LIGHT_THEME: return lightThemeData;
      case Themes.NEO_THEME: return neoThemeData;
      default: return ncryptThemeData;
    } 
  }
}