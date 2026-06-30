import 'package:flutter/material.dart';

void main() => runApp(const LowkeyMapsApp());

/// Minimal, dependency-free starter so the iOS cloud build + TestFlight pipeline
/// can be proven end-to-end first. Port the map/GPS/roads features in on top of this.
class LowkeyMapsApp extends StatelessWidget {
  const LowkeyMapsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lowkey Maps',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF08080F),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFA855F7),
          secondary: Color(0xFF22D3EE),
          surface: Color(0xFF111120),
        ),
        useMaterial3: true,
      ),
      home: const _Home(),
    );
  }
}

class _Home extends StatelessWidget {
  const _Home();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🗺️', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 12),
            const Text('Lowkey Maps',
                style: TextStyle(
                    fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            const SizedBox(height: 6),
            Text('iOS preview build',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.6))),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: () {},
              style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFA855F7)),
              child: const Text('Get started'),
            ),
          ],
        ),
      ),
    );
  }
}
