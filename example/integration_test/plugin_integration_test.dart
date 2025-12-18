import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:secure_screen_wrapper/secure_screen_wrapper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('SecureScreenWrapper Integration Tests', () {
    testWidgets('SecureScreenWrapper enables and disables correctly',
        (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(
        const MaterialApp(
          home: SecureScreenWrapper(
            child: Scaffold(
              body: Center(
                child: Text('Protected Screen'),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify the child widget is rendered
      expect(find.text('Protected Screen'), findsOneWidget);

      // Widget should be in the tree
      expect(find.byType(SecureScreenWrapper), findsOneWidget);
    });

    testWidgets('SecureScreenWrapper with enabled=false',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SecureScreenWrapper(
            enabled: false,
            child: Scaffold(
              body: Center(
                child: Text('Not Protected'),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Not Protected'), findsOneWidget);
    });

    testWidgets('SecureScreen global enable and disable',
        (WidgetTester tester) async {
      // Test global enable
      await SecureScreen.enable();
      await tester.pumpAndSettle();

      // Build a simple widget
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: Text('Globally Protected'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Globally Protected'), findsOneWidget);

      // Test global disable
      await SecureScreen.disable();
      await tester.pumpAndSettle();
    });

    testWidgets('Toggle security dynamically', (WidgetTester tester) async {
      bool isSecure = true;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              home: Scaffold(
                body: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SecureScreenWrapper(
                      enabled: isSecure,
                      child: Text(
                        isSecure ? 'Protected' : 'Not Protected',
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isSecure = !isSecure;
                        });
                      },
                      child: const Text('Toggle Security'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );

      await tester.pumpAndSettle();

      // Initially protected
      expect(find.text('Protected'), findsOneWidget);

      // Toggle to not protected
      await tester.tap(find.text('Toggle Security'));
      await tester.pumpAndSettle();

      expect(find.text('Not Protected'), findsOneWidget);

      // Toggle back to protected
      await tester.tap(find.text('Toggle Security'));
      await tester.pumpAndSettle();

      expect(find.text('Protected'), findsOneWidget);
    });

    testWidgets('Navigate between protected and unprotected screens',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Home')),
            body: Center(
              child: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SecureScreenWrapper(
                          child: Scaffold(
                            body: Center(
                              child: Text('Protected Screen'),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  child: const Text('Go to Protected Screen'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap to navigate
      await tester.tap(find.text('Go to Protected Screen'));
      await tester.pumpAndSettle();

      // Verify we're on the protected screen
      expect(find.text('Protected Screen'), findsOneWidget);

      // Go back
      await tester.pageBack();
      await tester.pumpAndSettle();

      // Verify we're back on home
      expect(find.text('Go to Protected Screen'), findsOneWidget);
    });

    testWidgets('Multiple SecureScreenWrapper widgets',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                SecureScreenWrapper(
                  child: Text('Protected 1'),
                ),
                SizedBox(height: 20),
                SecureScreenWrapper(
                  child: Text('Protected 2'),
                ),
                SizedBox(height: 20),
                Text('Not Protected'),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Protected 1'), findsOneWidget);
      expect(find.text('Protected 2'), findsOneWidget);
      expect(find.text('Not Protected'), findsOneWidget);
      expect(find.byType(SecureScreenWrapper), findsNWidgets(2));
    });
  });
}