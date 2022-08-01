import 'dart:convert';

import 'package:encrypt/encrypt.dart';
import 'package:nCrypt/core/account.dart';
import 'package:nCrypt/core/ncrypt_encryptor.dart';
import 'package:nCrypt/core/note.dart';
import 'package:pointycastle/key_derivators/api.dart';
import 'package:pointycastle/key_derivators/pbkdf2.dart';
import 'package:pointycastle/pointycastle.dart';
import 'package:test/test.dart';

void main() {
  group('nCrypt Encryptor class unit tests | ', () {
    NCryptEncryptor encryptor;
    String password = 'test_password';
    String salt = 'test_salt';

    setUp(() async {
      encryptor = await NCryptEncryptor.create(password, salt);
    });

    test('Check constructor result', () {
      expect(encryptor.cipherParameters.runtimeType, Pbkdf2Parameters);

      expect(encryptor.cipherParameters.salt, utf8.encode(salt));
      expect(encryptor.cipherParameters.iterationCount, 1000);
      expect(encryptor.cipherParameters.desiredKeyLength, 32);

      expect(encryptor.keyDerivator.runtimeType, PBKDF2KeyDerivator);
      expect(encryptor.keyDerivator.algorithmName, 'SHA-1/HMAC/PBKDF2');
      expect(encryptor.keyString,
          base64.encode(encryptor.keyDerivator.process(utf8.encode(password))));

      expect(encryptor.encrypter.runtimeType, Encrypter);
      expect(encryptor.encrypter.algo.runtimeType, AES);
    });

    test('GenerateIV generates random IV of length 16 bytes.', () async {
      IV iv = await generateIV();
      expect(iv.bytes.length, 16);
    });

    test(
        'encryptTestString returns an encrypted test string and accompanying IV.',
        () async {
      List<String> result = await encryptor.encryptTestString();
      expect(result.length, 2);
    });

    test('testPassword returns true for correct password', () async {
      List<String> testStringAndIV = await encryptor.encryptTestString();
      Map<String, String> input = {
        'test_string_encrypted': testStringAndIV[0],
        'test_string_iv': testStringAndIV[1],
      };

      bool result = await encryptor.testPassword(password, input);
      expect(result, true);
    });

    test('testPassword returns false for incorrect password', () async {
      List<String> testStringAndIV = await encryptor.encryptTestString();
      Map<String, String> input = {
        'test_string_encrypted': testStringAndIV[0],
        'test_string_iv': testStringAndIV[1],
      };

      bool result = await encryptor.testPassword('wrong_password', input);
      expect(result, false);
    });

    test(
        'encryptAccount returns EncryptedAccount and decryptAccount can decrypt it.',
        () async {
      Account account = Account(55, 'accountname', 'username', 'password');
      EncryptedAccount encryptedAccount =
          await encryptor.encryptAccount(account);
      Account decryptedAccount =
          await encryptor.decryptAccount(encryptedAccount);

      expect(account.id, decryptedAccount.id);
      expect(account.accountname, decryptedAccount.accountname);
      expect(account.username, decryptedAccount.username);
      expect(account.password, decryptedAccount.password);
    });

    test('encryptNote returns EncryptedNote and decryptNote can decrypt it.',
        () async {
      Note note = Note(55, 'title', 'content');
      EncryptedNote encryptedNote = await encryptor.encryptNote(note);
      Note decryptedNote = await encryptor.decryptNote(encryptedNote);

      expect(note.id, decryptedNote.id);
      expect(note.title, decryptedNote.title);
      expect(note.content, decryptedNote.content);
    });

    test('decryptAccountlist works for lists of encrypted accounts.', () async {
      Account account1 = Account(23, 'acc', 'user', 'pass');
      Account account2 = Account(64, 'accountn', 'usern', 'passw');

      List<EncryptedAccount> encryptedAccountList = [
        await encryptor.encryptAccount(account1),
        await encryptor.encryptAccount(account2),
      ];

      List<Account> decryptedAccountList =
          await encryptor.decryptAccountList(encryptedAccountList);

      expect(decryptedAccountList[0].id, account1.id);
      expect(decryptedAccountList[0].accountname, account1.accountname);
      expect(decryptedAccountList[0].username, account1.username);
      expect(decryptedAccountList[0].password, account1.password);

      expect(decryptedAccountList[1].id, account2.id);
      expect(decryptedAccountList[1].accountname, account2.accountname);
      expect(decryptedAccountList[1].username, account2.username);
      expect(decryptedAccountList[1].password, account2.password);
    });

    test('decryptNoteList works for lists of encrypted notes.', () async {
      Note note1 = Note(12, 'title', 'content');
      Note note2 = Note(86, 'titel', 'inhoud');

      List<EncryptedNote> encryptedNoteList = [
        await encryptor.encryptNote(note1),
        await encryptor.encryptNote(note2),
      ];

      List<Note> decryptedNoteList =
          await encryptor.decryptNoteList(encryptedNoteList);

      expect(decryptedNoteList[0].id, note1.id);
      expect(decryptedNoteList[0].title, note1.title);
      expect(decryptedNoteList[0].content, note1.content);

      expect(decryptedNoteList[1].id, note2.id);
      expect(decryptedNoteList[1].title, note2.title);
      expect(decryptedNoteList[1].content, note2.content);
    });
  });
}
