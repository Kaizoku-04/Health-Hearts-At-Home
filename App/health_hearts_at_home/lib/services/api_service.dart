// improved ApiService (sketch) — replace your current implementation
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const _kAccessKey = 'accessToken';
  static const _kRefreshKey = 'refreshToken';
  final Dio dio;
  final Dio _authDio;
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  Completer<bool>? _refreshCompleter;

  ApiService({required String baseUrl})
    : dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: Duration(milliseconds: 15000),
          receiveTimeout: Duration(milliseconds: 15000),
        ),
      ),
      _authDio = Dio(BaseOptions(baseUrl: baseUrl)) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await storage.read(key: _kAccessKey);
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (DioException e, handler) async {
          final resp = e.response;
          final reqOptions = e.requestOptions;
          if (resp != null &&
              resp.statusCode == 401 &&
              reqOptions.extra['retry'] != true) {
            try {
              final refreshed = await _performRefreshOnce();
              if (refreshed) {
                // build fresh request options
                final newOptions = Options(
                  method: reqOptions.method,
                  headers: Map<String, dynamic>.from(reqOptions.headers),
                  responseType: reqOptions.responseType,
                  contentType: reqOptions.contentType,
                  followRedirects: reqOptions.followRedirects,
                  validateStatus: reqOptions.validateStatus,
                  receiveDataWhenStatusError:
                      reqOptions.receiveDataWhenStatusError,
                );
                // attach new access token
                final newAccess = await storage.read(key: _kAccessKey);
                if (newAccess != null) {
                  newOptions.headers?['Authorization'] = 'Bearer $newAccess';
                }
                // mark so we don't loop again
                reqOptions.extra['retry'] = true;
                final response = await dio.request(
                  reqOptions.path,
                  data: reqOptions.data,
                  queryParameters: reqOptions.queryParameters,
                  options: newOptions,
                );
                handler.resolve(response);
                return;
              }
            } catch (err) {
              // refresh failed — fall through to pass original error
            }
          }
          handler.next(e);
        },
      ),
    );
  }

  Future<bool> _performRefreshOnce() async {
    // single-flight guard
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }
    _refreshCompleter = Completer<bool>();
    try {
      final ok = await _refreshTokens();
      _refreshCompleter!.complete(ok);
      return ok;
    } catch (err) {
      _refreshCompleter!.complete(false);
      return false;
    } finally {
      // reset for next time
      _refreshCompleter = null;
    }
  }

  Future<bool> _refreshTokens() async {
    final refresh = await storage.read(key: _kRefreshKey);
    if (refresh == null || refresh.isEmpty) {
      return false;
    }
    try {
      final r = await _authDio.post(
        '/refresh',
        data: {'refreshToken': refresh},
      );
      final data = r.data;
      final newAccess = data['accessToken'] as String?;
      final newRefresh = data['refreshToken'] as String?;
      if (newAccess != null && newRefresh != null) {
        await storage.write(key: _kAccessKey, value: newAccess);
        await storage.write(key: _kRefreshKey, value: newRefresh);
        return true;
      }
      return false;
    } catch (err) {
      // optionally: if refresh returns 401/400 remove tokens here so we don't repeatedly try
      return false;
    }
  }

  // helper to call unauthenticated endpoints via _authDio
  Future<Map<String, dynamic>> signup(
    String name,
    String email,
    String password,
  ) async {
    final r = await _authDio.post(
      '/signup',
      data: {'name': name, 'email': email, 'password': password},
    );
    return Map<String, dynamic>.from(r.data as Map);
  }

  // ... implement login, loginWithGoogle, me (using dio), sendPasswordResetCode, confirmPasswordReset etc.
  // remember: for public endpoints use _authDio to avoid unnecessary Authorization header presence.
  Future<Map<String, dynamic>> login(String email, String password) async {
    final r = await _authDio.post(
      '/login',
      data: {'email': email, 'password': password},
    );
    return r.data;
  }

  Future<Map<String, dynamic>> me() async {
    final r = await dio.get('/me');
    return r.data;
  }

  Future<void> logoutOnServer(int userId) async {
    try {
      await _authDio.post('/logout', data: {'userId': userId});
    } catch (_) {}
  }

  // ApiService.dart
  Future<Map<String, dynamic>> loginWithGoogle({
    String? code,
    String? idToken,
    String? redirectUri,
  }) async {
    // Build payload only with present fields
    final Map<String, dynamic> payload = {};
    if (code != null && code.isNotEmpty) payload['code'] = code;
    if (idToken != null && idToken.isNotEmpty) payload['idToken'] = idToken;
    if (redirectUri != null && redirectUri.isNotEmpty) {
      payload['redirectUri'] = redirectUri;
    }

    final r = await _authDio.post('/google', data: payload);
    return r.data;
  }

  // inside ApiService (example)
  Future<Map<String, dynamic>> sendPasswordResetCode(String email) async {
    final res = await dio.post('/send-reset-code', data: {'email': email});
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> verifyResetCode(
    String email,
    String code,
  ) async {
    final res = await dio.post(
      '/verify-reset-code',
      data: {'email': email, 'code': code},
    );
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> confirmPasswordReset(
    String email,
    String code,
    String newPassword,
  ) async {
    final res = await dio.post(
      '/confirm-reset',
      data: {'email': email, 'code': code, 'newPassword': newPassword},
    );
    return res.data as Map<String, dynamic>;
  }
}
