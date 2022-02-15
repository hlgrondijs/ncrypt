import 'package:flutter/material.dart';

import '../../core/NCrypt.dart';


class LockDialog extends StatefulWidget {
  LockDialog({
    @required this.setDontShowAgainBool
  });

  final Function setDontShowAgainBool;

  _LockDialogState createState() => new _LockDialogState();
}


class _LockDialogState extends State<LockDialog> {
  bool dontShowAgain = false;
  NCryptState nCryptState;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Form(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'nCrypt will always automatically lock your vault when the app is minimized.',
              style: TextStyle(
                fontSize: 16.0
              )
            ),
            Row(
              children: [
                Text(
                  "Don't show this message again",
                  style: TextStyle(
                    fontSize: 12.0
                  ),
                ),
                Checkbox(
                  value: dontShowAgain,
                  onChanged: (val) {
                    widget.setDontShowAgainBool(val);

                    setState(() {
                      dontShowAgain = val;
                    });
                  },
                )
              ]
            )
          ]
        )
      )
    );
  }
}