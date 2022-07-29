import 'package:encrypt/encrypt.dart';
import 'package:nCrypt/core/note.dart';
import 'package:test/test.dart';

void main() {
  group('Note class | ', () {
    test('New Note instance is empty', () {
      final Note note = Note.empty();

      expect(note.id, -1);
      expect(note.title, '');
      expect(note.content, '');
    });

    test('New EncryptedNote is empty', () {
      final EncryptedNote encryptedNote = EncryptedNote.empty();

      expect(encryptedNote.id, -1);
      expect(encryptedNote.title, Encrypted.fromBase64(''));
      expect(encryptedNote.content, Encrypted.fromBase64(''));
      expect(encryptedNote.titleIV, '');
      expect(encryptedNote.contentIV, '');
    });
  });
}
