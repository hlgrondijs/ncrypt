import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:scoped_model/scoped_model.dart';
import '../../core/ncrypt_model.dart';

import '../general/prefabs.dart';
import '../../core/account.dart';
import '../../core/vault_handler.dart';

import 'edit_account.dart';
import 'new_account.dart';
import '../general/vault.dart';

class AccountsVault extends StatefulWidget {
  AccountsVault({
    Key key,
    @required this.scaffoldKey,
    @required this.accountList,
    @required this.vaultHandler,
  }) : super(key: key);

  final GlobalKey<ScaffoldState> scaffoldKey;
  final List<Account> accountList;
  final VaultHandler vaultHandler;

  final Key key = Key('AccountsVaultWidget');

  @override
  AccountsVaultState createState() => new AccountsVaultState();
}

class AccountsVaultState extends State<AccountsVault> {
  bool showSearch = false;
  Map<int, bool> openedTileMap = {};

  @override
  Widget build(BuildContext context) {
    if (widget.accountList.length > 0) {
      return Container(
        child: ReorderableListView(
          onReorder: _onReorder,
          reverse: false,
          children: _searchFilterAccounts(widget.accountList)
              .map<Widget>(accountListItem)
              .toList(),
        ),
        decoration: BoxDecoration(
          gradient: gradientBackground(context),
          border: Border(
            top: BorderSide(
              color: Theme.of(context).dividerColor,
              width: .5,
              style: BorderStyle.solid,
            ),
          ),
        ),
      );
    } else {
      return Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          gradient: gradientBackground(context),
          border: Border(
            top: BorderSide(
              color: Theme.of(context).dividerColor,
              width: .5,
              style: BorderStyle.solid,
            ),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                _navigateToNewAccount(context);
              },
              child: Container(
                //   width: MediaQuery.of(context).size.width * .8,
                //   height: MediaQuery.of(context).size.height * .15,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
                      child: Icon(Icons.add),
                    ),
                    Container(
                      child: Text('\nStart by adding a new account\n'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      List<Account> newList = widget.accountList;
      final Account account = newList.removeAt(oldIndex);
      newList.insert(newIndex, account);
      widget.vaultHandler.reorderAccounts(newList);
    });
  }

  Widget accountListItem(Account account) {
    return Container(
      key: Key('AccountListItem_' + account.id.toString()),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColorDark,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            style: BorderStyle.solid,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor,
            blurRadius: 10.0,
            offset: Offset(0.0, 3.0),
          ),
        ],
      ),
      child: ExpansionTile(
        key: PageStorageKey<Account>(account),
        backgroundColor: Theme.of(context).primaryColorLight,
        title: Row(
          children: _buildTileHeader(account),
        ),
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 10.0),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
                  child: Icon(Icons.account_box),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
                  child: Text('Username: '),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Container(
                          child: Text(
                            account.username,
                            overflow: TextOverflow.clip,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(10.0, 0.0, 5.0, 0.0),
                        height: 30,
                        child: FloatingActionButton(
                          onPressed: () {
                            Clipboard.setData(
                                ClipboardData(text: account.username));
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content:
                                    Text('Copied username to clipboard.')));
                          },
                          heroTag:
                              'username_copy_button_' + account.id.toString(),
                          mini: true,
                          child: Icon(
                            Icons.content_copy,
                            size: 15.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 10.0),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
                  child: Icon(Icons.vpn_key),
                ),
                Container(
                    padding: EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
                    child: Text('Password: ')),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Container(
                          child: Text(
                            account.password,
                            overflow: TextOverflow.clip,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(10.0, 0.0, 5.0, 0.0),
                        height: 30,
                        child: FloatingActionButton(
                          onPressed: () {
                            Clipboard.setData(
                                ClipboardData(text: account.password));
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content:
                                    Text('Copied password to clipboard.')));
                          },
                          heroTag:
                              'password_copy_button_' + account.id.toString(),
                          mini: true,
                          child: Icon(
                            Icons.content_copy,
                            size: 15.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 40.0,
            padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  margin: EdgeInsets.fromLTRB(15.0, 0.0, 5.0, 0.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 6.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(16.0),
                        ),
                      ),
                    ),
                    onPressed: () {
                      _navigateToEditAccount(context, account);
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.edit,
                          size: 18.0,
                        ),
                        Container(
                          padding: EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 0.0),
                          child: Text('Edit'),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(15.0, 0.0, 0.0, 0.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 6.0,
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(16.0))),
                    ),
                    onPressed: () {
                      _deleteAccountFromDatabase(account.id);
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete,
                          size: 18.0,
                        ),
                        Container(
                          padding: EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 0.0),
                          child: Text('Delete'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTileHeader(Account account) {
    List<Widget> builder = [
      Expanded(
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
              child: Icon(Icons.drag_handle),
            ),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    account.accountname,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24.0,
                      color: Theme.of(context).secondaryHeaderColor,
                    ),
                  ),
                  SizedBox(
                    width: 20.0,
                  ),
                  Text(
                    account.username,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Theme.of(context).disabledColor,
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    ];
    return builder;
  }

  _navigateToNewAccount(BuildContext context) async {
    final newAccountID = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScopedModelDescendant<NCryptModel>(
          builder: (context, _, model) =>
              NewAccount(vaultHandler: model.vaultHandler),
        ),
      ),
    );
    if (newAccountID != null) {
      Account newAccount =
          await widget.vaultHandler.getAccountAndDecrypt(newAccountID);
      List<Account> accList = ScopedModel.of<NCryptModel>(context).accountList;
      accList.add(newAccount);
      ScopedModel.of<NCryptModel>(context, rebuildOnChange: true)
          .setAccountList(accList);
    }
  }

  _navigateToEditAccount(BuildContext context, Account account) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditAccount(
          account: account,
        ),
      ),
    );
  }

  List<Account> _searchFilterAccounts(List<Account> accList) {
    VaultState vaultState = context.findAncestorStateOfType<VaultState>();
    if (vaultState.searchFilter == null || vaultState.searchFilter == '') {
      return accList;
    } else {
      List<Account> filteredAccList = <Account>[];
      for (Account acc in accList) {
        if (acc.accountname
                .toLowerCase()
                .contains(vaultState.searchFilter.toLowerCase()) ||
            acc.username
                .toLowerCase()
                .contains(vaultState.searchFilter.toLowerCase())) {
          filteredAccList.add(acc);
        }
      }
      return filteredAccList;
    }
  }

  Future _deleteAccountFromDatabase(int id) async {
    bool accepted = false;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete account'),
          content: Text('Are you sure you want to delete this account?'),
          actions: [
            TextButton(
              child: Text('Decline'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Accept'),
              onPressed: () {
                accepted = true;
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );

    if (accepted) {
      widget.vaultHandler.deleteAccount(id);
      List<Account> accList = await widget.vaultHandler.getAccountsAndDecrypt();
      ScopedModel.of<NCryptModel>(context, rebuildOnChange: true)
          .setAccountList(accList);
    }
  }
}
