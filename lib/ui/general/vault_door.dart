import 'package:flutter/material.dart';

import 'package:scoped_model/scoped_model.dart';
import '../../core/ncrypt_model.dart';

import 'Unlock.dart';
import 'SetupPassword.dart';
import 'Prefabs.dart';
import 'Landing.dart';

class VaultDoor extends StatefulWidget {
  @override
  _VaultDoorState createState() => new _VaultDoorState();
}

class _VaultDoorState extends State<VaultDoor> {
  bool _showHelp = true;

  @override
  Widget build(BuildContext context) {
    Widget child;
    bool isFirstUse = ScopedModel.of<NCryptModel>(context).firstUse;

    if (isFirstUse && _showHelp) {
      child = Landing(
        onSubmit: () {
          setState(() {
            _showHelp = false;
          });
        },
      );
    }
    if (isFirstUse && !_showHelp) {
      child = ScopedModelDescendant<NCryptModel>(
        builder: (context, _, model) => SetupPassword(
          vaultHandler: model.vaultHandler,
          onSubmit: () async {
            await model.toggleFirstUse();
            setState(() {
              isFirstUse = model.firstUse;
            });
          },
        ),
      );
    }

    if (!isFirstUse) {
      child = ScopedModelDescendant<NCryptModel>(
          builder: (context, _, model) => Unlock(
              lockVault: model.lockVault, vaultHandler: model.vaultHandler));
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Container(
            padding: EdgeInsets.all(30.0),
            decoration: BoxDecoration(gradient: gradientBackground(context)),
            child: child,
          ),
        ),
      ),
    );
  }
}
