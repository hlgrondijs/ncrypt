import 'dart:math';

import 'package:encrypt/encrypt.dart';
import 'package:flutter/foundation.dart';
import 'package:nCrypt/core/account.dart';
import 'package:test/test.dart';

void main() {
  group('Account class | ', () {
    test('New Account instance is empty', () {
      final Account account = Account.empty();

      expect(account.id, -1);
      expect(account.accountname, '');
      expect(account.username, '');
      expect(account.password, '');
    });

    test('New EncryptedAccount is empty', () {
      final EncryptedAccount encryptedAccount = EncryptedAccount.empty();

      expect(encryptedAccount.id, -1);
      expect(encryptedAccount.accountname, Encrypted.fromBase64(''));
      expect(encryptedAccount.username, Encrypted.fromBase64(''));
      expect(encryptedAccount.password, Encrypted.fromBase64(''));
      expect(encryptedAccount.accountnameIV, '');
      expect(encryptedAccount.usernameIV, '');
      expect(encryptedAccount.passwordIV, '');
    });
  });
}
