import 'package:flutter/material.dart';

Gradient gradientBackground(BuildContext context) {
  return LinearGradient(
    colors: [
      Theme.of(context).colorScheme.surface,
      Theme.of(context).primaryColorLight
    ],
    begin: Alignment.topCenter,
    end: Alignment(.0, 0.0),
    tileMode: TileMode.clamp,
  );
}

Gradient gradientBackgroundInverted(BuildContext context) {
  return LinearGradient(
    colors: [
      Theme.of(context).colorScheme.surface,
      Theme.of(context).primaryColorLight
    ],
    begin: Alignment.bottomCenter,
    end: Alignment(.0, 0.0),
    tileMode: TileMode.clamp,
  );
}

showLoadingSpinner(BuildContext context, String text) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        child: Container(
          padding: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 20.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(0.0, 0.0, 25.0, 0.0),
                child: CircularProgressIndicator(),
              ),
              Flexible(child: Text(text)),
            ],
          ),
        ),
      );
    },
  );
}

confirmationButton(onPressed) {
  return FloatingActionButton(
    child: Icon(Icons.check),
    elevation: 5.0,
    onPressed: () {
      onPressed();
    },
  );
}
