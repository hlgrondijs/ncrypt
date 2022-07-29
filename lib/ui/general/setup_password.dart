import 'package:flutter/material.dart';

import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../core/vault_handler.dart';
import '../../core/password_strength.dart';
import 'prefabs.dart';
import 'confirm_password_dialog.dart';

typedef void Callback();

class SetupPassword extends StatefulWidget {
  SetupPassword({this.onSubmit, this.vaultHandler});

  final Callback onSubmit;
  final VaultHandler vaultHandler;

  _SetupPasswordState createState() => new _SetupPasswordState();
}

class _SetupPasswordState extends State<SetupPassword> {
  final _formKey = GlobalKey<FormState>();
  final _confirmationFormKey = GlobalKey<FormState>();
  TextEditingController _controller = TextEditingController();

  String masterpass1;
  String masterpass2;

  bool _passwordVisible = false;

  int level = 0;
  Color strengthColor = Colors.red;
  Icon strengthIcon = Icon(MdiIcons.emoticonAngry);

  @override
  void initState() {
    _controller.addListener(onChange);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints viewportConstraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: viewportConstraints.maxHeight,
            ),
            child: Container(
              padding: EdgeInsets.fromLTRB(50.0, 0.0, 50.0, 0.0),
              child: body(),
            ),
          ),
        );
      },
    );
  }

  Widget body() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Row(
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
        Text(
          'Setup your master password.\n\nYour master password will be the cryptographical key to your secrets.',
          textAlign: TextAlign.center,
        ),
        Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                child: TextFormField(
                  controller: _controller,
                  decoration: InputDecoration(
                    helperText: 'Choose a master password',
                    suffixIcon: IconButton(
                      icon: _passwordVisible
                          ? Icon(Icons.visibility)
                          : Icon(Icons.visibility_off),
                      onPressed: _togglePasswordVisiblity,
                    ),
                  ),
                  maxLength: 64,
                  obscureText: !_passwordVisible,
                  onSaved: (String input) {
                    masterpass1 = input;
                  },
                  keyboardType: TextInputType.visiblePassword,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter a password';
                    } else {
                      return null;
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                Row(
                  children: [
                    Container(
                      margin: EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
                      child: Text(
                        'Password Strength:',
                        style: TextStyle(fontSize: 12.0),
                      ),
                    ),
                    GestureDetector(
                      child: Container(
                        margin: EdgeInsets.fromLTRB(5.0, 15.0, 0.0, 0.0),
                        child: Icon(Icons.help, size: 14.0),
                      ),
                      onTap: _showPasswordStrengthTooltip,
                    )
                  ],
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
                  child: LinearPercentIndicator(
                    width: MediaQuery.of(context).size.width / 2,
                    lineHeight: 14.0,
                    percent: level / 100,
                    center: Text(
                      level.toString() + " bits",
                      style: new TextStyle(fontSize: 12.0),
                    ),
                    trailing: strengthIcon,
                    linearStrokeCap: LinearStrokeCap.roundAll,
                    backgroundColor: Theme.of(context).primaryColor,
                    progressColor: strengthColor,
                  ),
                ),
              ],
            ),
          ],
        ),
        Container(
          child: FloatingActionButton(
            onPressed: () {
              _setupMasterPassword();
            },
            child: Text('OK'),
          ),
        ),
      ],
    );
  }

  _showPasswordStrengthTooltip() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
          content: Container(
            child: Text(
              'The Password Strength bar shows how many estimated bits of entropy your password has. It should be as high as possible.\n\n'
              'Try to aim for 70 bits or higher to make your password hard to guess.',
              style: TextStyle(fontSize: 12.0),
            ),
          ),
        );
      },
    );
  }

  _togglePasswordVisiblity() {
    setState(() {
      _passwordVisible = !_passwordVisible;
    });
  }

  _setupMasterPassword() async {
    bool accepted = false;
    final FormState formState = _formKey.currentState;
    if (!formState.validate()) {
      return;
    }
    formState.save();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          actions: [
            TextButton(
              child: Text('Decline'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Accept'),
              onPressed: () {
                //Validate
                final FormState form = _confirmationFormKey.currentState;
                if (form.validate()) {
                  accepted = true;
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
          content: ConfirmPasswordDialog(
            confirmationFormKey: _confirmationFormKey,
            masterPassInput: masterpass1,
          ),
          title: Text('Confirm password'),
        );
      },
    );

    if (accepted) {
      showLoadingSpinner(context, 'Setting up database');
      await Future.delayed(const Duration(seconds: 1), () => "1");
      // await widget.vaultHandler.resetVault();
      widget.vaultHandler.setEncryptionKey(masterpass1).then((_) {
        Navigator.pop(context);
        widget.onSubmit();
      });
    }
  }

  onChange() {
    String pw = _controller.text;
    Entropizer entropizer = new Entropizer();
    double score = entropizer.evaluate(pw);
    int bits = score.round();
    setState(() {
      if (bits <= 24) {
        strengthColor = Colors.red;
        strengthIcon = Icon(MdiIcons.emoticonAngry);
      } else if (bits <= 45) {
        strengthColor = Colors.orange;
        strengthIcon = Icon(MdiIcons.emoticonSad);
      } else if (bits <= 67) {
        strengthColor = Colors.yellow;
        strengthIcon = Icon(MdiIcons.emoticonNeutral);
      } else if (bits <= 81) {
        strengthColor = Colors.lightGreen;
        strengthIcon = Icon(MdiIcons.emoticonHappy);
      } else {
        strengthColor = Colors.green;
        strengthIcon = Icon(MdiIcons.emoticonExcited);
      }

      if (bits > 100) {
        level = 100;
      } else {
        level = bits;
      }
    });
  }
}
