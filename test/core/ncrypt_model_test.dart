import 'package:nCrypt/core/account.dart';
import 'package:nCrypt/core/constants.dart';
import 'package:nCrypt/core/ncrypt_encryptor.dart';
import 'package:nCrypt/core/ncrypt_model.dart';
import 'package:nCrypt/core/note.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';

void main() {
  group('nCrypt model', () {
    bool firstUse = true;
    bool hideLockDialog = false;

    NCryptModel model;

    setUp(() {
      SharedPreferences.setMockInitialValues(
          {PREF_FIRST_USE: firstUse, PREF_HIDELOCKDIALOG: hideLockDialog});

      model = new NCryptModel(
        firstUse,
        hideLockDialog,
        [],
        [],
      );
    });

    test('toggleFirstUse', () async {
      await model.toggleFirstUse();

      SharedPreferences prefs = await SharedPreferences.getInstance();

      expect(model.firstUse, false);
      expect(prefs.getBool(PREF_FIRST_USE), false);
    });

    test('setHideLockDialog', () async {
      await model.setHideLockDialog(true);

      SharedPreferences prefs = await SharedPreferences.getInstance();

      expect(model.hideLockDialog, true);
      expect(prefs.getBool(PREF_HIDELOCKDIALOG), true);
    });

    test('Populate model, then lock vault', () async {
      model.nCryptEncryptor = await NCryptEncryptor.create('password', 'salt');
      expect(model.nCryptEncryptor.keyString, isNot(''));

      List<Account> accList = [
        Account(1, 'account', 'username', 'password'),
      ];
      await model.setAccountList(accList);
      expect(model.accountList.length, 1);
      List<Note> noteList = [
        Note(1, 'title', 'content'),
      ];
      await model.setNoteList(noteList);
      expect(model.noteList.length, 1);

      await model.lockVault();

      expect(model.accountList, []);
      expect(model.noteList, []);
      expect(
          model.nCryptEncryptor.keyString, model.nCryptEncryptor.deriveKey(''));
    });
  });
}
