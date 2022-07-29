import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../lib/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('integration test', () {
    testWidgets('Launch app and start using.', (tester) async {
      app.main();

      await tester.pumpAndSettle();
      expect(find.byKey(Key('LandingWidget')), findsOneWidget);

      final Finder fab = find.byKey(Key('LandingOKFAB'));
      await tester.tap(fab);

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

      print('1');
    });
  });
}
