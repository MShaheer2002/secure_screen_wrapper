import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'secure_screen_wrapper_platform_interface.dart';

/// An implementation of [SecureScreenWrapperPlatform] that uses method channels.
class MethodChannelSecureScreenWrapper extends SecureScreenWrapperPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('secure_screen_wrapper');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
