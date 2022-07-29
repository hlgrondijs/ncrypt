import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import '../../core/ncrypt_model.dart';

import '../general/Prefabs.dart';
import '../../core/note.dart';
import '../../core/vault_handler.dart';
import '../general/Vault.dart';

import 'NewNote.dart';
import 'EditNote.dart';
import 'ViewNote.dart';

class NotesVault extends StatefulWidget {
  NotesVault({
    Key key,
    @required this.scaffoldKey,
    @required this.noteList,
    @required this.vaultHandler,
  }) : super(key: key);

  final GlobalKey<ScaffoldState> scaffoldKey;
  final List<Note> noteList;
  final VaultHandler vaultHandler;

  @override
  _NotesVaultState createState() => new _NotesVaultState();
}

class _NotesVaultState extends State<NotesVault> {
  bool showSearch = false;
  List<Note> _notes;

  @override
  void initState() {
    _notes = widget.noteList;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.noteList.length > 0) {
      return Container(
        child: ReorderableListView(
          onReorder: _onReorder,
          reverse: false,
          children:
              _searchFilterNotes(_notes).map<Widget>(noteListItem).toList(),
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
              child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
                      child: Icon(Icons.add),
                    ),
                    GestureDetector(
                      onTap: () {
                        _navigateToNewNote(context);
                      },
                      child: Container(
                        child: Text(
                          '\nStart by adding a new note\n',
                        ),
                      ),
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
      final Note note = _notes.removeAt(oldIndex);
      _notes.insert(newIndex, note);
    });
    _reorderNotesInDB(_notes);
  }

  Widget noteListItem(Note note) {
    return Container(
      key: Key(note.id.toString()),
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
            blurRadius: 4.0,
            offset: Offset(0.0, 3.0),
          ),
        ],
      ),
      child: ExpansionTile(
        key: PageStorageKey<Note>(note),
        backgroundColor: Theme.of(context).primaryColorLight,
        title: Row(
          children: _buildTileHeader(note),
        ),
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(25.0, 5.0, 25.0, 10.0),
            // height: 100.0,
            constraints: BoxConstraints(maxHeight: 250.0),
            width: MediaQuery.of(context).size.width * 0.85,
            child: Text(
              note.content,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.0,
              ),
            ),
          ),
          Container(
            height: 40.0,
            margin: EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 0.0),
            padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 6.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16.0)),
                      ),
                    ),
                    onPressed: () {
                      _navigateToViewNote(context, note);
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.edit,
                          size: 18.0,
                        ),
                        Container(
                          padding: EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 0.0),
                          child: Text('View'),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 6.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16.0)),
                      ),
                    ),
                    onPressed: () {
                      _navigateToEditNote(context, note);
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
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 6.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16.0)),
                      ),
                    ),
                    onPressed: () {
                      _deleteNoteFromDatabase(note.id);
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.edit,
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

  List<Widget> _buildTileHeader(Note note) {
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
                    note.title,
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
                ],
              ),
            ),
          ],
        ),
      ),
    ];
    return builder;
  }

  _navigateToNewNote(BuildContext context) async {
    final newNoteID = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScopedModelDescendant<NCryptModel>(
          builder: (context, _, model) =>
              NewNote(vaultHandler: model.vaultHandler),
        ),
      ),
    );
    if (newNoteID != null) {
      Note newNote = await widget.vaultHandler.getNoteAndDecrypt(newNoteID);
      List<Note> nList = ScopedModel.of<NCryptModel>(context).noteList;
      nList.add(newNote);
      ScopedModel.of<NCryptModel>(context, rebuildOnChange: true)
          .setNoteList(nList);
    }
  }

  _navigateToViewNote(BuildContext context, Note note) async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) => ViewNote(note: note)));
  }

  _navigateToEditNote(BuildContext context, Note note) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditNote(note: note)),
    );
  }

  _reorderNotesInDB(List<Note> noteList) async {
    ScopedModel.of<NCryptModel>(context, rebuildOnChange: false)
        .vaultHandler
        .reorderNotes(noteList);
  }

  List<Note> _searchFilterNotes(List<Note> noteList) {
    VaultState vaultState = context.findAncestorStateOfType<VaultState>();
    if (vaultState.searchFilter == null || vaultState.searchFilter == '') {
      return noteList;
    } else {
      List<Note> filteredNoteList = <Note>[];
      for (Note note in noteList) {
        if (note.title
                .toLowerCase()
                .contains(vaultState.searchFilter.toLowerCase()) ||
            note.content
                .toLowerCase()
                .contains(vaultState.searchFilter.toLowerCase())) {
          filteredNoteList.add(note);
        }
      }
      return filteredNoteList;
    }
  }

  _deleteNoteFromDatabase(int id) async {
    bool accepted = false;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete note'),
          content: Text('Are you sure you want to delete this note?'),
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
      VaultHandler vaultHandler =
          ScopedModel.of<NCryptModel>(context, rebuildOnChange: true)
              .vaultHandler;
      vaultHandler.deleteNote(id);
      List<Note> nList = await vaultHandler.getNotesAndDecrypt();
      ScopedModel.of<NCryptModel>(context, rebuildOnChange: true)
          .setNoteList(nList);
      setState(() {
        _notes = nList;
      });
    }
  }
}
