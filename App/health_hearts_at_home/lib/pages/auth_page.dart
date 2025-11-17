import 'package:health_hearts_at_home/models/themes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'package:health_hearts_at_home/widgets/text_field_widget.dart'; // import your widget

class AuthPage extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDark;
  const AuthPage({
    super.key,
    required this.onToggleTheme,
    required this.isDark,
  });

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = false;
  bool _loading = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  String? _validateEmail(String? val) {
    if (val == null || val.isEmpty) return 'Enter email';
    final emailReg = RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$");
    if (!emailReg.hasMatch(val)) return 'Enter a valid email';
    return null;
  }

  String? _validatePassword(String? val) {
    if (val == null || val.isEmpty) return 'Enter password';
    if (val.length < 6) return 'Password must be at least 6 characters';
    return null;
  }
  // inside your AuthPage State class

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthService>();
    setState(() => _loading = true);

    String? err;
    try {
      if (_isLogin) {
        err = await auth.login(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        err = await auth.signUp(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      }
    } catch (e) {
      err = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }

    if (err != null) {
      // show a dialog/card with the message instead of the snack
      await _showMessageDialog(err);
    }
  }

  // Add this helper to the same State class
  Future<void> _showMessageDialog(String message) {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Notice'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // ---------- Google button handler ----------
  Future<void> _onGoogleSignIn() async {
    final auth = context.read<AuthService>();
    // AuthService exposes loading internally (for google flow)
    final String? err = await auth.signInWithGoogle();
    if (!mounted) return;
    if (err != null) {
      _showSnack(err);
    }
  }

  Widget _buildGoogleButton(BuildContext context) {
    final auth = context.watch<AuthService>();
    final bool gLoading = auth.loading;

    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      icon: gLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : _googleLogoWidget(),
      label: const Text('Continue with Google'),
      onPressed: gLoading ? null : _onGoogleSignIn,
    );
  }

  Widget _googleLogoWidget() {
    // Prefer an asset logo if you have it. If not, show a simple Icon fallback.
    // To use the asset, add an image at `assets/google_logo.png` and register it in pubspec.yaml.
    // If you don't want an asset, the Icon below is a fine fallback.
    return Image.asset(
      'assets/google_logo.png',
      height: 20,
      width: 20,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(Icons.login);
      },
    );
  }

  Future<void> _forgotPassword() async {
    final auth = context.read<AuthService>();

    // 1) Ask for email (prefill with existing input if available)
    final emailDlgController = TextEditingController(
      text: _emailController.text.trim(),
    );
    final String? email = await showDialog<String?>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Reset password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter the email associated with your account.'),
            const SizedBox(height: 10),
            TextField(
              controller: emailDlgController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(hintText: 'you@example.com'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, null),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final e = emailDlgController.text.trim();
              if (e.isEmpty) {
                _showSnack('Please enter an email');
                return;
              }
              if (_validateEmail(e) != null) {
                _showSnack('Enter a valid email');
                return;
              }
              Navigator.pop(c, e);
            },
            child: const Text('Send code'),
          ),
        ],
      ),
    );

    if (email == null) return;

    setState(() => _loading = true);
    String? sendErr;
    try {
      sendErr = await auth.sendPasswordResetCode(email: email);
    } catch (e) {
      sendErr = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }

    if (sendErr != null) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(sendErr)));
      }
      return;
    } // ---------- Step A: ask for code only ----------
    if (!mounted) return;
    final codeController = TextEditingController();
    final codeVerifying = ValueNotifier<bool>(false);
    String? verifiedCode;

    verifiedCode = await showDialog<String?>(
      context: context,
      barrierDismissible: false,
      builder: (c) {
        return AlertDialog(
          title: const Text('Enter verification code'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'We sent a verification code to your email. Enter it below.',
              ),
              const SizedBox(height: 12),
              TextField(
                controller: codeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Verification code',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c, null),
              child: const Text('Cancel'),
            ),
            ValueListenableBuilder<bool>(
              valueListenable: codeVerifying,
              builder: (ctx, verifying, _) {
                return TextButton(
                  onPressed: verifying
                      ? null
                      : () async {
                          // ✅ Disable button while loading
                          final code = codeController.text.trim();
                          if (code.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Enter verification code'),
                              ),
                            );
                            return;
                          }

                          codeVerifying.value = true;

                          String? verifyErr;
                          try {
                            verifyErr = await auth.verifyResetCode(
                              email: email,
                              code: code,
                            );
                          } catch (e) {
                            verifyErr = e.toString();
                          }

                          if (!mounted) {
                            codeVerifying.value = false;
                            return;
                          }

                          if (verifyErr != null) {
                            codeVerifying.value = false;
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(SnackBar(content: Text(verifyErr)));
                            return;
                          }

                          // ✅ Pop BEFORE resetting the notifier to avoid rebuild issues
                          if (Navigator.of(c).canPop()) {
                            Navigator.of(c).pop(code);
                          }
                        },
                  child: verifying
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Verify'),
                );
              },
            ),
          ],
        );
      },
    );

    // ✅ Dispose after frame completes to ensure dialog is fully unmounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      emailDlgController.dispose();
      codeController.dispose();
      codeVerifying.dispose();
    });

    if (verifiedCode == null) return;
    // ---------- Step B: ask for new password only ----------
    final newPassController = TextEditingController();
    final confirmPassController = TextEditingController();
    final submittingNotifier = ValueNotifier<bool>(false);

    if (!mounted) return;
    final bool? completed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (c) {
        return AlertDialog(
          title: const Text('Choose new password'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Enter a new password for your account.'),
                const SizedBox(height: 12),
                TextField(
                  controller: newPassController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: 'New password (min 6 chars)',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: confirmPassController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: 'Confirm password',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Cancel'),
            ),
            ValueListenableBuilder<bool>(
              valueListenable: submittingNotifier,
              builder: (ctx, submitting, _) {
                return TextButton(
                  onPressed: submitting
                      ? null
                      : () async {
                          // ✅ Disable button while loading
                          final newPass = newPassController.text;
                          final confirm = confirmPassController.text;
                          final passErr = _validatePassword(newPass);
                          if (passErr != null) {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(SnackBar(content: Text(passErr)));
                            return;
                          }
                          if (newPass != confirm) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Passwords do not match'),
                              ),
                            );
                            return;
                          }

                          submittingNotifier.value = true;

                          String? confirmErr;
                          try {
                            confirmErr = await auth.confirmPasswordReset(
                              email: email,
                              code: verifiedCode!,
                              newPassword: newPass,
                            );
                          } catch (e) {
                            confirmErr = e.toString();
                          }

                          if (!mounted) {
                            submittingNotifier.value = false;
                            return;
                          }

                          if (confirmErr != null) {
                            submittingNotifier.value = false;
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(SnackBar(content: Text(confirmErr)));
                            return;
                          }

                          // ✅ Pop BEFORE resetting the notifier
                          if (Navigator.of(c).canPop()) {
                            Navigator.of(c).pop(true);
                          }
                        },
                  child: submitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Reset password'),
                );
              },
            ),
          ],
        );
      },
    );

    // ✅ Dispose after frame completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      newPassController.dispose();
      confirmPassController.dispose();
      submittingNotifier.dispose();
    });

    if (completed == true) {
      _emailController.text = email;
      _passwordController.clear();
      if (mounted) {
        _showSnack('Password reset successful — you can now log in');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text('Sign Up / Log In', style: TextStyle(color: customTheme)),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: widget.onToggleTheme,
            icon: Icon(widget.isDark ? (Icons.dark_mode) : Icons.light_mode),
            color: customTheme,
            padding: EdgeInsets.only(right: 20.0),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 6,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        _isLogin ? 'Welcome back' : 'Create your account',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _isLogin
                            ? 'Log in to continue to the app'
                            : 'Join now — it only takes a minute',
                        style: theme.textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),

                      // Name (only for sign up) with smooth animation
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: _isLogin
                            ? const SizedBox.shrink()
                            : CustomTextField(
                                labelText: 'Full Name',
                                prefixIcon: Icons.person,
                                controller: _nameController,
                                isDark: widget.isDark,
                              ),
                      ),

                      if (!_isLogin) const SizedBox(height: 12),

                      CustomTextField(
                        labelText: 'Email',
                        prefixIcon: Icons.email,
                        controller: _emailController,
                        isDark: widget.isDark,
                        validator: _validateEmail,
                      ),

                      const SizedBox(height: 12),

                      CustomTextField(
                        labelText: 'Password',
                        prefixIcon: Icons.password,
                        controller: _passwordController,
                        isDark: widget.isDark,
                        validator: _validatePassword,
                      ),

                      const SizedBox(height: 20),

                      ElevatedButton(
                        onPressed: _loading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _loading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                _isLogin ? 'Log In' : 'Sign Up',
                                style: TextStyle(
                                  color: (widget.isDark
                                      ? Colors.white
                                      : Colors.black),
                                ),
                              ),
                      ),

                      const SizedBox(height: 8),

                      TextButton(
                        onPressed: _loading
                            ? null
                            : () => setState(() => _isLogin = !_isLogin),
                        child: Text(
                          _isLogin
                              ? "Don't have an account? Sign up"
                              : 'Already have an account? Log in',
                        ),
                      ),

                      const SizedBox(height: 12),
                      _buildGoogleButton(context),
                      const SizedBox(height: 8),

                      if (_isLogin)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _loading ? null : _forgotPassword,
                            child: const Text('Forgot password?'),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
