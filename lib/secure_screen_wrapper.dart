library secure_screen_wrapper;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A wrapper widget that prevents screenshots on Android and makes screenshots
/// appear black on iOS.
class SecureScreenWrapper extends StatefulWidget {
  final Widget child;
  final bool enabled;

  const SecureScreenWrapper({
    Key? key,
    required this.child,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<SecureScreenWrapper> createState() => _SecureScreenWrapperState();
}

class _SecureScreenWrapperState extends State<SecureScreenWrapper>
    with WidgetsBindingObserver {
  static const MethodChannel _channel = MethodChannel('secure_screen_wrapper');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.enabled) {
      _enableSecureMode();
    }
  }

  @override
  void didUpdateWidget(SecureScreenWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enabled != widget.enabled) {
      if (widget.enabled) {
        _enableSecureMode();
      } else {
        _disableSecureMode();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (widget.enabled) {
      _disableSecureMode();
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!widget.enabled) return;
    if (state == AppLifecycleState.resumed) {
      _enableSecureMode();
    }
  }

  Future<void> _enableSecureMode() async {
    try {
      await _channel.invokeMethod('enableSecureMode');
    } on PlatformException catch (e) {
      debugPrint('Failed to enable secure mode: ${e.message}');
    }
  }

  Future<void> _disableSecureMode() async {
    try {
      await _channel.invokeMethod('disableSecureMode');
    } on PlatformException catch (e) {
      debugPrint('Failed to disable secure mode: ${e.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Global helper to enable secure mode for the entire app
class SecureScreen {
  static const MethodChannel _channel = MethodChannel('secure_screen_wrapper');

  static Future<void> enable() async {
    try {
      await _channel.invokeMethod('enableSecureMode');
    } on PlatformException catch (e) {
      debugPrint('Failed to enable secure mode: ${e.message}');
    }
  }

  static Future<void> disable() async {
    try {
      await _channel.invokeMethod('disableSecureMode');
    } on PlatformException catch (e) {
      debugPrint('Failed to disable secure mode: ${e.message}');
    }
  }
}