import 'package:flutter/material.dart';

import 'package:scoped_model/scoped_model.dart';
import '../../core/ncrypt_model.dart';
import '../../core/vault_handler.dart';

import '../general/Prefabs.dart';
import '../../core/ncrypt.dart';

class ResetVault extends StatefulWidget {
  const ResetVault({
    Key key,
  }) : super(key: key);

  @override
  _ResetVaultState createState() => _ResetVaultState();
}

class _ResetVaultState extends State<ResetVault> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String currentMasterpassword;
  bool _isValidPassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Reset vault')),
      body: resetVaultBody(),
    );
  }

  Widget resetVaultBody() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints viewportConstraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: viewportConstraints.maxHeight,
            ),
            child: Form(
              key: _formKey,
              child: Container(
                padding: EdgeInsets.fromLTRB(50.0, 30.0, 50.0, 30.0),
                decoration: BoxDecoration(
                  gradient: gradientBackground(context),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Container(
                      child: Text(
                        'This will reset the vault to its default settings. Any data stored on this device will be lost!',
                        style: TextStyle(
                          fontSize: 12.0,
                        ),
                      ),
                    ),
                    Container(
                      child: TextFormField(
                        decoration: InputDecoration(
                            icon: Icon(Icons.vpn_key),
                            labelText: 'Current master password',
                            helperText:
                                'Enter your current master password to confirm the vault reset'),
                        keyboardType: TextInputType.visiblePassword,
                        onSaved: (String currMpass) {
                          currentMasterpassword = currMpass;
                        },
                        validator: _validatePassword,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
                      child: FloatingActionButton(
                        child: Icon(Icons.delete),
                        elevation: 5.0,
                        onPressed: () {
                          _resetVault();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _validatePassword(String password) {
    if (password.isEmpty) {
      return 'Please enter a password';
    }

    if (!_isValidPassword) {
      _isValidPassword = true;
      return 'Wrong password';
    }

    return null;
  }

  _resetVault() {
    final FormState form = _formKey.currentState;
    form.save();
    FocusScope.of(context).requestFocus(new FocusNode());
    if (form.validate()) {
      VaultHandler vaultHandler =
          ScopedModel.of<NCryptModel>(context).vaultHandler;
      if (vaultHandler.nCryptEncryptor.masterPassword ==
          currentMasterpassword) {
        vaultHandler.resetVault().then((_) async {
          await ScopedModel.of<NCryptModel>(context).toggleFirstUse();
          await ScopedModel.of<NCryptModel>(context).init();

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
                content: Text('Your vault has been reset. '
                    'You will now be redirected the password setup screen.'),
              );
            },
          );

          Navigator.pop(context, true);
        });
      } else {
        setState(() {
          _isValidPassword = false;
        });
      }
      form.validate();
    }
  }
}
