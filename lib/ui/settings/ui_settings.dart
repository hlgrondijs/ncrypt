import 'package:flutter/material.dart';

import '../../core/ncrypt.dart';
import '../general/prefabs.dart';
import '../../core/constants.dart';

class UISettings extends StatefulWidget {
  @override
  _UISettingsState createState() => new _UISettingsState();
}

class _UISettingsState extends State<UISettings> {
  int _themeRadio;
  NCryptState nCryptState;

  List<Map<String, String>> themeOptions = [
    {'name': 'nCrypt', 'identifier': DARK_THEME, 'idx': '0'},
    {
      'name': 'Light',
      'identifier': LIGHT_THEME,
      'idx': '1',
    },
    {
      'name': 'Neo',
      'identifier': NEO_THEME,
      'idx': '2',
    }
  ];

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
    void _radioPressed(int value) => _changeTheme(value, context);

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
                      ...themeOptions.map((option) {
                        return Container(
                          child: Row(
                            children: [
                              Radio(
                                value: int.parse(option['idx']),
                                groupValue: _themeRadio,
                                onChanged: _radioPressed,
                              ),
                              Text(option['name']),
                            ],
                          ),
                        );
                      }),
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

    String theme = themeOptions[themeIdx]['identifier'];
    nCryptState.changeTheme(theme);
  }
}
