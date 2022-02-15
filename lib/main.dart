import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:scoped_model/scoped_model.dart';
import 'core/NCryptModel.dart';

import 'core/NCrypt.dart';
import 'core/DbHandler.dart';

// for development
import 'package:flutter/rendering.dart';
import 'core/Constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //debugPaintSizeEnabled=true;
  // debugPaintPointersEnabled = true;
  String themeString = DARK_THEME;
  bool hideLockDialog = false;

  /////
  // Initialize or retrieve settings
  /////
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isFirstUse = prefs.getBool(PREF_FIRST_USE);
  // isFirstUse = null;
  if (isFirstUse == null) {
    isFirstUse = true;
    prefs.setString(PREF_THEME, DARK_THEME);
    prefs.setBool(PREF_FIRST_USE, true);
    prefs.setBool(PREF_HIDELOCKDIALOG, false);
  } 
  else {
    if (isFirstUse) { // For after app reset
      prefs.setString(PREF_THEME, DARK_THEME);
      prefs.setBool(PREF_FIRST_USE, true);
      prefs.setBool(PREF_HIDELOCKDIALOG, false);
    } else {
      themeString = prefs.getString(PREF_THEME);
      hideLockDialog = prefs.getBool(PREF_HIDELOCKDIALOG);
    }
  }
  
  /////
  // Run App
  /////
  NCryptModel nCryptModel = new NCryptModel(isFirstUse, hideLockDialog, [], []);
  await nCryptModel.init();

  runApp(ScopedModel(
    model: nCryptModel,
    child: NCrypt(
      themeString: themeString
  )));
}