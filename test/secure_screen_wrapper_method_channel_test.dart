import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:secure_screen_wrapper/secure_screen_wrapper_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelSecureScreenWrapper platform = MethodChannelSecureScreenWrapper();
  const MethodChannel channel = MethodChannel('secure_screen_wrapper');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
