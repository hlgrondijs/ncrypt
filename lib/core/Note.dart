import 'package:encrypt/encrypt.dart';

class Note {
  int id;
  String title, content;

  Note.empty() {
    this.id = -1;
    this.title = '';
    this.content = '';
  }

  Note(this.id, this.title, this.content);
}


class EncryptedNote {
  int id;
  Encrypted title, content;
  String titleIV, contentIV;

  EncryptedNote.empty() {
    this.id = -1;
    this.title = Encrypted.fromUtf8('');
    this.content = Encrypted.fromUtf8('');
    this.titleIV = '';
    this.contentIV = '';
  }

  EncryptedNote(id, title, content, titleIV, contentIV) {
    this.id = id;
    this.title = Encrypted.fromBase64(title);
    this.content = Encrypted.fromBase64(content);
    this.titleIV = titleIV;
    this.contentIV = contentIV;
  }
}