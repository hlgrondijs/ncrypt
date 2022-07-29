import 'package:encrypt/encrypt.dart';
import 'package:pointycastle/pointycastle.dart';

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'account.dart';
import 'note.dart';

class NcryptEncryptor {
  String masterPassword;
  String keyString;

  Encrypter encrypter;
  KeyDerivator keyDerivator = new KeyDerivator("SHA-1/HMAC/PBKDF2");
  Pbkdf2Parameters cipherParameters;

  NcryptEncryptor(String password, String salt) {
    masterPassword = password;

    List<int> saltBytes = utf8.encode(salt);
    cipherParameters = new Pbkdf2Parameters(saltBytes, 1000, 32);
    keyDerivator.init(cipherParameters);

    keyString = base64KeyFromPassword(password);
    encrypter = Encrypter(AES(Key.fromBase64(keyString)));
  }

  Future<IV> generateIV() async {
    final Random rng = new Random.secure();
    Uint8List ivUint8List = Uint8List(16);
    for (var i = 0; i < 16; i++) {
      ivUint8List[i] = rng.nextInt(255);
    }
    return IV(ivUint8List);
  }

  String base64KeyFromPassword(String password) {
    List<int> passwordBytes = utf8.encode(password);
    List<int> keyBytes = keyDerivator.process(passwordBytes);
    return base64.encode(keyBytes);
  }

  setKeyString(String password) async {
    masterPassword = password;
    keyString = base64KeyFromPassword(password);
    encrypter = Encrypter(AES(Key.fromBase64(keyString)));
  }

  Future<List<String>> encryptTestString() async {
    // Encrypt the "test_string" used for unlocking the vault (checking master password).
    IV iv = await generateIV();
    String encryptedTestString =
        encrypter.encrypt('secret test string', iv: iv).base64;
    return [encryptedTestString, iv.base64];
  }

  Future<bool> testPassword(
      Map<String, dynamic> testStringIV, String testedPassword) async {
    // During unlock the master password is tested by trying to decrypt the "test_string". If the password is valid, decrypted value should read 'secret test string'.
    String testedKeyString = base64KeyFromPassword(testedPassword);
    Encrypter testEncrypter = Encrypter(AES(Key.fromBase64(testedKeyString)));
    IV iv = IV.fromBase64(testStringIV["test_string_iv"]);

    String testString;
    try {
      testString = testEncrypter.decrypt(
          Encrypted.fromBase64(testStringIV["test_string_encrypted"]),
          iv: iv);
    } catch (e) {
      return false;
    }

    if (testString == 'secret test string') {
      return true;
    }
    return false;
  }

  Future<Account> decryptAccount(EncryptedAccount encryptedAccount) async {
    IV accountNameIV = IV.fromBase64(encryptedAccount.accountnameIV);
    String decryptedAccountname = '';
    if (encryptedAccount.accountname.base64 != '') {
      decryptedAccountname =
          encrypter.decrypt(encryptedAccount.accountname, iv: accountNameIV);
    }

    IV usernameIV = IV.fromBase64(encryptedAccount.usernameIV);
    String decryptedUsername = '';
    if (encryptedAccount.username.base64 != '') {
      decryptedUsername =
          encrypter.decrypt(encryptedAccount.username, iv: usernameIV);
    }

    IV passwordIV = IV.fromBase64(encryptedAccount.passwordIV);
    String decryptedPassword = '';
    if (encryptedAccount.password.base64 != '') {
      decryptedPassword =
          encrypter.decrypt(encryptedAccount.password, iv: passwordIV);
    }

    try {
      return Account(encryptedAccount.id, decryptedAccountname,
          decryptedUsername, decryptedPassword);
    } catch (e) {
      return Account.empty();
    }
  }

  Future<EncryptedAccount> encryptAccount(Account account) async {
    IV accountnameIV = await generateIV();
    String encryptedAccountnameBase64 = '';
    if (account.accountname != '') {
      encryptedAccountnameBase64 =
          encrypter.encrypt(account.accountname, iv: accountnameIV).base64;
    }

    IV usernameIV = await generateIV();
    String encryptedUsernameBase64 = '';
    if (account.username != '') {
      encryptedUsernameBase64 =
          encrypter.encrypt(account.username, iv: usernameIV).base64;
    }

    IV passwordIV = await generateIV();
    String encryptedPasswordBase64 = '';
    if (account.password != '') {
      encryptedPasswordBase64 =
          encrypter.encrypt(account.password, iv: passwordIV).base64;
    }

    return EncryptedAccount(
        account.id,
        encryptedAccountnameBase64,
        encryptedUsernameBase64,
        encryptedPasswordBase64,
        accountnameIV.base64,
        usernameIV.base64,
        passwordIV.base64);
  }

  Future<List<Account>> decryptAccountList(
      List<EncryptedAccount> encryptedAccountList) async {
    List<Account> decryptedAccountList = <Account>[];
    Account dacc;
    for (EncryptedAccount encryptedAccount in encryptedAccountList) {
      dacc = await decryptAccount(encryptedAccount);
      decryptedAccountList.add(dacc);
    }
    return decryptedAccountList;
  }

  Future<Note> decryptNote(EncryptedNote encryptedNote) async {
    IV titleIV = IV.fromBase64(encryptedNote.titleIV);
    String decryptedTitle = '';
    if (encryptedNote.title.base64 != '') {
      decryptedTitle = encrypter.decrypt(encryptedNote.title, iv: titleIV);
    }

    IV contentIV = IV.fromBase64(encryptedNote.contentIV);
    String decryptedContent = '';
    if (encryptedNote.content.base64 != '') {
      decryptedContent =
          encrypter.decrypt(encryptedNote.content, iv: contentIV);
    }

    try {
      return Note(
        encryptedNote.id,
        decryptedTitle,
        decryptedContent,
      );
    } catch (e) {
      return Note.empty();
    }
  }

  Future<EncryptedNote> encryptNote(Note note) async {
    IV titleIV = await generateIV();
    String encryptedTitleBase64 = '';
    if (note.title != '') {
      encryptedTitleBase64 = encrypter.encrypt(note.title, iv: titleIV).base64;
    }

    IV contentIV = await generateIV();
    String encryptedContentBase64 = '';
    if (note.content != '') {
      encryptedContentBase64 =
          encrypter.encrypt(note.content, iv: contentIV).base64;
    }

    return EncryptedNote(note.id, encryptedTitleBase64, encryptedContentBase64,
        titleIV.base64, contentIV.base64);
  }

  Future<List<Note>> decryptNoteList(
      List<EncryptedNote> encryptedNoteList) async {
    List<Note> decryptedNoteList = <Note>[];
    Note dnote;
    for (EncryptedNote encryptedNote in encryptedNoteList) {
      dnote = await decryptNote(encryptedNote);
      decryptedNoteList.add(dnote);
    }
    return decryptedNoteList;
  }
}
