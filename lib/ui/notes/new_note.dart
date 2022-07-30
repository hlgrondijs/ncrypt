import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants.dart';
import '../../core/note.dart';
import '../general/prefabs.dart';
import '../../core/vault_handler.dart';

class NewNote extends StatefulWidget {
  NewNote({Key key, @required this.vaultHandler}) : super(key: key);

  final VaultHandler vaultHandler;

  @override
  _NewNoteState createState() => _NewNoteState();
}

class _NewNoteState extends State<NewNote> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController textBoxController = TextEditingController();
  Note newNote = new Note(-1, '', '');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('New note')),
      body: body(),
    );
  }

  Widget body() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints viewportConstraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: viewportConstraints.maxHeight,
            ),
            child: Form(
              key: _formKey,
              child: Container(
                padding: EdgeInsets.fromLTRB(50.0, 30.0, 50.0, 30.0),
                decoration: BoxDecoration(
                  gradient: gradientBackground(context),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text('Store a new note using the form below'),
                    Container(
                      child: TextFormField(
                        key: Key('NewNoteTitleFormField'),
                        maxLength: MAX_TITLE_LENGTH,
                        decoration: InputDecoration(
                          icon: Icon(Icons.title),
                          labelText: 'Title',
                          helperText: 'Enter the title of your note',
                        ),
                        keyboardType: TextInputType.text,
                        onSaved: (String title) {
                          newNote.title = title;
                        },
                      ),
                    ),
                    Container(
                      child: TextField(
                        key: Key('NewNoteContentFormField'),
                        decoration: InputDecoration(
                          icon: Icon(Icons.edit),
                          labelText: 'Note content',
                          helperText: 'Enter the text of your note',
                        ),
                        keyboardType: TextInputType.multiline,
                        maxLines: 5,
                        maxLength: MAX_CONTENT_LENGTH,
                        maxLengthEnforcement: MaxLengthEnforcement.enforced,
                        controller: textBoxController,
                      ),
                    ),
                    Container(
                      child: FloatingActionButton(
                        key: Key('NewNoteConfirmFAB'),
                        child: Icon(Icons.check),
                        elevation: 5.0,
                        onPressed: () {
                          _storeNote();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  _storeNote() {
    final FormState form = _formKey.currentState;
    form.save();
    newNote.content = textBoxController.text;

    widget.vaultHandler.addNote(newNote).then((id) {
      Navigator.pop(context, id);
    });
  }
}
