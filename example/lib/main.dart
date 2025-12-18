import 'package:flutter/material.dart';
import 'package:secure_screen_wrapper/secure_screen_wrapper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Secure Screen Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isSecure = true;

  @override
  Widget build(BuildContext context) {
    return SecureScreenWrapper(
      enabled: _isSecure,
      child: Scaffold(
        appBar: AppBar(title: const Text('Secure Screen Demo')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.security, size: 100, color: Colors.blue),
              const SizedBox(height: 20),
              Text(
                _isSecure ? 'Screen is Secured' : 'Screen is Not Secured',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Try taking a screenshot:\n'
                  '• Android: Screenshot blocked\n'
                  '• iOS: Screenshot appears black',
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isSecure = !_isSecure;
                  });
                },
                child: Text(_isSecure ? 'Disable Security' : 'Enable Security'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
