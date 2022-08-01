import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'dart:core';

import 'package:scoped_model/scoped_model.dart';
import 'ncrypt_model.dart';

import 'account.dart';
import 'note.dart';
import 'ncrypt_encryptor.dart';
import 'db_handler.dart';

class VaultHandler {
  // High-level app functionality methods that can be used throughout the application.
  NCryptEncryptor nCryptEncryptor;
  SharedPreferences sharedPreferences;

  VaultHandler(NCryptEncryptor nCryptEncryptor) {
    this.nCryptEncryptor = nCryptEncryptor;
  }

  Future setEncryptionKey(String password) async {
    nCryptEncryptor.setPassword(password);
    List<String> x = await nCryptEncryptor.encryptTestString();
    await DbHandler2.db.setTestString(x[0], x[1]);
  }

  Future<bool> testPasswordValid(String password) async {
    return await nCryptEncryptor.testPassword(password);
  }

  Future setNCryptEncryptorParameters(String password) async {
    nCryptEncryptor.setPassword(password);
  }

  Future resetVault() async {
    await DbHandler2.db.resetDatabase();
  }

  Future changeMasterPassword(String newPassword) async {
    List<Account> decryptedAccountList = await getAccountsAndDecrypt();
    List<Note> decryptedNoteList = await getNotesAndDecrypt();

    await setEncryptionKey(newPassword);

    await DbHandler2.db.deleteAllAccounts();
    decryptedAccountList.forEach((Account account) async {
      await addAccount(account);
    });

    await DbHandler2.db.deleteAllNotes();
    decryptedNoteList.forEach((Note note) async {
      await addNote(note);
    });
  }

  Future updateAccountsStateFromDB(BuildContext context) async {
    List<Account> accountList = await getAccountsAndDecrypt();
    ScopedModel.of<NCryptModel>(context, rebuildOnChange: true)
        .setAccountList(accountList);
  }

  Future updateNotesStateFromDB(BuildContext context) async {
    List<Note> noteList = await getNotesAndDecrypt();
    ScopedModel.of<NCryptModel>(context, rebuildOnChange: true)
        .setNoteList(noteList);
  }

  Future deleteAccount(int id) async {
    await DbHandler2.db.deleteAccount(id);
  }

  Future deleteNote(int id) async {
    await DbHandler2.db.deleteNote(id);
  }

  Future<Account> getAccountAndDecrypt(int id) async {
    EncryptedAccount encryptedAccount = await DbHandler2.db.getAccount(id);
    Account decryptedAccount =
        await nCryptEncryptor.decryptAccount(encryptedAccount);
    return decryptedAccount;
  }

  Future<Note> getNoteAndDecrypt(int id) async {
    EncryptedNote encryptedNote = await DbHandler2.db.getNote(id);
    Note decryptedNote = await nCryptEncryptor.decryptNote(encryptedNote);
    return decryptedNote;
  }

  Future<List<Account>> getAccountsAndDecrypt() async {
    List<EncryptedAccount> encAccList = await DbHandler2.db.getAllAccounts();
    List<Account> decAccList =
        await nCryptEncryptor.decryptAccountList(encAccList);
    return decAccList;
  }

  Future<List<Note>> getNotesAndDecrypt() async {
    List<EncryptedNote> encNoteList = await DbHandler2.db.getAllNotes();
    List<Note> decNoteList = await nCryptEncryptor.decryptNoteList(encNoteList);
    return decNoteList;
  }

  Future<int> addAccount(Account account) async {
    EncryptedAccount encryptedAccount =
        await nCryptEncryptor.encryptAccount(account);
    int id = await DbHandler2.db.putAccount(encryptedAccount);
    return id;
  }

  Future updateAccount(Account account) async {
    EncryptedAccount encryptedAccount =
        await nCryptEncryptor.encryptAccount(account);
    await DbHandler2.db.updateAccount(encryptedAccount);
  }

  Future<int> addNote(Note note) async {
    EncryptedNote encryptedNote = await nCryptEncryptor.encryptNote(note);
    int id = await DbHandler2.db.putNote(encryptedNote);
    return id;
  }

  Future updateNote(Note note) async {
    EncryptedNote encryptedNote = await nCryptEncryptor.encryptNote(note);
    await DbHandler2.db.updateNote(encryptedNote);
  }

  Future reorderNotes(List<Note> noteList) async {
    await DbHandler2.db.reorderNotes(noteList);
  }

  Future reorderAccounts(List<Account> accList) async {
    await DbHandler2.db.reorderAccounts(accList);
  }
}
