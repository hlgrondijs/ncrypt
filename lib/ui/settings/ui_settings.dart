import 'package:flutter/material.dart';

import '../../core/ncrypt.dart';
import '../general/Prefabs.dart';
import '../../core/constants.dart';

class UISettings extends StatefulWidget {
  @override
  _UISettingsState createState() => new _UISettingsState();
}

class _UISettingsState extends State<UISettings> {
  int _themeRadio;
  NCryptState nCryptState;

  @override
  void initState() {
    super.initState();
    nCryptState = context.findAncestorStateOfType<NCryptState>();
    if (nCryptState.selectedTheme == DARK_THEME) {
      _themeRadio = 0;
    }
    if (nCryptState.selectedTheme == LIGHT_THEME) {
      _themeRadio = 1;
    }
    if (nCryptState.selectedTheme == NEO_THEME) {
      _themeRadio = 2;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('UI Settings')),
      body: Container(
        decoration: BoxDecoration(
          gradient: gradientBackground(context),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(30.0),
              child: Column(
                children: [
                  Text('Select a theme', style: TextStyle(fontSize: 20)),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        child: Row(
                          children: [
                            Radio(
                              value: 0,
                              groupValue: _themeRadio,
                              onChanged: (int value) {
                                _changeTheme(value, context);
                              },
                            ),
                            Text('nCrypt'),
                          ],
                        ),
                      ),
                      Container(
                        child: Row(
                          children: [
                            Radio(
                              value: 1,
                              groupValue: _themeRadio,
                              onChanged: (int value) {
                                _changeTheme(value, context);
                              },
                            ),
                            Text('Light'),
                          ],
                        ),
                      ),
                      Container(
                        child: Row(
                          children: [
                            Radio(
                              value: 2,
                              groupValue: _themeRadio,
                              onChanged: (int value) {
                                _changeTheme(value, context);
                              },
                            ),
                            Text('Neo'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _changeTheme(int themeIdx, BuildContext context) {
    setState(() {
      _themeRadio = themeIdx;
    });
    nCryptState = context.findAncestorStateOfType<NCryptState>();

    String theme = [DARK_THEME, LIGHT_THEME, NEO_THEME][themeIdx];
    nCryptState.changeTheme(theme);
  }
}
