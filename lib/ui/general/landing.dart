import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

typedef void Callback();

class Landing extends StatefulWidget {
  Landing({Key key, this.onSubmit}) : super(key: key);

  final Callback onSubmit;

  Key key = Key('LandingWidget');

  _LandingState createState() => new _LandingState();
}

class _LandingState extends State<Landing> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints viewportConstraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: viewportConstraints.maxHeight,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        child: Icon(
                          MdiIcons.cellphoneKey,
                          size: 50.0,
                        ),
                      ),
                      Container(
                        child: Text(
                          'NCRYPT',
                          style: TextStyle(fontSize: 24.0),
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  child: Text(
                    'nCrypt is a place to store your secrets, such as passwords and personal notes, in a secure and easy way.',
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                  child: Row(
                    children: [
                      Container(
                        child: Icon(Icons.warning),
                        margin: EdgeInsets.fromLTRB(0.0, 0.0, 15.0, 0.0),
                      ),
                      Flexible(
                        child: Text(
                          'For security & privacy reasons, your master password is not recoverable!',
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  child: Row(
                    children: [
                      Container(
                        child: Icon(Icons.warning),
                        margin: EdgeInsets.fromLTRB(0.0, 0.0, 15.0, 0.0),
                      ),
                      Flexible(
                        child: Text(
                          'When you lose your device, your passwords are also lost!',
                          // ' Use the backup function to mitigate this.'
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  child: Row(
                    children: [
                      Container(
                        child: Icon(Icons.warning),
                        margin: EdgeInsets.fromLTRB(0.0, 0.0, 15.0, 0.0),
                      ),
                      Flexible(
                        child: Text(
                          'nCrypt will automatically lock when you minimize the app',
                          // ' Use the backup function to mitigate this.'
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  height: 15.0,
                ),
                Container(
                  child: Row(
                    children: [
                      Container(
                        child: Icon(Icons.add),
                        margin: EdgeInsets.fromLTRB(0.0, 0.0, 15.0, 0.0),
                      ),
                      Flexible(
                        child: Text(
                          'Use the plus-icon to add a new account or note.',
                          style: TextStyle(fontSize: 12.0),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  child: Row(
                    children: [
                      Container(
                        child: Icon(Icons.search),
                        margin: EdgeInsets.fromLTRB(0.0, 0.0, 15.0, 0.0),
                      ),
                      Flexible(
                        child: Text(
                          'Use this icon to filter accounts or notes',
                          style: TextStyle(fontSize: 12.0),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  child: Row(
                    children: [
                      Container(
                        child: Icon(Icons.account_box),
                        margin: EdgeInsets.fromLTRB(0.0, 0.0, 15.0, 0.0),
                      ),
                      Flexible(
                        child: Text(
                          'Use this icon to access your accounts',
                          style: TextStyle(fontSize: 12.0),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  child: Row(
                    children: [
                      Container(
                        child: Icon(Icons.note),
                        margin: EdgeInsets.fromLTRB(0.0, 0.0, 15.0, 0.0),
                      ),
                      Flexible(
                        child: Text(
                          'Use this icon to access your notes',
                          style: TextStyle(fontSize: 12.0),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  child: Row(
                    children: [
                      Container(
                        child: Icon(Icons.settings),
                        margin: EdgeInsets.fromLTRB(0.0, 0.0, 15.0, 0.0),
                      ),
                      Flexible(
                        child: Text(
                          'Use this icon to access settings',
                          style: TextStyle(fontSize: 12.0),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  child: Row(
                    children: [
                      Container(
                        child: Icon(Icons.lock),
                        margin: EdgeInsets.fromLTRB(0.0, 0.0, 15.0, 0.0),
                      ),
                      Flexible(
                        child: Text(
                          'Use this icon to lock nCrypt',
                          style: TextStyle(fontSize: 12.0),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  height: 15.0,
                ),
                Container(
                  child: Row(
                    children: [
                      Container(
                        child: Icon(Icons.drag_handle),
                        margin: EdgeInsets.fromLTRB(0.0, 0.0, 15.0, 0.0),
                      ),
                      Flexible(
                        child: Text(
                          'Tap and hold then drag an item to change the order of your list',
                          style: TextStyle(fontSize: 12.0),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                  child: FloatingActionButton(
                    key: Key('LandingOKFAB'),
                    onPressed: () {
                      widget.onSubmit();
                    },
                    child: Text('OK'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
