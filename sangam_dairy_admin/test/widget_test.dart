import 'package:flutter_test/flutter_test.dart';
import 'package:sangam_dairy_admin/main.dart';

void main() {
  testWidgets('Sangam Dairy Admin Login screen loads',
          (WidgetTester tester) async {
        await tester.pumpWidget(const SangamDairyAdminApp());

        expect(find.text('Sangam Dairy'), findsOneWidget);
        expect(find.text('ADMIN PANEL'), findsOneWidget);
        expect(find.text('Welcome back!'), findsOneWidget);
        expect(find.text('Email address'), findsOneWidget);
        expect(find.text('Password'), findsOneWidget);
        expect(find.text('Sign In'), findsOneWidget);
      });
}
