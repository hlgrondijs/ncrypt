import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:scoped_model/scoped_model.dart';
import '../../core/ncrypt_model.dart';

import '../../core/note.dart';
import '../general/prefabs.dart';
import '../../core/vault_handler.dart';

class EditNote extends StatefulWidget {
  const EditNote({Key key, @required this.note}) : super(key: key);

  final Note note;

  @override
  _EditNoteState createState() => _EditNoteState();
}

class _EditNoteState extends State<EditNote> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController textBoxController;

  @override
  void initState() {
    super.initState();
    textBoxController = TextEditingController(text: widget.note.content);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit note'),
      ),
      body: editNoteBody(),
    );
  }

  Widget editNoteBody() {
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
                  Container(
                    child: TextFormField(
                      decoration: InputDecoration(
                        icon: Icon(Icons.title),
                        labelText: 'Title',
                        helperText: 'The title of your note',
                      ),
                      initialValue: widget.note.title,
                      maxLength: 40,
                      maxLengthEnforcement: MaxLengthEnforcement.enforced,
                      keyboardType: TextInputType.text,
                      onSaved: (String title) {
                        widget.note.title = title;
                      },
                    ),
                  ),
                  Container(
                      child: TextField(
                    decoration: InputDecoration(
                      icon: Icon(Icons.edit),
                      labelText: 'Note content',
                    ),
                    keyboardType: TextInputType.multiline,
                    maxLines: 5,
                    maxLength: 500,
                    maxLengthEnforcement: MaxLengthEnforcement.enforced,
                    controller: textBoxController,
                  )),
                  Container(
                    margin: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                    child: confirmationButton(storeNote),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  storeNote() {
    final FormState form = _formKey.currentState;
    form.save();
    widget.note.content = textBoxController.text;

    VaultHandler vaultHandler =
        ScopedModel.of<NCryptModel>(context).vaultHandler;
    vaultHandler.updateNote(widget.note).then((_) {
      vaultHandler.getAccountsAndDecrypt().then((accList) {
        ScopedModel.of<NCryptModel>(context).setAccountList(accList);
      });
      Navigator.pop(context);
    });
  }
}
