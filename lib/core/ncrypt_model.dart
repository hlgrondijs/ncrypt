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

  NcryptEncryptor _nCryptEncryptor;
  NcryptEncryptor get nCryptEncryptor => _nCryptEncryptor;

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
    String salt = await DbHandler2.db.getSalt();
    print(salt);
    _nCryptEncryptor = NcryptEncryptor('', salt);
  }

  Future lockVault() async {
    _nCryptEncryptor.keyString = '';
    _accountList = [];
    _noteList = [];
  }

  Future toggleFirstUse() async {
    sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool(PREF_FIRST_USE, !firstUse);

    _firstUse = !firstUse;
    print(_firstUse);
    notifyListeners();
  }

  Future setHideLockDialog(val) async {
    sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool(PREF_HIDELOCKDIALOG, val);
    _hideLockDialog = val;
  }

  void setAccountList(List<Account> accList) async {
    _accountList = accList;
    notifyListeners();
  }

  void setNoteList(List<Note> nList) async {
    _noteList = nList;
    notifyListeners();
  }
}
