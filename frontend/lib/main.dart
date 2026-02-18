import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';
import 'screens/dashboard_screen.dart';
import 'screens/login_screen.dart';
import 'providers/damage_history_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => DamageHistoryProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Vehicle Damage Detector',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

/// 🔥 Auto switch: Login ↔ Dashboard + LOAD FIRESTORE DATA
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 🔥 USER LOGGED IN → LOAD DAMAGE DETECTIONS
        if (snapshot.hasData) {
          // Load Firestore detections AFTER login
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Provider.of<DamageHistoryProvider>(
              context,
              listen: false,
            ).loadDetections();
          });

          return const DashboardScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
