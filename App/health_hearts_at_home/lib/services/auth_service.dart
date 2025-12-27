import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_service.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UserModel {
  final int id;
  final String name;
  final String email;
  final bool isVerified;
  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.isVerified,
  });

  // create from backend map
  factory UserModel.fromMap(Map<String, dynamic> m) {
    return UserModel(
      id: m['id'] is int ? m['id'] as int : int.parse(m['id'].toString()),
      name: m['name']?.toString() ?? '',
      email: m['email']?.toString() ?? '',
      isVerified: m['is_verified'] is bool
          ? m['is_verified'] as bool
          : bool.parse(m['is_verified'].toString()),
    );
  }

  // Create from Google account (fallback when server exchange not available)
  factory UserModel.fromGoogle(GoogleSignInAccount acct) {
    return UserModel(
      id: acct.id.hashCode, // best-effort id when no server mapping
      name: acct.displayName ?? '',
      email: acct.email,
      isVerified: true,
    );
  }
}

class AuthService extends ChangeNotifier {
  final ApiService api;
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  // google_sign_in singleton
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  GoogleSignInAccount?
  _googleAccount; // private google account (avoid name clash)

  // public user model used by the rest of your app
  UserModel? user;

  // lifecycle / state flags
  bool isInitializing = true;
  bool _loading = false;
  bool get loading => _loading;

  // constructor
  AuthService({required this.api}) {
    _init();
  }

  bool get isLoggedIn => user != null && user!.isVerified;

  // ---------- initialization ----------
  Future<void> _init() async {
    try {
      // 1) initialize GoogleSignIn (safe to call even if not using Google login)
      try {
        await dotenv.load(fileName: ".env");
        await _googleSignIn.initialize(
          serverClientId: dotenv.env['serverClientId'],
        );
      } catch (e) {
        // initialization may fail on some platforms; ignore but log
        debugPrint('GoogleSignIn.initialize() error: $e');
      }

      // 2) attempt to restore server session first (if tokens exist)
      final storedAccess = await storage.read(key: 'accessToken');
      if (storedAccess != null && storedAccess.isNotEmpty) {
        try {
          final profile = await api.me();
          user = UserModel.fromMap(profile);
          // early return: we have a valid server session
          return;
        } catch (err) {
          debugPrint('api.me error (session may be expired): $err');
        }
      }

      // 3) attempt lightweight Google authentication (restores previous google sign-in without UI)
      try {
        final GoogleSignInAccount? acct = await _googleSignIn
            .attemptLightweightAuthentication();
        if (acct != null) {
          _googleAccount = acct;
          // If you want to attempt server exchange automatically, call signInWithGoogle(exchangeWithServer: true, silent: true)
          // For now, set a fallback user from Google account so UI can reflect signed-in state.
          user = UserModel.fromGoogle(acct);
        }
      } catch (e) {
        debugPrint('attemptLightweightAuthentication error: $e');
      }
    } finally {
      isInitializing = false;
      notifyListeners();
    }
  }

