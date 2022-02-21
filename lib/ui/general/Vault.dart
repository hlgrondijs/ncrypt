import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';


import '../../core/NCryptModel.dart';
import 'LockDialog.dart';
import '../../core/Account.dart';
import '../../core/Note.dart';
import 'Prefabs.dart';
import '../../core/VaultHandler.dart';

import '../notes/NotesVault.dart';
import '../notes/NewNote.dart';

import '../accounts/AccountsVault.dart';
import '../accounts/NewAccount.dart';

import 'Landing.dart';

import '../settings/ResetVault.dart';
import '../settings/UISettings.dart';
import '../settings/ChangeMaster.dart';



class Vault extends StatefulWidget {
  Vault({Key key, @required this.vaultHandler}) : super(key: key);

  VaultHandler vaultHandler;

  @override
  VaultState createState() => new VaultState();
}


class VaultState extends State<Vault> with WidgetsBindingObserver {
  AppLifecycleState _lastLifecycleState;
  TextEditingController searchController = new TextEditingController();
  String searchFilter;
  bool showSearch = false;
  bool dontShowLockHelperAgain = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  Map<int, bool> openedTileMap = {};
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    searchController.addListener(() {
      setState(() {
        searchFilter = searchController.text;
      });
    });

  }

  @override
  void dispose() {
    searchController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      Navigator.of(context).pop();
    }
    setState(() {
      _lastLifecycleState = state;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_lastLifecycleState == AppLifecycleState.paused) {
      return Container();
    }
    return WillPopScope(
      onWillPop: _lockVault,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: vaultAppBar(context),
        body: _bodies(_currentIndex),
        drawer: settingsDrawer(context),
        bottomNavigationBar: BottomNavigationBar(
          onTap: _onNavBarTapped,
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          unselectedItemColor: Theme.of(context).colorScheme.secondary,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.account_box),
              label: 'Passwords',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.note),
              label: 'Notes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.lock),
              label: 'Lock',
            ),
          ]
        ),
      )
    );
  }

  Widget _bodies(index) {
    if (index == 0) {
      return ScopedModelDescendant<NCryptModel>(
        builder: (context, _, model) => AccountsVault(
          scaffoldKey: _scaffoldKey,
          accountList: model.accountList,
          vaultHandler: widget.vaultHandler
        ),
      );
    }
    if (index == 1) {
      return ScopedModelDescendant<NCryptModel>(
        builder: (context, _, model) => NotesVault(
          scaffoldKey: _scaffoldKey,
          noteList: model.noteList,
          vaultHandler: widget.vaultHandler,
        ),
      );
    }
    return Container();
  }

  Widget vaultAppBar(BuildContext context) {
    if (_currentIndex == 0) {
      return AppBar(
        actions: <Widget>[
          searchIconButton(),
          Container(
            child: IconButton(
              icon: Icon(Icons.add, size: 30.0),
              onPressed: () {
                _navigateToNewAccount(context);
              },
            ),
          ),
        ],
        automaticallyImplyLeading: false,
        bottom: searchTextField(),
        elevation: 8.0,
        title: Row(
          children: [
            Icon(Icons.account_box),
            Container(
              margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
              child: Text(
                'Passwords',
              ),
            ),
          ],
        ),
      );
    }

    if (_currentIndex == 1) {
      return AppBar(
        actions: [
          searchIconButton(),
          Container(
            child: IconButton(
              icon: Icon(Icons.add, size: 30.0),
              onPressed: () {
                _navigateToNewNote(context);
              },
            ),
          ),
        ],
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Icon(Icons.note),
            Container(
              margin:EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
              child: Text('Notes'),
            ),
          ],
        ),

        bottom: searchTextField(),
        elevation: 8.0,
      );
    }

    return AppBar(
      automaticallyImplyLeading: false,
      leading: Icon(Icons.settings),
      title: Text(
        'Settings'
      )
    );
  }

  Widget searchIconButton() {
    if (!showSearch) {
      return Container(
        margin: EdgeInsets.fromLTRB(.0, .0, 15.0, .0),
        child: IconButton(
          icon: Icon(Icons.search, size: 28.0),
          onPressed: () {
            setState(() {
              showSearch = true;
              searchFilter = searchController.text;
            });
          },
        ),
      );
    }
    return Container();
  }

  Widget searchTextField() {
    if (showSearch) {
      return PreferredSize(
        preferredSize: Size(200.0, 65.0),
        child: Container(
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.fromLTRB(20.0, 0.0, 0.0, 5.0),
                  child: TextFormField(
                    autofocus: true,
                    controller: searchController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      icon: Icon(Icons.search),
                      labelText: 'Type to search...',
                    ),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                child: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      searchFilter = null;
                      showSearch = false;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }
    return null;
  }

  Widget settingsDrawer(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: .7,
      child: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              child: Row(
                children: [
                  Icon(Icons.settings),
                  Container(
                    margin: EdgeInsets.fromLTRB(20.0, 0.0, 0.0, 0.0),
                    child: Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 24.0,
                      )
                    ),
                  ),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * .15,
                  alignment: Alignment.center,
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                        child: Icon(
                          Icons.color_lens,
                          size: 20.0
                        ),
                      ),
                      Flexible(
                        child: ListTile(
                          title: Text('Color theme'),
                          onTap: () {
                            _uiSettings(context);
                          }
                        )
                      )
                    ]
                  )
                ),
                Container(
                  height: MediaQuery.of(context).size.height * .15,
                  alignment: Alignment.center,
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                        child: Icon(
                          Icons.lock,
                          size: 20.0
                        ),
                      ),
                      Flexible(
                        child: ListTile(
                          title: Text('Change master password'),
                          onTap: () {
                            _changeMasterPassword(context);
                          }
                        )
                      )
                    ]
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height * .15,
                  alignment: Alignment.center,
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                        child: Icon(
                          Icons.delete_forever,
                          size: 20.0
                        ),
                      ),
                      Flexible(
                        child: ListTile(
                          title: Text('Reset nCrypt'),
                          onTap: () {
                            _resetDevice(context);
                          }
                        )
                      )
                    ]
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height * .15,
                  alignment: Alignment.center,                  
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                        child: Icon(
                          Icons.help,
                          size: 20.0
                        ),
                      ),
                      Flexible(
                        child: ListTile(
                          title: Text('Help'),
                          onTap: () {
                            _help(context);
                          }
                        )
                      )
                    ]
                  )
                ),
              ]
            )
          ],
        ),
      ),
    );
  }

  void _uiSettings(BuildContext context) {
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => UISettings(),
      )
    );
  }

  void _changeMasterPassword(BuildContext context) {
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ScopedModelDescendant<NCryptModel> (
          builder: (context, _, model) => ChangeMaster(
            vaultHandler: widget.vaultHandler,
          ),
        ),
      )
    );
  }

  void _resetDevice(BuildContext context) {
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ResetVault(),
      )
    ).then((passwordChanged) {
      if (passwordChanged != null) {
        Navigator.of(context).pop();
      }
    });
  }

  void _help(BuildContext context) {
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          body: SafeArea(
            child: Center(
              child: Container(
                padding: EdgeInsets.all(30.0),
                decoration: BoxDecoration(
                  gradient: gradientBackground(context)
                ),
                child: Landing(
                  onSubmit: () {
                    Navigator.of(context).pop();
                  }
                )
              )
            )
          )
        )
      )
    );
  }

  _onNavBarTapped(int index) async {
    if (index == 3) {
      bool lock = await _lockVault();
      if (lock) {
        Navigator.of(context).pop();
      }
    } else {
      if (index == 2) {
        _scaffoldKey.currentState.openDrawer();
        return;
      }
      setState(() {
        _currentIndex = index;
      });
    }
  }

  _navigateToNewAccount(BuildContext context) async {
    final newAccountID = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScopedModelDescendant<NCryptModel>(
          builder: (context, _, model) => NewAccount(
            vaultHandler: model.vaultHandler
          ),
        ),
      ),
    );
    if (newAccountID != null) {
      Account newAccount = await widget.vaultHandler.getAccountAndDecrypt(newAccountID);
      List<Account> accList = ScopedModel.of<NCryptModel>(context).accountList;
      accList.add(newAccount);
      ScopedModel.of<NCryptModel>(context, rebuildOnChange: true).setAccountList(accList);
    }
  }

  _navigateToNewNote(BuildContext context) async {
    final newNoteID = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScopedModelDescendant<NCryptModel>(
          builder: (context, _, model) => NewNote(
            vaultHandler: model.vaultHandler
          ),
        ),
      ),
    );
    if (newNoteID != null) {
      Note newNote = await widget.vaultHandler.getNoteAndDecrypt(newNoteID);
      List<Note> nList =ScopedModel.of<NCryptModel>(context).noteList;
      nList.add(newNote);
      ScopedModel.of<NCryptModel>(context, rebuildOnChange: true).setNoteList(nList);
    }
  }

  Future<bool> _lockVault() async {
    bool lock = false;
    if (!ScopedModel.of<NCryptModel>(context).hideLockDialog) {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            actions: [
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  lock = true;
                  if (dontShowLockHelperAgain) {
                    ScopedModel.of<NCryptModel>(context).setHideLockDialog(true);
                  }
                  Navigator.of(context).pop();
                },
              )
            ],
            content: LockDialog(
              setDontShowAgainBool: _setHideLockDialogFormState,
            ),
            contentPadding: EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 0.0),
            title: Text('Lock your vault.')
          );
        }
      );
    } else {
      lock = true;
    }
    return lock;
  }

  void _setHideLockDialogFormState(val) {
    setState(() {
      dontShowLockHelperAgain = val;
    });
  }
}

