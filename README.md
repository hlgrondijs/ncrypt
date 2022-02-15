# nCrypt

A password manager for personal use on smartphones, written in Dart with Flutter and other packages. The idea behind the application is to not use any cloud or back-up systems, but instead rely on the user to remember their master password and safeguard their device. This is similar to a "hardware wallet". 

The user chooses a master password that will be used as the encryption key for their secrets. All data stored on disk is encrypted and is only decrypted at runtime using the master password. Because of this, any data stored is highly secure and can **never** be recovered without the master password.

## About

I published the source code of the app so that it can be confirmed to be secure and to show I am not hiding any secrets.