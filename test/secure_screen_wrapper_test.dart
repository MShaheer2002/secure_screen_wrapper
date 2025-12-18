import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:secure_screen_wrapper/secure_screen_wrapper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel('secure_screen_wrapper');
  final List<MethodCall> log = <MethodCall>[];

  setUp(() {
    log.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      log.add(methodCall);
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('SecureScreenWrapper Widget Tests', () {
    testWidgets('SecureScreenWrapper renders child widget',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SecureScreenWrapper(
            child: Text('Protected Content'),
          ),
        ),
      );

      expect(find.text('Protected Content'), findsOneWidget);
    });

    testWidgets('SecureScreenWrapper calls enableSecureMode on init',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SecureScreenWrapper(
            child: Text('Protected'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(log, isNotEmpty);
      expect(log.first.method, 'enableSecureMode');
    });

    testWidgets('SecureScreenWrapper with enabled=false does not enable',
        (WidgetTester tester) async {
      log.clear();

      await tester.pumpWidget(
        const MaterialApp(
          home: SecureScreenWrapper(
            enabled: false,
            child: Text('Not Protected'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(log, isEmpty);
    });

    testWidgets('SecureScreenWrapper calls disableSecureMode on dispose',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SecureScreenWrapper(
            child: Text('Protected'),
          ),
        ),
      );

      await tester.pumpAndSettle();
      log.clear();

      // Remove the widget
      await tester.pumpWidget(
        const MaterialApp(
          home: Text('No longer protected'),
        ),
      );

      await tester.pumpAndSettle();

      expect(log, isNotEmpty);
      expect(log.any((call) => call.method == 'disableSecureMode'), isTrue);
    });

    testWidgets('SecureScreenWrapper toggles security when enabled changes',
        (WidgetTester tester) async {
      bool isSecure = true;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              home: Column(
                children: [
                  SecureScreenWrapper(
                    enabled: isSecure,
                    child: const Text('Content'),
                  ),
                  ElevatedButton(
                    onPressed: () => setState(() => isSecure = !isSecure),
                    child: const Text('Toggle'),
                  ),
                ],
              ),
            );
          },
        ),
      );

      await tester.pumpAndSettle();
      log.clear();

      // Toggle to disabled
      await tester.tap(find.text('Toggle'));
      await tester.pumpAndSettle();

      expect(log.any((call) => call.method == 'disableSecureMode'), isTrue);
      log.clear();

      // Toggle back to enabled
      await tester.tap(find.text('Toggle'));
      await tester.pumpAndSettle();

      expect(log.any((call) => call.method == 'enableSecureMode'), isTrue);
    });
  });

  group('SecureScreen Static Methods Tests', () {
    test('SecureScreen.enable calls enableSecureMode', () async {
      log.clear();

      await SecureScreen.enable();

      expect(log, isNotEmpty);
      expect(log.first.method, 'enableSecureMode');
    });

    test('SecureScreen.disable calls disableSecureMode', () async {
      log.clear();

      await SecureScreen.disable();

      expect(log, isNotEmpty);
      expect(log.first.method, 'disableSecureMode');
    });

    test('SecureScreen methods handle platform exceptions gracefully',
        () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        throw PlatformException(code: 'ERROR', message: 'Test error');
      });

      // Should not throw
      await expectLater(SecureScreen.enable(), completes);
      await expectLater(SecureScreen.disable(), completes);
    });
  });

  group('Method Channel Tests', () {
    test('enableSecureMode method is called correctly', () async {
      log.clear();

      await SecureScreen.enable();

      expect(log, hasLength(1));
      expect(log[0].method, equals('enableSecureMode'));
      expect(log[0].arguments, isNull);
    });

    test('disableSecureMode method is called correctly', () async {
      log.clear();

      await SecureScreen.disable();

      expect(log, hasLength(1));
      expect(log[0].method, equals('disableSecureMode'));
      expect(log[0].arguments, isNull);
    });
  });
}