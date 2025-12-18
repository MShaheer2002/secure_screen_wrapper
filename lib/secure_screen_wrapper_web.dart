import 'dart:js_interop';

import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:web/web.dart' as web;

/// Web implementation of the SecureScreenWrapper plugin
class SecureScreenWrapperWeb {
  /// Registers this class as the default instance of [SecureScreenWrapperWeb]
  static void registerWith(Registrar registrar) {
    final MethodChannel channel = MethodChannel(
      'secure_screen_wrapper',
      const StandardMethodCodec(),
      registrar,
    );

    final pluginInstance = SecureScreenWrapperWeb();
    channel.setMethodCallHandler(pluginInstance._handleMethodCall);
  }

  /// Handles method calls over the MethodChannel
  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'enableSecureMode':
        _enableSecureMode();
        return true;
      case 'disableSecureMode':
        _disableSecureMode();
        return true;
      default:
        throw PlatformException(
          code: 'Unimplemented',
          details: 'Method ${call.method} not implemented on web',
        );
    }
  }

  /// Enable secure mode - disable right-click, text selection, etc.
  void _enableSecureMode() {
    final document = web.document;
    final body = document.body;

    if (body != null) {
      // Disable text selection
      body.style.userSelect = 'none';
      body.style.setProperty('-webkit-user-select', 'none');
      body.style.setProperty('-moz-user-select', 'none');
      body.style.setProperty('-ms-user-select', 'none');
    }

    // Disable right-click context menu
    document.addEventListener('contextmenu', (web.Event event) {
      event.preventDefault();
    }.toJS);

    // Disable drag and drop
    document.addEventListener('dragstart', (web.Event event) {
      event.preventDefault();
    }.toJS);

    // Block screenshot shortcuts
    document.addEventListener('keydown', (web.Event event) {
      if (event is web.KeyboardEvent) {
        // PrintScreen, Ctrl+Shift+S, Cmd+Shift+3, Cmd+Shift+4
        if (event.key == 'PrintScreen' ||
            (event.ctrlKey && event.shiftKey && event.key == 'S') ||
            (event.metaKey && event.shiftKey && event.key == '3') ||
            (event.metaKey && event.shiftKey && event.key == '4')) {
          event.preventDefault();
        }
      }
    }.toJS);

    // Blur content when tab loses focus (prevent screenshot tools)
    document.addEventListener('visibilitychange', (web.Event event) {
      if (document.hidden) {
        _blurContent();
      } else {
        _unblurContent();
      }
    }.toJS);
  }

  /// Disable secure mode - restore normal functionality
  void _disableSecureMode() {
    final body = web.document.body;
    
    if (body != null) {
      // Re-enable text selection
      body.style.userSelect = 'auto';
      body.style.setProperty('-webkit-user-select', 'auto');
      body.style.setProperty('-moz-user-select', 'auto');
      body.style.setProperty('-ms-user-select', 'auto');
    }

    // Remove blur if any
    _unblurContent();
  }

  /// Blur the content
  void _blurContent() {
    final body = web.document.body;
    if (body != null) {
      body.style.filter = 'blur(20px)';
    }
  }

  /// Remove blur from content
  void _unblurContent() {
    final body = web.document.body;
    if (body != null) {
      body.style.filter = 'none';
    }
  }
}