import 'package:flutter/material.dart' hide MenuController;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'models/themes.dart';
// ✅ Uncommented this so AuthGate can use it
import 'pages/auth_page.dart';
import 'pages/home_page.dart';
import 'services/api_service.dart';
import 'services/app_service.dart';
import 'services/auth_service.dart';

void main() async {
  // If using an emulator, use 'http://10.0.2.2:4000'
  // If using a physical device, ensure this IP is correct and reachable
  const baseUrl = 'http://10.32.99.85:4000';

  await dotenv.load(fileName: ".env");

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthService(api: ApiService(baseUrl: baseUrl)),
        ),
        ChangeNotifierProvider(
          create: (_) => AppService(api: ApiService(baseUrl: baseUrl)),
          // ✅ Removed "child: const MyApp()" here.
          // Inside the providers list, you only define the create function.
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyApp();
}

class _MyApp extends State<MyApp> {
  bool _isDark = false;

  @override
  Widget build(BuildContext context) {
    final ColorScheme lightScheme = ColorScheme.fromSwatch(
      primarySwatch: customTheme,
    );
    final ColorScheme darkScheme = ColorScheme.fromSwatch(
      primarySwatch: customTheme,
      brightness: Brightness.dark,
    );

    final ThemeData lightTheme = ThemeData(
      useMaterial3: false,
      colorScheme: lightScheme,
      primarySwatch: customTheme,
      scaffoldBackgroundColor: Colors.white,
    );

    final ThemeData darkTheme = ThemeData(
      useMaterial3: false,
      colorScheme: darkScheme,
      primarySwatch: customTheme,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF121212),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CHD - Health Hearts at Home',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      // ✅ Fixed: Only use AuthGate here.
      // It determines whether to show AuthPage or HomePage.
      home: AuthGate(
        onToggleTheme: () => setState(() => _isDark = !_isDark),
        isDark: _isDark,
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  final VoidCallback onToggleTheme;
  final bool isDark;

  const AuthGate({
    super.key,
    required this.onToggleTheme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();

    // logic: If logged in -> Home, Else -> Auth
    if (auth.isLoggedIn) {
      return HomePage(onToggleTheme: onToggleTheme, isDark: isDark);
    } else {
      return AuthPage(onToggleTheme: onToggleTheme, isDark: isDark);
    }
  }
}