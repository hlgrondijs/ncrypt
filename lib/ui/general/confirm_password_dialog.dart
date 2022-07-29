import 'package:flutter/material.dart';

class ConfirmPasswordDialog extends StatefulWidget {
  ConfirmPasswordDialog({
    @required this.confirmationFormKey,
    @required this.masterPassInput,
  });

  final GlobalKey<FormState> confirmationFormKey;
  final String masterPassInput;

  _ConfirmPasswordDialogState createState() =>
      new _ConfirmPasswordDialogState();
}

class _ConfirmPasswordDialogState extends State<ConfirmPasswordDialog> {
  bool _passwordConfirmVisible = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Form(
        key: widget.confirmationFormKey,
        child: TextFormField(
          key: Key('ConfirmMasterPasswordFormField'),
          decoration: InputDecoration(
            helperText: 'Type it again',
            suffixIcon: IconButton(
              icon: _passwordConfirmVisible
                  ? Icon(Icons.visibility)
                  : Icon(Icons.visibility_off),
              onPressed: () {
                setState(() {
                  _passwordConfirmVisible = !_passwordConfirmVisible;
                });
              },
            ),
          ),
          maxLength: 64,
          obscureText: !_passwordConfirmVisible,
          keyboardType: TextInputType.visiblePassword,
          validator: (value) {
            if (value != widget.masterPassInput) {
              return "Passwords don't match";
            }
            return null;
          },
        ),
      ),
    );
  }
}
