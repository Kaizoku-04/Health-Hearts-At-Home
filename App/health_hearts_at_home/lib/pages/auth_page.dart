import 'package:health_hearts_at_home/models/themes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'package:health_hearts_at_home/widgets/text_field_widget.dart';

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
  bool _isLogin = true;
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

  // --- LOGIC METHODS ---

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
      await _showMessageDialog(err);
    }
  }

  Future<void> _showMessageDialog(String message) {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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

  Future<void> _onGoogleSignIn() async {
    final auth = context.read<AuthService>();
    final String? err = await auth.signInWithGoogle();
    if (!mounted) return;
    if (err != null) {
      _showSnack(err);
    }
  }

  Future<void> _forgotPassword() async {
    final auth = context.read<AuthService>();
    final emailDlgController = TextEditingController(text: _emailController.text.trim());

    // 1. Ask for Email
    final String? email = await showDialog<String?>(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
          TextButton(onPressed: () => Navigator.pop(c, null), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final e = emailDlgController.text.trim();
              if (e.isEmpty || _validateEmail(e) != null) {
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
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(sendErr)));
      return;
    }

    // 2. Ask for Code
    if (!mounted) return;
    final codeController = TextEditingController();
    final codeVerifying = ValueNotifier<bool>(false);

    String? verifiedCode = await showDialog<String?>(
      context: context,
      barrierDismissible: false,
      builder: (c) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Enter verification code'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('We sent a verification code to your email. Enter it below.'),
              const SizedBox(height: 12),
              TextField(
                controller: codeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: 'Verification code'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c, null), child: const Text('Cancel')),
            ValueListenableBuilder<bool>(
              valueListenable: codeVerifying,
              builder: (ctx, verifying, _) {
                return TextButton(
                  onPressed: verifying ? null : () async {
                    final code = codeController.text.trim();
                    if (code.isEmpty) return;
                    codeVerifying.value = true;
                    String? verifyErr;
                    try {
                      verifyErr = await auth.verifyResetCode(email: email, code: code);
                    } catch (e) {
                      verifyErr = e.toString();
                    }
                    if (!mounted) return;
                    codeVerifying.value = false;
                    if (verifyErr != null) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(verifyErr)));
                      return;
                    }
                    if (Navigator.of(c).canPop()) Navigator.of(c).pop(code);
                  },
                  child: verifying
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Verify'),
                );
              },
            ),
          ],
        );
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      emailDlgController.dispose();
      codeController.dispose();
      codeVerifying.dispose();
    });

    if (verifiedCode == null) return;

    // 3. New Password
    final newPassController = TextEditingController();
    final confirmPassController = TextEditingController();
    final submittingNotifier = ValueNotifier<bool>(false);

    if (!mounted) return;
    final bool? completed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (c) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                  decoration: const InputDecoration(hintText: 'New password (min 6 chars)'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: confirmPassController,
                  obscureText: true,
                  decoration: const InputDecoration(hintText: 'Confirm password'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
            ValueListenableBuilder<bool>(
              valueListenable: submittingNotifier,
              builder: (ctx, submitting, _) {
                return TextButton(
                  onPressed: submitting ? null : () async {
                    final newPass = newPassController.text;
                    if (_validatePassword(newPass) != null || newPass != confirmPassController.text) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid password or mismatch')));
                      return;
                    }
                    submittingNotifier.value = true;
                    String? confirmErr;
                    try {
                      confirmErr = await auth.confirmPasswordReset(
                          email: email, code: verifiedCode, newPassword: newPass
                      );
                    } catch (e) {
                      confirmErr = e.toString();
                    }
                    if (!mounted) return;
                    submittingNotifier.value = false;
                    if (confirmErr != null) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(confirmErr)));
                      return;
                    }
                    if (Navigator.of(c).canPop()) Navigator.of(c).pop(true);
                  },
                  child: submitting
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Reset'),
                );
              },
            ),
          ],
        );
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      newPassController.dispose();
      confirmPassController.dispose();
      submittingNotifier.dispose();
    });

    if (completed == true) {
      _emailController.text = email;
      _passwordController.clear();
      if (mounted) _showSnack('Password reset successful — you can now log in');
    }
  }

  // --- UI BUILDING BLOCKS ---

  Widget _buildGoogleButton(BuildContext context, bool isDark) {
    final auth = context.watch<AuthService>();
    final bool gLoading = auth.loading;

    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: isDark ? Colors.white : Colors.black87,
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: gLoading
          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
          : _googleLogoWidget(),
      label: const Text('Continue with Google', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      onPressed: gLoading ? null : _onGoogleSignIn,
    );
  }

  Widget _googleLogoWidget() {
    return Image.asset(
      'assets/google_logo.png',
      height: 24,
      width: 24,
      errorBuilder: (context, error, stackTrace) => const Icon(Icons.login),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = widget.isDark;
    final bgColor = isDarkTheme ? const Color(0xFF121212) : const Color(0xFFE7E7EC);
    final cardColor = isDarkTheme ? const Color(0xFF1E1E1E) : Colors.white;
    final primaryText = isDarkTheme ? Colors.white : const Color(0xFF1D1D1F);
    final secondaryText = isDarkTheme ? const Color(0xFFBDBDBD) : const Color(0xFF5A5A60);
    final brandColor = customTheme;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: widget.onToggleTheme,
            icon: Icon(isDarkTheme ? Icons.light_mode : Icons.dark_mode),
            color: primaryText,
            padding: const EdgeInsets.only(right: 20.0),
          ),
        ],
      ),
      body: Center(
        // ✅ WRAP WITH ScrollConfiguration TO HIDE SCROLLBAR
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_rounded, size: 64, color: brandColor),
                  const SizedBox(height: 16),
                  Text(
                    "Health Hearts at Home",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: primaryText
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isLogin ? "Welcome back, please log in." : "Create an account to get started.",
                    style: TextStyle(fontSize: 15, color: secondaryText),
                  ),
                  const SizedBox(height: 32),

                  // --- LOGIN CARD ---
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.grey.withOpacity(isDarkTheme ? 0.2 : 0.1)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDarkTheme ? 0.0 : 0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            _isLogin ? 'Log In' : 'Sign Up',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: primaryText
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),

                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder: (child, animation) => SizeTransition(sizeFactor: animation, child: child),
                            child: _isLogin
                                ? const SizedBox.shrink()
                                : Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: CustomTextField(
                                labelText: 'Full Name',
                                prefixIcon: Icons.person_outline_rounded,
                                controller: _nameController,
                                isDark: isDarkTheme,
                              ),
                            ),
                          ),

                          CustomTextField(
                            labelText: 'Email Address',
                            prefixIcon: Icons.email_outlined,
                            controller: _emailController,
                            isDark: isDarkTheme,
                            validator: _validateEmail,
                          ),
                          const SizedBox(height: 16),

                          CustomTextField(
                            labelText: 'Password',
                            prefixIcon: Icons.lock_outline_rounded,
                            controller: _passwordController,
                            isDark: isDarkTheme,
                            validator: _validatePassword,
                          ),

                          if (_isLogin)
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: _loading ? null : _forgotPassword,
                                child: Text(
                                  'Forgot password?',
                                  style: TextStyle(color: brandColor, fontWeight: FontWeight.w600),
                                ),
                              ),
                            )
                          else
                            const SizedBox(height: 24),

                          ElevatedButton(
                            onPressed: _loading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: brandColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                              shadowColor: brandColor.withOpacity(0.4),
                            ),
                            child: _loading
                                ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                                : Text(
                              _isLogin ? 'Log In' : 'Sign Up',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  _buildGoogleButton(context, isDarkTheme),

                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isLogin ? "Don't have an account? " : "Already have an account? ",
                        style: TextStyle(color: secondaryText),
                      ),
                      GestureDetector(
                        onTap: _loading ? null : () => setState(() => _isLogin = !_isLogin),
                        child: Text(
                          _isLogin ? "Sign Up" : "Log In",
                          style: TextStyle(
                            color: brandColor,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            decorationColor: brandColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}