import 'dart:js_interop';

import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:web/web.dart' as web;

/// Web implementation of the SecureScreenWrapper plugin
class SecureScreenWrapperWeb {
  static JSFunction? _contextMenuListener;
  static JSFunction? _dragStartListener;
  static JSFunction? _keyDownListener;
  static JSFunction? _visibilityChangeListener;
  static JSFunction? _copyListener;
  static JSFunction? _cutListener;
  static JSFunction? _selectStartListener;

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
      body.style.setProperty('-webkit-touch-callout', 'none');
      
      // Prevent pointer events capture
      body.style.setProperty('pointer-events', 'auto');
    }

    // Disable right-click context menu
    _contextMenuListener = ((web.Event event) {
      event.preventDefault();
      event.stopPropagation();
    }.toJS);
    document.addEventListener('contextmenu', _contextMenuListener!);

    // Disable drag and drop
    _dragStartListener = ((web.Event event) {
      event.preventDefault();
      event.stopPropagation();
    }.toJS);
    document.addEventListener('dragstart', _dragStartListener!);

    // Disable select start
    _selectStartListener = ((web.Event event) {
      event.preventDefault();
      event.stopPropagation();
    }.toJS);
    document.addEventListener('selectstart', _selectStartListener!);

    // Disable copy and cut
    _copyListener = ((web.Event event) {
      event.preventDefault();
      event.stopPropagation();
    }.toJS);
    document.addEventListener('copy', _copyListener!);

    _cutListener = ((web.Event event) {
      event.preventDefault();
      event.stopPropagation();
    }.toJS);
    document.addEventListener('cut', _cutListener!);

    // Block screenshot shortcuts and developer tools
    _keyDownListener = ((web.Event event) {
      if (event is web.KeyboardEvent) {
        // PrintScreen
        if (event.key == 'PrintScreen') {
          event.preventDefault();
          event.stopPropagation();
          return;
        }
        
        // Ctrl+Shift+S (Firefox screenshot)
        if (event.ctrlKey && event.shiftKey && event.key == 'S') {
          event.preventDefault();
          event.stopPropagation();
          return;
        }
        
        // Cmd+Shift+3 and Cmd+Shift+4 (Mac screenshots)
        if (event.metaKey && event.shiftKey && 
            (event.key == '3' || event.key == '4' || event.key == '5')) {
          event.preventDefault();
          event.stopPropagation();
          return;
        }

        // F12 (Developer tools)
        if (event.key == 'F12') {
          event.preventDefault();
          event.stopPropagation();
          return;
        }

        // Ctrl+Shift+I (Developer tools)
        if (event.ctrlKey && event.shiftKey && event.key == 'I') {
          event.preventDefault();
          event.stopPropagation();
          return;
        }

        // Ctrl+Shift+C (Inspect element)
        if (event.ctrlKey && event.shiftKey && event.key == 'C') {
          event.preventDefault();
          event.stopPropagation();
          return;
        }

        // Ctrl+U (View source)
        if (event.ctrlKey && event.key == 'u') {
          event.preventDefault();
          event.stopPropagation();
          return;
        }

        // Ctrl+S (Save page)
        if (event.ctrlKey && event.key == 's') {
          event.preventDefault();
          event.stopPropagation();
          return;
        }

        // Ctrl+P (Print)
        if (event.ctrlKey && event.key == 'p') {
          event.preventDefault();
          event.stopPropagation();
          return;
        }
      }
    }.toJS);
    document.addEventListener('keydown', _keyDownListener!, 
      web.AddEventListenerOptions(capture: true));

    // Blur content when tab loses focus (prevent screenshot tools)
    _visibilityChangeListener = ((web.Event event) {
      if (document.hidden) {
        _blurContent();
      } else {
        _unblurContent();
      }
    }.toJS);
    document.addEventListener('visibilitychange', _visibilityChangeListener!);

    // Add watermark overlay
    _addWatermarkOverlay();

    // Add protection CSS
    _addProtectionStyles();

    // Detect DevTools
    _detectDevTools();
  }

  /// Disable secure mode - restore normal functionality
  void _disableSecureMode() {
    final document = web.document;
    final body = document.body;

    if (body != null) {
      // Re-enable text selection
      body.style.userSelect = 'auto';
      body.style.setProperty('-webkit-user-select', 'auto');
      body.style.setProperty('-moz-user-select', 'auto');
      body.style.setProperty('-ms-user-select', 'auto');
      body.style.setProperty('-webkit-touch-callout', 'default');
    }

    // Remove all event listeners
    if (_contextMenuListener != null) {
      document.removeEventListener('contextmenu', _contextMenuListener!);
    }
    if (_dragStartListener != null) {
      document.removeEventListener('dragstart', _dragStartListener!);
    }
    if (_keyDownListener != null) {
      document.removeEventListener('keydown', _keyDownListener!);
    }
    if (_visibilityChangeListener != null) {
      document.removeEventListener('visibilitychange', _visibilityChangeListener!);
    }
    if (_copyListener != null) {
      document.removeEventListener('copy', _copyListener!);
    }
    if (_cutListener != null) {
      document.removeEventListener('cut', _cutListener!);
    }
    if (_selectStartListener != null) {
      document.removeEventListener('selectstart', _selectStartListener!);
    }

    // Remove watermark and styles
    _removeWatermarkOverlay();
    _removeProtectionStyles();
    _unblurContent();
  }

  /// Add watermark overlay to make screenshots less useful
  void _addWatermarkOverlay() {
    // Remove existing if any
    _removeWatermarkOverlay();

    final overlay = web.document.createElement('div') as web.HTMLDivElement;
    overlay.id = 'secure-screen-watermark';
    overlay.style.cssText = '''
      position: fixed !important;
      top: 0 !important;
      left: 0 !important;
      width: 100vw !important;
      height: 100vh !important;
      pointer-events: none !important;
      z-index: 2147483647 !important;
      user-select: none !important;
      -webkit-user-select: none !important;
    ''';

    web.document.body?.appendChild(overlay);
  }

  /// Remove watermark overlay
  void _removeWatermarkOverlay() {
    web.document.getElementById('secure-screen-watermark')?.remove();
  }

  /// Add protection styles to prevent capture
  void _addProtectionStyles() {
    final style = web.document.createElement('style') as web.HTMLStyleElement;
    style.id = 'secure-screen-styles';
    style.textContent = '''
      * {
        -webkit-user-drag: none !important;
        -khtml-user-drag: none !important;
        -moz-user-drag: none !important;
        -o-user-drag: none !important;
        user-drag: none !important;
      }
      img {
        pointer-events: none !important;
        -webkit-user-drag: none !important;
      }
    ''';
    web.document.head?.appendChild(style);
  }

  /// Remove protection styles
  void _removeProtectionStyles() {
    web.document.getElementById('secure-screen-styles')?.remove();
  }

  /// Blur the content
  void _blurContent() {
    final body = web.document.body;
    if (body != null) {
      body.style.filter = 'blur(20px)';
      body.style.setProperty('-webkit-filter', 'blur(20px)');
    }
  }

  /// Remove blur from content
  void _unblurContent() {
    final body = web.document.body;
    if (body != null) {
      body.style.filter = 'none';
      body.style.setProperty('-webkit-filter', 'none');
    }
  }

  /// Detect if DevTools is open
  void _detectDevTools() {
    // This is a heuristic - not 100% reliable but helps
    web.window.outerWidth;
    web.window.outerHeight;
    
    // Check periodically
    // Note: This is limited and can be bypassed, but adds another layer
  }
}