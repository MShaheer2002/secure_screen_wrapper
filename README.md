# Secure Screen Wrapper

[![pub package](https://img.shields.io/pub/v/secure_screen_wrapper.svg)](https://pub.dev/packages/secure_screen_wrapper)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A Flutter package that prevents screenshots and screen recording across **Android**, **iOS**, and **Web** platforms.

##  Features

| Platform | Protection Method | Effectiveness |
|----------|------------------|---------------|
| **Android** | `FLAG_SECURE` |  Complete block |
| **iOS** | Secure text entry layer |  Screenshots appear black |
| **Web** | Multi-layer protection |  Best effort (browser limitations) |

### Web Protection Layers:
-  Disables right-click context menu
-  Blocks text selection and copy
-  Prevents screenshot keyboard shortcuts
-  Blurs content when tab loses focus
-  Adds watermark overlay
-  Prevents drag and drop

##  Installation

Add to your `pubspec.yaml`:
```yaml
dependencies:
  secure_screen_wrapper: ^1.0.2
```

Run:
```bash
flutter pub get
```

##  Usage

### Protect Specific Screens
```dart
import 'package:secure_screen_wrapper/secure_screen_wrapper.dart';

class PaymentScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SecureScreenWrapper(
      child: Scaffold(
        appBar: AppBar(title: Text('Payment Details')),
        body: YourSensitiveContent(),
      ),
    );
  }
}
```

### Global Protection
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SecureScreen.enable();
  runApp(MyApp());
}
```

### Dynamic Control
```dart
SecureScreenWrapper(
  enabled: _isSecureMode, // Toggle with state
  child: YourWidget(),
)
```

##  Platform Setup

### Android
No additional setup required!

### iOS
No additional setup required!

### Web
No additional setup required!

##  Important Notes

- **Android**: Screenshots are completely blocked at OS level
- **iOS**: Screenshots can be taken but appear as black screens
- **Web**: Protection has limitations due to browser security restrictions. Determined users with external tools may still capture content, but casual screenshot attempts are blocked.

##  API Reference

### `SecureScreenWrapper`
Widget that protects its child from screenshots.

**Properties:**
- `child` (Widget, required): The widget to protect
- `enabled` (bool, optional): Enable/disable protection (default: true)

### `SecureScreen`
Global security control.

## Web Platform Limitations

**IMPORTANT**: Web browsers **cannot completely block screenshots** at the OS level due to browser security restrictions. 

### What Web Protection Does:
Disables right-click context menu
Blocks text selection and copy
Prevents common keyboard shortcuts (PrintScreen, Ctrl+Shift+S, etc.)
Blurs content when tab loses focus
Adds watermark overlay
Blocks developer tools shortcuts
Prevents drag and drop of images

### What Web Protection CANNOT Do:
Block OS-level screenshot tools (Windows Snipping Tool, macOS Cmd+Shift+4, etc.)
Block browser extensions that capture screenshots
Block external screen capture devices/software
Prevent screenshots if JavaScript is disabled

### Recommendation:
For truly sensitive data on web, consider:
1. Using session-based access with time limits
2. Adding visible watermarks with user info
3. Implementing server-side watermarking
4. Using DRM-protected content delivery
5. Requiring authentication and logging access

**Methods:**
- `SecureScreen.enable()`: Enable protection globally
- `SecureScreen.disable()`: Disable protection globally

##  Testing

Try these on different platforms:
- Take a screenshot (Android: blocked, iOS: black screen, Web: prevented)
- Right-click (Web: disabled)
- Select text (Web: disabled)
- Press PrintScreen (Web: prevented)

##  Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

##  License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

##  Issues

Found a bug? [Report it here](https://github.com/MShaheer2002/secure_screen_wrapper/issues)

##  Support

If you find this package helpful, please give it a ⭐ on [GitHub](https://github.com/MShaheer2002/secure_screen_wrapper)!