  // ---------- traditional auth (email/password) ----------
  Future<String?> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final data = await api.signup(name, email, password);
      final u = data['user'] as Map<String, dynamic>;
      user = UserModel.fromMap(u);
      notifyListeners();
      return data['message']?.toString() ??
          'Account created. Please verify your email before logging in.';
    } catch (err) {
      return _extractError(err);
    }
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      final data = await api.login(email, password);

      // defensive parse of user payload
      final u = data['user'] as Map<String, dynamic>?;
      if (u == null) {
        return 'Invalid response from server.';
      }

      final tempUser = UserModel.fromMap(u);

      // If user is NOT verified, do NOT store tokens — just inform the user
      if (!tempUser.isVerified) {
        // optional: remove any previously stored tokens to be safe
        try {
          await storage.delete(key: 'accessToken');
          await storage.delete(key: 'refreshToken');
        } catch (_) {}

        // store the user model so UI can reflect "unverified" state if desired
        user = tempUser;
        // don't call notifyListeners() if you don't want the app to treat the user as logged in

        // prefer backend message if available
        final serverMsg =
            (data['message'] as String?) ??
            'Please verify your account first. Check your email for the verification link/code.';
        return serverMsg;
      }

      // user is verified -> store tokens then set user and notify
      if (data['accessToken'] != null) {
        await storage.write(key: 'accessToken', value: data['accessToken']);
      }
      if (data['refreshToken'] != null) {
        await storage.write(key: 'refreshToken', value: data['refreshToken']);
      }

      user = tempUser;
      notifyListeners();
      return null;
    } catch (err) {
      return _extractError(err);
    }
  }

  Future<void> logout() async {
    if (user != null) {
      try {
        await api.logoutOnServer(user!.id);
      } catch (e) {
        debugPrint('logoutOnServer failed: $e');
      }
    }

    // Google signOut if used
    try {
      await _googleSignIn.signOut();
      _googleAccount = null;
    } catch (e) {
      debugPrint('google signOut error: $e');
    }

    user = null;
    await storage.delete(key: 'accessToken');
    await storage.delete(key: 'refreshToken');
    notifyListeners();
  }

  Future<String?> signInWithGoogle({
    List<String> scopes = const <String>['email', 'profile'],
    bool exchangeWithServer = true,
  }) async {
    try {
      _loading = true;
      notifyListeners();

      // 1) Interactive authenticate (preferred) or lightweight
      late final GoogleSignInAccount account;
      try {
        if (_googleSignIn.supportsAuthenticate()) {
          account = await _googleSignIn.authenticate();
        } else {
          final maybe = await _googleSignIn.attemptLightweightAuthentication();
          if (maybe == null) {
            _loading = false;
            notifyListeners();
            return 'Sign in canceled or not available';
          }
          account = maybe;
        }
      } catch (e) {
        _loading = false;
        notifyListeners();
        return 'Google sign-in failed: $e';
      }

      _googleAccount = account;

      // 2) Try to get server auth code using v7 authorizationClient
      String? serverAuthCode;
      try {
        final GoogleSignInServerAuthorization? serverAuth = await account
            .authorizationClient
            .authorizeServer(scopes);
        serverAuthCode = serverAuth?.serverAuthCode;
      } catch (e) {
        debugPrint('authorizeServer() failed or not available: $e');
        serverAuthCode = null;
      }

      // 3) Also obtain idToken as a secondary fallback (may still be available)
      String? idToken;
      try {
        final GoogleSignInAuthentication auth = account.authentication;
        idToken = auth.idToken;
      } catch (e) {
        debugPrint('account.authentication failed: $e');
        idToken = null;
      }

      // 4) If requested, try server exchange (prefer serverAuthCode, fallback to idToken)
      if (exchangeWithServer) {
        // Concrete helper that calls your typed ApiService method using named args
        Future<bool> tryExchangeWithServer(
          String token, {
          required bool tokenIsCode,
        }) async {
          try {
            // Call ApiService.loginWithGoogle with named params
            final Map<String, dynamic> data = await api.loginWithGoogle(
              code: tokenIsCode ? token : null,
              idToken: tokenIsCode ? null : token,
              redirectUri: '', // optional for mobile flows
            );

            // If server returned tokens / user — persist them and succeed
            if (data['accessToken'] != null) {
              await storage.write(
                key: 'accessToken',
                value: data['accessToken'].toString(),
              );
            }
            if (data['refreshToken'] != null) {
              await storage.write(
                key: 'refreshToken',
                value: data['refreshToken'].toString(),
              );
            }
            if (data['user'] != null && data['user'] is Map) {
              user = UserModel.fromMap(Map<String, dynamic>.from(data['user']));
              notifyListeners();
              return true;
            }
          } catch (e) {
            debugPrint('server exchange failed (isCode=$tokenIsCode): $e');
          }
          return false;
        }

        // Try serverAuthCode first (preferred)
        if (serverAuthCode != null) {
          final exchanged = await tryExchangeWithServer(
            serverAuthCode,
            tokenIsCode: true,
          );
          if (exchanged) {
            _loading = false;
            notifyListeners();
            return null; // success
          }
        }

        // Then try idToken if serverAuthCode didn't produce a session
        if (idToken != null) {
          final exchanged = await tryExchangeWithServer(
            idToken,
            tokenIsCode: false,
          );
          if (exchanged) {
            _loading = false;
            notifyListeners();
            return null; // success
          }
        }

        debugPrint(
          'Server exchange unavailable or failed; falling back to local mapping.',
        );
      }

      // 5) Fallback: no server exchange available — map Google account locally
      user = UserModel.fromGoogle(account);
      _loading = false;
      notifyListeners();
      return null;
    } on Exception catch (e) {
      _loading = false;
      notifyListeners();
      return e.toString();
    }
  }

  /// If you need an access token for Google APIs (People, Drive, etc),
  /// request authorization for scopes. This will prompt user if needed.
  Future<String?> requestAccessTokenForScopes(List<String> scopes) async {
    try {
      GoogleSignInAccount? acct = _googleAccount;
      if (acct == null) {
        // try to restore a previously-signed-in Account without UI
        try {
          acct = await _googleSignIn.attemptLightweightAuthentication();
          if (acct != null) _googleAccount = acct;
        } catch (e) {
          // ignore restore errors — we'll treat as not signed in
          debugPrint('lightweight auth failed: $e');
          acct = null;
        }
      }

      if (acct == null) return 'Not signed in';

      final GoogleSignInClientAuthorization authorization = await acct
          .authorizationClient
          .authorizeScopes(scopes);

      return authorization.accessToken;
    } on Exception catch (e) {
      return e.toString();
    }
  }

  // ---------- helpers ----------
  String? _extractError(dynamic err) {
    try {
      if (err is DioException && err.response != null) {
        final d = err.response!.data;
        if (d is Map && d['message'] != null) return d['message'].toString();
      }
    } catch (_) {}
    return 'Unknown error';
  }

  Future<String?> sendPasswordResetCode({required String email}) async {
    try {
      // Expect api.sendPasswordResetCode to return a Map-like response
      final data = await api.sendPasswordResetCode(email);
      // Typical successful response shape: { ok: true } or { message: '...' }
      if (data['ok'] == true || data['success'] == true) return null;
      if (data['message'] != null) return data['message'].toString();
      return null;
    } catch (err) {
      return _extractError(err);
    }
  }

  Future<String?> verifyResetCode({
    required String email,
    required String code,
  }) async {
    try {
      final data = await api.verifyResetCode(email, code);
      if (data['ok'] == true || data['valid'] == true) return null;
      if (data['message'] != null) return data['message'].toString();
      return null;
    } catch (err) {
      return _extractError(err);
    }
  }

  Future<String?> confirmPasswordReset({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    try {
      final data = await api.confirmPasswordReset(email, code, newPassword);
      if (data['ok'] == true || data['success'] == true) {
        return null;
      }
      if (data['message'] != null) return data['message'].toString();
      return null;
    } catch (err) {
      return _extractError(err);
    }
  }
}
