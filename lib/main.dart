import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:ncmt_kripa/firebase_options.dart';
import 'package:ncmt_kripa/providers/auth_provider.dart';
import 'package:ncmt_kripa/providers/task_provider.dart';
import 'package:ncmt_kripa/providers/theme_providers.dart';
import 'package:ncmt_kripa/screens/dashboard.dart';
import 'package:ncmt_kripa/screens/login_screen.dart';
import 'package:ncmt_kripa/theme/app_theme.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthenticationProvider()),
        ChangeNotifierProvider(create: (context) => TaskProvider(),),
        ChangeNotifierProvider(create: (context) => ThemeProvider(),)
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: AuthWrapper(),
    theme: AppTheme.lightTheme,
    darkTheme: AppTheme.darkTheme,
    themeMode: context.watch<ThemeProvider>().isDarkMode ? ThemeMode.dark : ThemeMode.light,
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        print("Connection: ${snapshot.connectionState}");
        print("Has Data: ${snapshot.hasData}");
        print("User: ${snapshot.data}");
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.hasData) {
          return const Dashboard();
        }

        return const LoginScreen();
      },
    );
  }
}
