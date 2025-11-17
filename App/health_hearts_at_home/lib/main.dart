import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'pages/auth_page.dart';
import 'models/themes.dart';

void main() {
  const baseUrl =
      'http://192.168.1.155:4000'; // replace with your API base URL or move to config
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthService(api: ApiService(baseUrl: baseUrl)),
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
    );

    final ThemeData darkTheme = ThemeData(
      useMaterial3: false,
      colorScheme: darkScheme,
      primarySwatch: customTheme,
      brightness: Brightness.dark,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Auth Template',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      home: AuthGate(
        onToggleTheme: () => setState(() => _isDark = !_isDark),
        isDark: _isDark,
      ),
    );
  }
}

/// Shows AuthPage when not signed in, basic LoggedInPage when signed in.
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
    if (auth.isLoggedIn) {
      return LoggedInPage(onToggleTheme: onToggleTheme, isDark: isDark);
    } else {
      return AuthPage(onToggleTheme: onToggleTheme, isDark: isDark);
    }
  }
}

/// Minimal signed-in page used in the auth-only template.
/// Replace with your full app navigation later.
class LoggedInPage extends StatelessWidget {
  final VoidCallback onToggleTheme;
  final bool isDark;
  const LoggedInPage({
    super.key,
    required this.onToggleTheme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome'),
        actions: [
          IconButton(
            onPressed: onToggleTheme,
            icon: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
          ),
          IconButton(
            onPressed: () async {
              await auth.logout();
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Center(
        child: user == null
            ? const CircularProgressIndicator()
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Hello, ${user.name.isNotEmpty ? user.name : user.email}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Text('Email: ${user.email}'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () async {
                      await auth.logout();
                    },
                    child: const Text('Sign out'),
                  ),
                ],
              ),
      ),
    );
  }
}
