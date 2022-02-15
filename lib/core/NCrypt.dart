import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'NCryptModel.dart';
import '../ui/general/VaultDoor.dart';
import '../ui/general/Theme.dart';
import 'Constants.dart';

class NCrypt extends StatefulWidget {
  NCrypt({Key key, @required this.themeString}) : super(key: key);

  final String themeString;

  @override
  NCryptState createState() => new NCryptState();
}

class NCryptState extends State<NCrypt> {
  String selectedTheme;
  bool hideLockDialog;
  NcryptThemes ncryptThemes;

  @override
  void initState() {   
    super.initState();
    selectedTheme = widget.themeString;
    ncryptThemes = NcryptThemes();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<NCryptModel>(
      builder: (context, child, model) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'nCrypt',
          theme: ncryptThemes.getTheme(selectedTheme),
          home: VaultDoor(),
        );
      }
    );
  }

  changeTheme(String theme) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    setState((){
      selectedTheme = theme;
      sharedPreferences.setString(PREF_THEME, theme);
    });
  }
}
