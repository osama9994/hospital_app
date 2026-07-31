import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:hospital_app/main.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('hospital_app_test_');
    Hive.init(tempDir.path);
  });

  setUp(() async {
    if (!Hive.isBoxOpen('authBox')) {
      await Hive.openBox('authBox');
    }
    await Hive.box('authBox').clear();
  });

  tearDownAll(() async {
    await Hive.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  testWidgets('shows the login screen when no user is saved', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    expect(find.text('Hospital Management System'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Register Here'), findsOneWidget);
  });
}
