import 'package:flutter/material.dart';

import '../../core/account.dart';
import '../general/Prefabs.dart';
import '../../core/constants.dart';
import '../../core/vault_handler.dart';

import '../general/PasswordStrengthIndicator.dart';

class NewAccount extends StatefulWidget {
  NewAccount({Key key, @required this.vaultHandler}) : super(key: key);

  final VaultHandler vaultHandler;

  @override
  _NewAccountState createState() => _NewAccountState();
}

class _NewAccountState extends State<NewAccount> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<PasswordStrengthIndicatorState> _passwordStrengthKey =
      GlobalKey<PasswordStrengthIndicatorState>();

  TextEditingController _passwordController;
  Account newAccount = new Account(-1, '', '', '');

  bool _passwordVisible = false;

  @override
  void initState() {
    _passwordController = new TextEditingController();
    _passwordController.addListener(() {
      _passwordStrengthKey.currentState
          .onPasswordChange(_passwordController.text);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('New account')),
      body: body(),
    );
  }

  Widget body() {
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
                padding: EdgeInsets.fromLTRB(25.0, 10.0, 25.0, 30.0),
                decoration: BoxDecoration(
                  gradient: gradientBackground(context),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Text('Store a new account using the form below.'),
                    Container(
                      child: TextFormField(
                        decoration: InputDecoration(
                          icon: Icon(Icons.public),
                          labelText: 'Accountname',
                          helperText: 'The name of the service or app',
                        ),
                        maxLength: MAX_ACCOUNTNAME_LENGTH,
                        keyboardType: TextInputType.text,
                        onSaved: (String accountname) {
                          newAccount.accountname = accountname;
                        },
                      ),
                    ),
                    Container(
                      child: TextFormField(
                        decoration: InputDecoration(
                            icon: Icon(Icons.account_box),
                            labelText: 'Username',
                            helperText: 'Your username'),
                        maxLength: MAX_USERNAME_LENGTH,
                        keyboardType: TextInputType.emailAddress,
                        onSaved: (String username) {
                          newAccount.username = username;
                        },
                      ),
                    ),
                    Container(
                      child: TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          icon: Icon(Icons.vpn_key),
                          labelText: 'Password',
                          helperText: 'Your password',
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
                        maxLength: MAX_PASSWORD_LENGTH,
                        obscureText: !_passwordVisible,
                        keyboardType: TextInputType.visiblePassword,
                        onSaved: (String password) {
                          newAccount.password = password;
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        PasswordStrengthIndicator(
                          key: _passwordStrengthKey,
                          initialPassword: '',
                        )
                      ],
                    ),
                    Container(
                      child: FloatingActionButton(
                        child: Icon(Icons.check),
                        elevation: 5.0,
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
      },
    );
  }

  storeAccount() {
    final FormState form = _formKey.currentState;
    form.save();

    widget.vaultHandler.addAccount(newAccount).then((id) {
      Navigator.pop(context, id);
    });
  }
}
