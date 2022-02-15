import 'package:flutter/material.dart';
import '../general/Prefabs.dart';
import '../../core/VaultHandler.dart';
import '../general/PasswordStrengthIndicator.dart';


class ChangeMaster extends StatefulWidget {
  ChangeMaster({ Key key, @required this.vaultHandler}) : super(key: key);

  final VaultHandler vaultHandler;

  @override
  _ChangeMasterState createState() => new _ChangeMasterState();
}

class _ChangeMasterState extends State<ChangeMaster> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _confirmationFormKey = GlobalKey<FormState>();
  final GlobalKey<PasswordStrengthIndicatorState> _passwordStrengthKey = GlobalKey<PasswordStrengthIndicatorState>();

  TextEditingController _newPasswordController = TextEditingController();

  String currentPassword;
  String newPassword;
  bool _isValidPassword = true;

  bool _currentPasswordVisible = false;
  bool _newPasswordVisible = false;

  @override
  void initState() {
    _newPasswordController.addListener(() {
      _passwordStrengthKey.currentState.onPasswordChange(_newPasswordController.text);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Change master password')),
      ),
      body: mBody(),
    );
  }

  Widget mBody() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints viewportConstraints) {
        return  SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: viewportConstraints.maxHeight,
            ),
            child: Form(
              key: _formKey,
              child: Container(
                padding: EdgeInsets.fromLTRB(50.0, 30.0, 50.0, 30.0),
                decoration: BoxDecoration(
                  gradient: gradientBackground(context)
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text('To change your master password, please enter your current master password and a new one.')
                    ),
                    Container(
                      height: 120.0,
                      child: TextFormField(
                        decoration: InputDecoration(
                          icon: Icon(Icons.vpn_key),
                          labelText: 'Current master password',
                          helperText: "Enter your current password to confirm it's you",
                          suffixIcon: IconButton(
                            icon: _currentPasswordVisible ? Icon(Icons.visibility) : Icon(Icons.visibility_off),
                            onPressed: _toggleCurrentPasswordVisibility,
                          ),
                        ),
                        obscureText: !_currentPasswordVisible,
                        onSaved: (String currentPass) { currentPassword = currentPass; },
                        validator: _validatePassword,
                      ),
                    ),  
                    Container(
                      height: 120.0,
                      child: TextFormField(
                        controller: _newPasswordController,
                        decoration: InputDecoration(
                          icon: Icon(Icons.vpn_key),
                          labelText: 'New master password',
                          helperText: "Enter your new masterpassword",
                          suffixIcon: IconButton(
                            icon: _newPasswordVisible ? Icon(Icons.visibility) : Icon(Icons.visibility_off),
                            onPressed: _toggleNewPasswordVisibility,
                          ),
                        ),
                        obscureText: !_newPasswordVisible,
                        onSaved: (String newPass) { newPassword = newPass; },
                        validator: _validatePassword,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        PasswordStrengthIndicator(
                          key: _passwordStrengthKey,
                          initialPassword: '',
                        )
                      ]
                    ),
                    Container(
                      height: 60.0,
                      child: FloatingActionButton(
                        child: Icon(Icons.save),
                        heroTag: 'change_masterpassword',
                        elevation: 5.0,
                        onPressed: () {
                          _changeMasterPassword();
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

  _toggleCurrentPasswordVisibility() {
    setState(() {
      _currentPasswordVisible = !_currentPasswordVisible;
    });
  }
  _toggleNewPasswordVisibility() {
    setState(() {
      _newPasswordVisible = !_newPasswordVisible;
    });
  }

  _changeMasterPassword() async {
    final FormState form = _formKey.currentState;
    if (form.validate()) {
      form.save();

      FocusScope.of(context).requestFocus(new FocusNode());

      bool isValid = await widget.vaultHandler.testPasswordValid(currentPassword);
      if (isValid) {
        setState(() {
          _isValidPassword = true;
        });
        bool accepted = false;
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
                    final FormState confirmationForm =_confirmationFormKey.currentState;
                    if (confirmationForm.validate()) {
                      accepted = true;
                      Navigator.of(context).pop();
                    }
                  },
                )
              ],
              content: Form(
                key: _confirmationFormKey,
                child: TextFormField(
                  decoration: InputDecoration(
                    helperText: 'Type it again'
                  ),
                  maxLength: 64,
                  obscureText: true,
                  validator: (value) {
                    if (value != newPassword) {
                      return "Passwords don't match";
                    }
                    return null;
                  },
                ),
              ),
              title: Text('Confirm password'),
            );
          }
        );
        if (accepted) {
          showLoadingSpinner(context, 'Changing password');
          widget.vaultHandler.changeMasterPassword(newPassword).then((_) {
            Navigator.pop(context);
            Navigator.pop(context);
          });
        }
      } else {
        setState(() {
          _isValidPassword = false;
        });
      }
      form.validate();
    }

  }
}

