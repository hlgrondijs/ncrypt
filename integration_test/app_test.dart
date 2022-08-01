import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import '../lib/core/ncrypt_model.dart';
import 'package:path/path.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../lib/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('integration tests', () {
    testWidgets(
        'Launch app for first time, setup password and unlock vault. Then create 1 account & 1 note. Then lock the vault.',
        (tester) async {
      SharedPreferences.setMockInitialValues({});

      String path = await getDatabasesPath();
      String dbPath = join(path, 'ncrypt.db');
      await deleteDatabase(dbPath);

      app.main();

      await tester.pumpAndSettle();

      BuildContext context = tester.element(find.byKey(Key('VaultDoorWidget')));

      expect(find.byKey(Key('LandingWidget')), findsOneWidget);

      await tester.tap(find.byKey(Key('LandingOKFAB')));

      await tester.pumpAndSettle();

      expect(find.byKey(Key('SetupPasswordWidget')), findsOneWidget);

      await tester.enterText(find.byKey(Key('ChooseMasterPassword')), '1234');
      await tester.tap(find.byKey(Key('ChooseMasterPasswordFAB')));

      await tester.pumpAndSettle();

      await tester.enterText(
          find.byKey(Key('ConfirmMasterPasswordFormField')), '1234');
      await tester.tap(find.byKey(Key('ConfirmMasterPasswordButton')));

      await tester.pumpAndSettle();

      await tester.enterText(
          find.byKey(Key('MasterPasswordUnlockFormField')), '1234');
      await tester.tap(find.byKey(Key('MasterPasswordUnlockFAB')));

      await tester.pumpAndSettle();

      await tester.tap(find.byKey(Key('NewAccountIconButton')));

      await tester.pumpAndSettle();

      await tester.enterText(
          find.byKey(Key('NewAccountAccountnameFormField')), 'accountname');
      await tester.enterText(
          find.byKey(Key('NewAccountUsernameFormField')), 'username');
      await tester.enterText(
          find.byKey(Key('NewAccountPasswordFormField')), 'password');
      await tester.tap(find.byKey(Key('NewAccountConfirmFAB')));

      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.note));

      await tester.pumpAndSettle();

      await tester.tap(find.byKey(Key('NewNoteIconButton')));

      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(Key('NewNoteTitleFormField')), 'title');
      await tester.enterText(
          find.byKey(Key('NewNoteContentFormField')), 'content');
      await tester.tap(find.byKey(Key('NewNoteConfirmFAB')));

      await tester.pumpAndSettle();

      expect(ScopedModel.of<NCryptModel>(context).accountList.length, 1);
      expect(ScopedModel.of<NCryptModel>(context).noteList.length, 1);

      await tester.tap(find.byIcon(Icons.lock));

      await tester.pumpAndSettle();

      await tester.tap(find.byKey(Key('LockVaultConfirmationTextButton')));

      await tester.pumpAndSettle();

      expect(ScopedModel.of<NCryptModel>(context).accountList.length, 0);
      expect(ScopedModel.of<NCryptModel>(context).noteList.length, 0);
      expect(ScopedModel.of<NCryptModel>(context).nCryptEncryptor.keyString,
          ScopedModel.of<NCryptModel>(context).nCryptEncryptor.deriveKey(''));
    });
  });
}
