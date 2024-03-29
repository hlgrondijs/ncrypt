import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'db_handler.dart';
import 'constants.dart';
import 'ncrypt_encryptor.dart';
import 'account.dart';
import 'note.dart';
import 'vault_handler.dart';

class NCryptModel extends Model {
  NCryptModel(
      this._firstUse, this._hideLockDialog, this._accountList, this._noteList);

  NCryptEncryptor _nCryptEncryptor;
  NCryptEncryptor get nCryptEncryptor => _nCryptEncryptor;
  set nCryptEncryptor(encryptor) {
    _nCryptEncryptor = encryptor;
  }

  VaultHandler get vaultHandler => VaultHandler(_nCryptEncryptor);

  bool _firstUse;
  bool get firstUse => _firstUse;

  bool _hideLockDialog;
  bool get hideLockDialog => _hideLockDialog;

  List<Account> _accountList;
  List<Account> get accountList => _accountList;

  List<Note> _noteList;
  List<Note> get noteList => _noteList;

  SharedPreferences sharedPreferences;

  Future init() async {
    await DbHandler2.db.initDb();
    _nCryptEncryptor = await NCryptEncryptor.create('');
  }

  Future lockVault() async {
    _nCryptEncryptor.setPassword('');
    _accountList = [];
    _noteList = [];
  }

  Future toggleFirstUse() async {
    sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool(PREF_FIRST_USE, !firstUse);

    _firstUse = !firstUse;
    notifyListeners();
  }

  Future setHideLockDialog(val) async {
    sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool(PREF_HIDELOCKDIALOG, val);
    _hideLockDialog = val;
  }

  Future setAccountList(List<Account> accList) async {
    _accountList = accList;
    notifyListeners();
  }

  Future setNoteList(List<Note> nList) async {
    _noteList = nList;
    notifyListeners();
  }
}
