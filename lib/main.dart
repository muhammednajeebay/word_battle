import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app/di/injection.dart';
import 'features/matchmaking/presentation/pages/lobby_page.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Fallback if firebase_options.dart is missing or invalid (for development)
    debugPrint("Firebase initialization failed: $e");
    // You might want to show an error screen here
  }
  await setupDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Word Battle Arena',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LobbyPage(),
    );
  }
}
