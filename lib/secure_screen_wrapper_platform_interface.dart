import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'secure_screen_wrapper_method_channel.dart';

abstract class SecureScreenWrapperPlatform extends PlatformInterface {
  /// Constructs a SecureScreenWrapperPlatform.
  SecureScreenWrapperPlatform() : super(token: _token);

  static final Object _token = Object();

  static SecureScreenWrapperPlatform _instance = MethodChannelSecureScreenWrapper();

  /// The default instance of [SecureScreenWrapperPlatform] to use.
  ///
  /// Defaults to [MethodChannelSecureScreenWrapper].
  static SecureScreenWrapperPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [SecureScreenWrapperPlatform] when
  /// they register themselves.
  static set instance(SecureScreenWrapperPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
