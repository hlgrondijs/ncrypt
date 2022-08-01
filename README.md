# nCrypt

## Project description

A password manager for personal use on smartphones, written in Dart with Flutter and other packages. The app does not use any cloud or back-up systems, but instead relies on the user to remember their master password and safeguard their device. This is similar to a "hardware wallet". 

The user chooses a master password that will be used as the encryption key for their secrets. All data stored on disk is encrypted using the Advanced Encryption Standard and is only decrypted at runtime using the master password. Because of this, any data stored is highly secure and can **never** be recovered without the master password.

## Developer notes

### Run

1. Install flutter. `snap install flutter --classic`
2. Make `flutter doctor` output green checkmarks.
3. Launch Android emulator.
2. Call `flutter run`.

### Unit Tests

`flutter test test/ -r expanded`

### Integration tests

With a Android emulator running: `flutter run integration_test/app_test.dart`