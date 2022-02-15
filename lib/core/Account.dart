import 'package:encrypt/encrypt.dart';

class Account {
  int id;
  String accountname, username, password;

  Account.empty() {
    this.id = -1;
    this.accountname = '';
    this.username = '';
    this.password = '';
  }

  Account(this.id, this.accountname, this.username, this.password);
}


class EncryptedAccount {
  int id;
  Encrypted accountname, username, password;
  String accountnameIV, usernameIV, passwordIV;

  EncryptedAccount.empty() {
    this.id = -1;
    this.accountname = Encrypted.fromUtf8('');
    this.username = Encrypted.fromUtf8('');
    this.password = Encrypted.fromUtf8('');
    this.accountnameIV = '';
    this.usernameIV = '';
    this.passwordIV = '';
  }

  EncryptedAccount(id, accountname, username, password, accountnameIV, usernameIV, passwordIV) {
    this.id = id;
    this.accountname = Encrypted.fromBase64(accountname);
    this.username = Encrypted.fromBase64(username);
    this.password = Encrypted.fromBase64(password);
    this.accountnameIV = accountnameIV;
    this.usernameIV = usernameIV;
    this.passwordIV = passwordIV;
  }
}