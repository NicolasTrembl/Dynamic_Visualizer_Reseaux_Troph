import 'package:flutter/material.dart';
import 'pages/visualizer_page.dart';
import 'pages/welcome_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => const WelcomePage());
          case '/visualizer':
            final String path = settings.arguments as String;
            return MaterialPageRoute(
              builder: (_) => VisualizerPage(path: path),
            );
          default:
            return null;
        }
      },
      title: 'Dynamic Visualizer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyan),
        useMaterial3: true,
      ),
      initialRoute: '/',
      // home: const WelcomePage(),
    );
  }
}
