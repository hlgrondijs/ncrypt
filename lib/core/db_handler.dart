import 'dart:async';
import 'dart:math';
import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'account.dart';
import 'note.dart';

class DbHandler2 {
  DbHandler2._();

  static final DbHandler2 db = DbHandler2._();

  Database _database;
  final Random _random = Random.secure();

  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await initDb();
    return _database;
  }

  String generateSalt() {
    // This salt is used for the master password key derivation.
    var values = List<int>.generate(32, (i) => _random.nextInt(256));
    return base64Url.encode(values);
  }

  initializeDatabase(Database db, int version) async {
    await db.execute("""
      CREATE TABLE Accounts (
        id INTEGER PRIMARY KEY,
        accountname VARCHAR(255),
        username VARCHAR(255),
        password VARCHAR(255),
        accountname_iv VARCHAR(255),
        username_iv VARCHAR(255),
        password_iv VARCHAR(255),
        m_order INT
      );
      """);

    await db.execute("""
    CREATE TABLE Notes (
      id INTEGER PRIMARY KEY,
      title VARCHAR(255),
      content VARCHAR(5000),
      title_iv VARCHAR(255),
      content_iv VARCHAR(255),
      m_order INT
    );
    """);

    await db.execute("""
    CREATE TABLE Tools (
      id INTEGER PRIMARY KEY,
      salt VARCHAR(999),
      test_string_encrypted VARCHAR(500),
      test_string_iv VARCHAR(255)
    );
    """);

    final String initializationSalt = generateSalt();
    await db.rawInsert("""
      INSERT INTO Tools(salt) VALUES("${initializationSalt}");
      """);
  }

  initDb() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'ncrypt.db');

    return await openDatabase(path, version: 1, readOnly: false,
        onCreate: (Database db, int version) async {
      await initializeDatabase(db, version);
    }, onUpgrade: (Database db, int oldVersion, int newVersion) async {
      // migrations go here
    });
  }

  Future resetDatabase() async {
    var dbClient = await database;
    await dbClient.rawDelete("""
      DELETE FROM Accounts;
      """);
    await dbClient.rawDelete("""
      DELETE FROM Notes;
      """);
    await dbClient.rawDelete("""
      DELETE FROM Tools;
      """);
    final String salt = generateSalt();
    await dbClient.rawInsert("""
      INSERT INTO Tools (salt) VALUES ("${salt}");
      """);
  }

  Future getSalt() async {
    var dbClient = await database;
    var result = await dbClient.rawQuery("""
      SELECT salt FROM Tools;
      """);
    return result[0]['salt'];
  }

  Future<dynamic> getTestString() async {
    var dbClient = await database;
    var result = await dbClient.rawQuery("""
      SELECT test_string_encrypted, test_string_iv FROM Tools WHERE id = 1;
      """);
    return result[0];
  }

  Future setTestString(String testString, String iv) async {
    var dbClient = await database;
    var result = await dbClient.rawInsert("""
      UPDATE Tools SET test_string_encrypted = "${testString}", test_string_iv = "${iv}" WHERE id = 1;
      """);
  }

  Future updateTestString(String testString, String iv) async {
    var dbClient = await database;
    var result = await dbClient.rawUpdate("""
      UPDATE Tools SET test_string_encrypted = "${testString}", test_string_iv = "${iv}" WHERE id = 1;
      """);
  }

  /*
  Notes
  */

  Future putNote(EncryptedNote encryptedNote) async {
    var dbClient = await database;

    var countResult = await dbClient.rawQuery("""
      SELECT COUNT(*) FROM Notes;
      """);
    int rowCount = Sqflite.firstIntValue(countResult);

    var mOrderIndex;
    if (rowCount == 0) {
      mOrderIndex = 0;
    } else {
      var maxResult = await dbClient.rawQuery("""
        SELECT MAX(m_order) FROM Notes;
        """);
      mOrderIndex = Sqflite.firstIntValue(maxResult) + 1;
    }

    var result = await dbClient.rawInsert("""
      INSERT INTO Notes (title, content, title_iv, content_iv, m_order)
      VALUES (
      "${encryptedNote.title.base64}",
      "${encryptedNote.content.base64}",
      "${encryptedNote.titleIV}",
      "${encryptedNote.contentIV}",
      ${mOrderIndex});
      """);
    return result;
  }

  Future updateNote(EncryptedNote encryptedNote) async {
    var dbClient = await database;
    var result = dbClient.rawUpdate("""
      UPDATE Notes SET 
      title = "${encryptedNote.title.base64}",
      content = "${encryptedNote.content.base64}",
      title_iv = "${encryptedNote.titleIV}",
      content_iv = "${encryptedNote.contentIV}"
      WHERE id = ${encryptedNote.id};
      """);
    return result;
  }

  Future<EncryptedNote> getNote(int id) async {
    var dbClient = await database;
    var result = await dbClient.rawQuery("""
      SELECT title, content, title_iv, content_iv FROM Notes WHERE id = ${id};
      """);
    EncryptedNote encryptedNote = new EncryptedNote(id, result[0]['title'],
        result[0]['content'], result[0]['title_iv'], result[0]['content_iv']);
    return encryptedNote;
  }

  Future deleteNote(int id) async {
    var dbClient = await database;
    var result = await dbClient.rawDelete("""
      DELETE FROM Notes WHERE id = ${id};
      """);
    return result;
  }

  Future<List<EncryptedNote>> getAllNotes() async {
    var dbClient = await database;
    try {
      var result = await dbClient.rawQuery("""
        SELECT id, title, content, title_iv, content_iv FROM Notes ORDER BY m_order;
        """);

      List<EncryptedNote> encryptedNoteList = <EncryptedNote>[];
      for (var row in result) {
        encryptedNoteList.add(EncryptedNote(row['id'], row['title'],
            row['content'], row['title_iv'], row['content_iv']));
      }
      return encryptedNoteList;
    } catch (e) {
      print('Error getting encrypted notes from DB');
      return [];
    }
  }

  Future deleteAllNotes() async {
    var dbClient = await database;
    await dbClient.rawDelete("""
      DELETE FROM Notes;
      """);
  }

  Future reorderNotes(List<Note> noteList) async {
    var dbClient = await database;
    int index = 0;
    for (var note in noteList) {
      await dbClient.rawQuery("""
        UPDATE Notes SET m_order = ${index} WHERE id = ${note.id};
        """);
      index++;
    }
  }

  /*
  Accounts
  */

  Future putAccount(EncryptedAccount encryptedAccount) async {
    var dbClient = await database;

    var countResult = await dbClient.rawQuery("""
      SELECT COUNT(*) FROM Notes;
      """);
    int rowCount = Sqflite.firstIntValue(countResult);

    var mOrderIndex;
    if (rowCount == 0) {
      mOrderIndex = 0;
    } else {
      var maxResult = await dbClient.rawQuery("""
        SELECT MAX(m_order) FROM Notes;
        """);
      mOrderIndex = Sqflite.firstIntValue(maxResult) + 1;
    }

    var result = await dbClient.rawInsert("""
      INSERT INTO Accounts (accountname, username, password, accountname_iv, username_iv, password_iv, m_order)
      VALUES (
        "${encryptedAccount.accountname.base64}",
        "${encryptedAccount.username.base64}",
        "${encryptedAccount.password.base64}",
        "${encryptedAccount.accountnameIV}",
        "${encryptedAccount.usernameIV}",
        "${encryptedAccount.passwordIV}",
        ${mOrderIndex});
      """);
    return result;
  }

  Future updateAccount(EncryptedAccount encryptedAccount) async {
    var dbClient = await database;
    var result = await dbClient.rawUpdate("""
      UPDATE Accounts SET 
        accountname = "${encryptedAccount.accountname.base64}",
        username = "${encryptedAccount.username.base64}",
        password = "${encryptedAccount.password.base64}",
        accountname_iv = "${encryptedAccount.accountnameIV}",
        username_iv = "${encryptedAccount.usernameIV}",
        password_iv = "${encryptedAccount.passwordIV}"
        WHERE id = ${encryptedAccount.id};
      """);
  }

  Future<EncryptedAccount> getAccount(int id) async {
    var dbClient = await database;
    var result = await dbClient.rawQuery("""
      SELECT accountname, username, password, accountname_iv, username_iv, password_iv FROM Accounts WHERE id = ${id};
      """);
    EncryptedAccount encryptedAccount = new EncryptedAccount(
        id,
        result[0]['accountname'],
        result[0]['username'],
        result[0]['password'],
        result[0]['accountname_iv'],
        result[0]['username_iv'],
        result[0]['password_iv']);
    return encryptedAccount;
  }

  Future deleteAccount(int id) async {
    var dbClient = await database;
    var result = await dbClient.rawDelete("""
      DELETE FROM Accounts WHERE id = ${id};
      """);
  }

  Future<List<EncryptedAccount>> getAllAccounts() async {
    var dbClient = await database;
    try {
      var result = await dbClient.rawQuery("""
        SELECT id, accountname, username, password, accountname_iv, username_iv, password_iv FROM Accounts ORDER BY m_order;
        """);

      List<EncryptedAccount> encryptedAccountList = <EncryptedAccount>[];
      for (var row in result) {
        encryptedAccountList.add(EncryptedAccount(
            row['id'],
            row['accountname'],
            row['username'],
            row['password'],
            row['accountname_iv'],
            row['username_iv'],
            row['password_iv']));
      }
      return encryptedAccountList;
    } catch (e) {
      print("Error getting encrypted accounts from DB.");
      return [];
    }
  }

  Future deleteAllAccounts() async {
    var dbClient = await database;
    await dbClient.rawDelete("""
      DELETE FROM Accounts;
      """);
  }

  Future reorderAccounts(List<Account> accList) async {
    var dbClient = await database;
    int index = 0;
    for (var acc in accList) {
      await dbClient.rawQuery("""
        UPDATE Accounts SET m_order = ${index} WHERE id = ${acc.id};
        """);
      index++;
    }
  }
}
