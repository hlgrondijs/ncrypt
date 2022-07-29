import 'package:flutter/material.dart';

import '../../core/note.dart';
import '../general/prefabs.dart';

class ViewNote extends StatefulWidget {
  ViewNote({Key key, @required this.note}) : super(key: key);

  final Note note;

  @override
  _ViewNoteState createState() => new _ViewNoteState();
}

class _ViewNoteState extends State<ViewNote> {
  @override
  Widget build(BuildContext context) {
    String title = "View note: ";
    if (widget.note.title != "") {
      title += widget.note.title;
    } else {
      title += "untitled";
    }

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: viewNoteBody(),
    );
  }

  Widget viewNoteBody() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints viewportConstraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: viewportConstraints.maxHeight,
              minWidth: viewportConstraints.maxWidth,
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: gradientBackground(context),
              ),
              child: Container(
                margin: EdgeInsets.fromLTRB(50.0, 10.0, 50.0, 10.0),
                child: Text(
                  widget.note.content,
                  style: TextStyle(fontSize: 24.0),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
