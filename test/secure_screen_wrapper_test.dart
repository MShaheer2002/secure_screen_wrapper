import 'package:flutter_test/flutter_test.dart';
import 'package:secure_screen_wrapper/secure_screen_wrapper.dart';
import 'package:secure_screen_wrapper/secure_screen_wrapper_platform_interface.dart';
import 'package:secure_screen_wrapper/secure_screen_wrapper_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockSecureScreenWrapperPlatform
    with MockPlatformInterfaceMixin
    implements SecureScreenWrapperPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final SecureScreenWrapperPlatform initialPlatform = SecureScreenWrapperPlatform.instance;

  test('$MethodChannelSecureScreenWrapper is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelSecureScreenWrapper>());
  });

  test('getPlatformVersion', () async {
    SecureScreenWrapper secureScreenWrapperPlugin = SecureScreenWrapper();
    MockSecureScreenWrapperPlatform fakePlatform = MockSecureScreenWrapperPlatform();
    SecureScreenWrapperPlatform.instance = fakePlatform;

    expect(await secureScreenWrapperPlugin.getPlatformVersion(), '42');
  });
}
