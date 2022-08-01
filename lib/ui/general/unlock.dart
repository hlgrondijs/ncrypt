import 'dart:async';

import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'package:scoped_model/scoped_model.dart';

import 'vault.dart';
import '../../core/vault_handler.dart';
import '../../core/ncrypt_model.dart';

import '../../core/account.dart';
import '../../core/note.dart';
import 'prefabs.dart';

typedef void Callback();

class Unlock extends StatefulWidget {
  Unlock({
    Key key,
    this.vaultHandler,
    this.lockVault,
  }) : super(key: key);

  final VaultHandler vaultHandler;
  final Callback lockVault;

  _UnlockState createState() => new _UnlockState();
}

class _UnlockState extends State<Unlock> {
  final _formKey = GlobalKey<FormState>();
  bool _passwordVisible = false;

  bool _isValidPassword = true;
  String masterPassword = '';

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints viewportConstraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: viewportConstraints.maxHeight,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 0.0),
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
                  TextFormField(
                    key: Key('MasterPasswordUnlockFormField'),
                    decoration: InputDecoration(
                      helperText: 'Enter your master password to unlock nCrypt',
                      suffixIcon: IconButton(
                        icon: _passwordVisible
                            ? Icon(Icons.visibility)
                            : Icon(Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            _passwordVisible = !_passwordVisible;
                          });
                        },
                      ),
                    ),
                    obscureText: !_passwordVisible,
                    onSaved: (String password) {
                      masterPassword = password;
                    },
                    keyboardType: TextInputType.visiblePassword,
                    validator: _validatePassword,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 0.0),
                    child: FloatingActionButton(
                      key: Key('MasterPasswordUnlockFAB'),
                      child: Icon(Icons.lock_open),
                      elevation: 5.0,
                      onPressed: () {
                        _submit();
                      },
                    ),
                  ),
                  Container(
                    child: Text('v2.0.0'),
                  ),
                ],
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
      return 'Wrong password';
    }

    return null;
  }

  _submit() async {
    showLoadingSpinner(context, "Decrypting data");
    await Future.delayed(const Duration(seconds: 1), () => "1");
    final FormState form = _formKey.currentState;
    // dismiss keyboard
    FocusScope.of(context).requestFocus(new FocusNode());

    form.save();
    widget.vaultHandler.testPasswordValid(masterPassword).then((isValid) {
      if (isValid) {
        setState(() {
          _isValidPassword = true;
        });
        form.validate();

        widget.vaultHandler
            .setNCryptEncryptorParameters(masterPassword)
            .then((_) async {
          form.reset();
          _passwordVisible = false;
          await _unlockVault();
        });
      } else {
        Navigator.pop(context);
        setState(() {
          _isValidPassword = false;
        });
        form.validate();
      }
    });
  }

  _unlockVault() async {
    List<Account> daccList = await widget.vaultHandler.getAccountsAndDecrypt();
    ScopedModel.of<NCryptModel>(context).setAccountList(daccList);

    List<Note> dnoteList = await widget.vaultHandler.getNotesAndDecrypt();
    ScopedModel.of<NCryptModel>(context).setNoteList(dnoteList);

    Navigator.pop(context);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScopedModelDescendant<NCryptModel>(
            builder: (context, _, model) => Vault(
                  vaultHandler: model.vaultHandler,
                )),
      ),
    ).then((exitCode) async {
      // After popping this route, clear memory!
      showLoadingSpinner(context, "Clearing memory");
      await Future.delayed(const Duration(seconds: 1), () => "1");
      await ScopedModel.of<NCryptModel>(context).lockVault();
      Navigator.pop(context);
      if (exitCode == 1) {
        // vault deletion??
      }
    });
  }
}
