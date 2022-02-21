import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import '../../core/NCryptModel.dart';
import '../../core/Constants.dart';
import '../../core/Account.dart';
import '../general/Prefabs.dart';
import '../../core/VaultHandler.dart';

import '../general/PasswordStrengthIndicator.dart';

class EditAccount extends StatefulWidget {
  const EditAccount({ Key key, @required this.account}) : super(key: key);

  final Account account;

  @override
  _EditAccountState createState() => _EditAccountState();
}

class _EditAccountState extends State<EditAccount> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<PasswordStrengthIndicatorState> _passwordStrengthKey = GlobalKey<PasswordStrengthIndicatorState>();

  TextEditingController _passwordController;
  bool _passwordVisible = false;

  @override
  void initState() {
    _passwordController = TextEditingController(text: widget.account.password);
    _passwordController.addListener(() {
      _passwordStrengthKey.currentState.onPasswordChange(_passwordController.text);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit account')
      ),
      body: mBody(),
    );
  }

    Widget mBody() {
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
                padding: EdgeInsets.fromLTRB(25.0, 0.0, 25.0, 30.0),
                decoration: BoxDecoration(
                  gradient: gradientBackground(context)   
                ),                
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget> [
                    Container(
                      // Accountname
                      child: TextFormField(
                        decoration: InputDecoration(
                          icon: Icon(Icons.public),
                          labelText: 'Accountname',
                          helperText: 'Current accountname: ' + widget.account.accountname,
                        ),
                        initialValue: widget.account.accountname,
                        maxLength: MAX_ACCOUNTNAME_LENGTH,
                        keyboardType: TextInputType.text,
                        onSaved: (String newAccountname) { widget.account.accountname = newAccountname; }
                      ),
                    ),
                    Container(
                      // Username
                      child: TextFormField(
                        decoration: InputDecoration(
                          icon: Icon(Icons.account_box),
                          labelText: 'Username',
                          helperText: 'Current username: ' + widget.account.username,
                        ),
                        initialValue: widget.account.username,
                        maxLength: MAX_USERNAME_LENGTH,
                        keyboardType: TextInputType.emailAddress,
                        onSaved: (String newUsername) { widget.account.username = newUsername; }
                      ),
                    ),
                    Container(
                      // Password
                      child: TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          icon: Icon(Icons.vpn_key),
                          labelText: 'Password',
                          helperText: 'Current password: ' + widget.account.password,
                          suffixIcon: IconButton(
                            icon: _passwordVisible ? Icon(Icons.visibility) : Icon(Icons.visibility_off),
                            onPressed: () {
                              setState(() {
                                _passwordVisible = !_passwordVisible;
                              });
                            },
                          ),
                        ),
                        maxLength: MAX_PASSWORD_LENGTH,
                        obscureText: !_passwordVisible,
                        keyboardType: TextInputType.visiblePassword,
                        onSaved: (String newPassword) { widget.account.password = newPassword; }
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        PasswordStrengthIndicator(
                          key: _passwordStrengthKey,
                          initialPassword: widget.account.password,
                        )
                      ],
                    ),
                    Container(
                      // Save button
                      child: FloatingActionButton(
                        child: Icon(Icons.check),
                        elevation: 5.0,
                        heroTag: 'edit_account_save',
                        onPressed: () {
                          storeAccount();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    );
  }

  storeAccount() {
    final FormState form = _formKey.currentState;
    form.save();

    VaultHandler vaultHandler =ScopedModel.of<NCryptModel>(context).vaultHandler;
    vaultHandler.updateAccount(widget.account).then((_) {
      vaultHandler.getNotesAndDecrypt().then((nList) {
        ScopedModel.of<NCryptModel>(context).setNoteList(nList);
      });
      Navigator.pop(context);
    });
  }
}