import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
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
          connectTimeout: const Duration(milliseconds: 15000),
          receiveTimeout: const Duration(milliseconds: 15000),
          contentType: Headers.jsonContentType,
          responseType: ResponseType.json,
        ),
      ),
      _authDio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(milliseconds: 15000),
          receiveTimeout: const Duration(milliseconds: 15000),
          contentType: Headers.jsonContentType,
          responseType: ResponseType.json,
        ),
      ) {
    // Add logging interceptor
    dio.interceptors.add(LoggingInterceptor());
    _authDio.interceptors.add(LoggingInterceptor());

    // Add main request/response/error interceptor
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

          // Handle 401 with token refresh
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
              debugPrint('❌ Token refresh failed: $err');
              // refresh failed — fall through to pass original error
            }
          }
          handler.next(e);
        },
      ),
    );

    // Add error handling interceptor
    dio.interceptors.add(ErrorInterceptor());
    _authDio.interceptors.add(ErrorInterceptor());
  }

  // ===== TOKEN MANAGEMENT =====

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
        debugPrint('🔐 Tokens refreshed successfully');
        return true;
      }
      return false;
    } catch (err) {
      debugPrint('❌ Token refresh error: $err');
      // optionally: if refresh returns 401/400 remove tokens here so we don't repeatedly try
      return false;
    }
  }

  // ===== AUTHENTICATION ENDPOINTS =====

  Future<Map<String, dynamic>> signup(
    String name,
    String email,
    String password,
  ) async {
    try {
      final r = await _authDio.post(
        '/signup',
        data: {'name': name, 'email': email, 'password': password},
      );
      return Map<String, dynamic>.from(r.data as Map);
    } on DioException catch (e) {
      debugPrint('❌ Signup error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final r = await _authDio.post(
        '/login',
        data: {'email': email, 'password': password},
      );

      // Store tokens if provided
      if (r.data is Map) {
        final accessToken = r.data['accessToken'] as String?;
        final refreshToken = r.data['refreshToken'] as String?;

        if (accessToken != null) {
          await storage.write(key: _kAccessKey, value: accessToken);
        }
        if (refreshToken != null) {
          await storage.write(key: _kRefreshKey, value: refreshToken);
        }
      }

      return r.data;
    } on DioException catch (e) {
      debugPrint('❌ Login error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> loginWithGoogle({
    String? code,
    String? idToken,
    String? redirectUri,
  }) async {
    try {
      // Build payload only with present fields
      final Map<String, dynamic> payload = {};
      if (code != null && code.isNotEmpty) payload['code'] = code;
      if (idToken != null && idToken.isNotEmpty) payload['idToken'] = idToken;
      if (redirectUri != null && redirectUri.isNotEmpty) {
        payload['redirectUri'] = redirectUri;
      }

      final r = await _authDio.post('/google', data: payload);

      // Store tokens if provided
      if (r.data is Map) {
        final accessToken = r.data['accessToken'] as String?;
        final refreshToken = r.data['refreshToken'] as String?;

        if (accessToken != null) {
          await storage.write(key: _kAccessKey, value: accessToken);
        }
        if (refreshToken != null) {
          await storage.write(key: _kRefreshKey, value: refreshToken);
        }
      }

      return r.data;
    } on DioException catch (e) {
      debugPrint('❌ Google login error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> sendPasswordResetCode(String email) async {
    try {
      final res = await _authDio.post(
        '/send-reset-code',
        data: {'email': email},
      );
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      debugPrint('❌ Send reset code error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> verifyResetCode(
    String email,
    String code,
  ) async {
    try {
      final res = await _authDio.post(
        '/verify-reset-code',
        data: {'email': email, 'code': code},
      );
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      debugPrint('❌ Verify reset code error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> confirmPasswordReset(
    String email,
    String code,
    String newPassword,
  ) async {
    try {
      final res = await _authDio.post(
        '/confirm-reset',
        data: {'email': email, 'code': code, 'newPassword': newPassword},
      );
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      debugPrint('❌ Confirm password reset error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> me() async {
    try {
      final r = await dio.get('/me');
      return r.data;
    } on DioException catch (e) {
      debugPrint('❌ Get user error: $e');
      rethrow;
    }
  }

  Future<void> logoutOnServer(int userId) async {
    try {
      await _authDio.post('/logout', data: {'userId': userId});
    } catch (e) {
      debugPrint('⚠️ Logout server error (non-critical): $e');
    }
  }

  // ===== GENERIC GET/POST/PUT/PATCH/DELETE METHODS FOR CHD APP =====

  /// Generic GET request
  Future<dynamic> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      debugPrint('🔵 GET: $endpoint');
      final response = await dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: options,
      );
      debugPrint('✅ GET Success: $endpoint - ${response.statusCode}');
      return response.data;
    } on DioException catch (e) {
      debugPrint('❌ GET Error: $endpoint - ${_getDioErrorMessage(e)}');
      rethrow;
    }
  }

  /// Generic POST request
  Future<dynamic> post(
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      debugPrint('🔵 POST: $endpoint');
      debugPrint('📦 Data: $data');
      final response = await dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      debugPrint('✅ POST Success: $endpoint - ${response.statusCode}');
      return response.data;
    } on DioException catch (e) {
      debugPrint('❌ POST Error: $endpoint - ${_getDioErrorMessage(e)}');
      rethrow;
    }
  }

  /// Generic PUT request
  Future<dynamic> put(
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      debugPrint('🔵 PUT: $endpoint');
      final response = await dio.put(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      debugPrint('✅ PUT Success: $endpoint - ${response.statusCode}');
      return response.data;
    } on DioException catch (e) {
      debugPrint('❌ PUT Error: $endpoint - ${_getDioErrorMessage(e)}');
      rethrow;
    }
  }

  /// Generic PATCH request
  Future<dynamic> patch(
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      debugPrint('🔵 PATCH: $endpoint');
      final response = await dio.patch(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      debugPrint('✅ PATCH Success: $endpoint - ${response.statusCode}');
      return response.data;
    } on DioException catch (e) {
      debugPrint('❌ PATCH Error: $endpoint - ${_getDioErrorMessage(e)}');
      rethrow;
    }
  }

  /// Generic DELETE request
  Future<void> delete(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      debugPrint('🔵 DELETE: $endpoint');
      final response = await dio.delete(
        endpoint,
        queryParameters: queryParameters,
        options: options,
      );
      debugPrint('✅ DELETE Success: $endpoint - ${response.statusCode}');
    } on DioException catch (e) {
      debugPrint('❌ DELETE Error: $endpoint - ${_getDioErrorMessage(e)}');
      rethrow;
    }
  }

  /// Upload file
  Future<dynamic> uploadFile(
    String endpoint, {
    required String filePath,
    required String fileName,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      debugPrint('🔵 File Upload: $endpoint');

      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
        ...?additionalData,
      });

      final response = await dio.post(endpoint, data: formData);

      debugPrint('✅ File Upload Success: $endpoint');
      return response.data;
    } on DioException catch (e) {
      debugPrint('❌ File Upload Error: $endpoint - ${_getDioErrorMessage(e)}');
      rethrow;
    }
  }

  /// Download file
  Future<void> downloadFile(
    String endpoint,
    String savePath, {
    Function(int received, int total)? onReceiveProgress,
  }) async {
    try {
      debugPrint('🔵 File Download: $endpoint');

      await dio.download(
        endpoint,
        savePath,
        onReceiveProgress:
            onReceiveProgress ??
            (received, total) {
              if (total != -1) {
                debugPrint(
                  'Download progress: ${(received / total * 100).toStringAsFixed(0)}%',
                );
              }
            },
      );

      debugPrint('✅ File Download Success: $endpoint');
    } on DioException catch (e) {
      debugPrint(
        '❌ File Download Error: $endpoint - ${_getDioErrorMessage(e)}',
      );
      rethrow;
    }
  }

  // ===== UTILITY METHODS =====

  /// Helper method to get readable error messages from DioException
  String _getDioErrorMessage(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please check your internet.';
      case DioExceptionType.sendTimeout:
        return 'Send timeout. Please try again.';
      case DioExceptionType.receiveTimeout:
        return 'Receive timeout. Please try again.';
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final statusMessage = e.response?.statusMessage;
        return 'Error: $statusCode - $statusMessage';
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      case DioExceptionType.connectionError:
        return 'Connection error. Please check your internet.';
      case DioExceptionType.unknown:
        return 'Unknown error occurred: ${e.message}';
      default:
        return 'An error occurred: ${e.message}';
    }
  }

  /// Set auth token manually
  void setAuthToken(String token) {
    dio.options.headers['Authorization'] = 'Bearer $token';
    debugPrint('🔐 Auth token set');
  }

  /// Remove auth token
  void removeAuthToken() {
    dio.options.headers.remove('Authorization');
    debugPrint('🔐 Auth token removed');
  }

  /// Clear all stored tokens
  Future<void> clearTokens() async {
    await storage.delete(key: _kAccessKey);
    await storage.delete(key: _kRefreshKey);
    removeAuthToken();
    debugPrint('🔐 All tokens cleared');
  }

  /// Get stored access token
  Future<String?> getAccessToken() async {
    return await storage.read(key: _kAccessKey);
  }

  /// Get stored refresh token
  Future<String?> getRefreshToken() async {
    return await storage.read(key: _kRefreshKey);
  }
}

// ===== INTERCEPTORS =====

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint(
      '┌─────────────────────────────────────────────────────\n'
      '│ 📤 REQUEST\n'
      '├─ Method: ${options.method}\n'
      '├─ URL: ${options.uri}\n'
      '├─ Headers: ${options.headers}\n'
      '├─ QueryParameters: ${options.queryParameters}\n'
      '${options.data != null ? '├─ Data: ${options.data}\n' : ''}'
      '└─────────────────────────────────────────────────────',
    );
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint(
      '┌─────────────────────────────────────────────────────\n'
      '│ 📥 RESPONSE\n'
      '├─ Status Code: ${response.statusCode}\n'
      '├─ URL: ${response.requestOptions.uri}\n'
      '├─ Data: ${response.data}\n'
      '└─────────────────────────────────────────────────────',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint(
      '┌─────────────────────────────────────────────────────\n'
      '│ ⚠️ ERROR\n'
      '├─ Type: ${err.type}\n'
      '├─ URL: ${err.requestOptions.uri}\n'
      '├─ Status Code: ${err.response?.statusCode}\n'
      '├─ Message: ${err.message}\n'
      '└─────────────────────────────────────────────────────',
    );
    handler.next(err);
  }
}

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    String errorMessage = 'An error occurred';

    if (err.type == DioExceptionType.connectionTimeout) {
      errorMessage = 'Connection timeout';
    } else if (err.type == DioExceptionType.receiveTimeout) {
      errorMessage = 'Receive timeout';
    } else if (err.type == DioExceptionType.badResponse) {
      errorMessage =
          'Error: ${err.response?.statusCode} - ${err.response?.statusMessage}';
    } else if (err.type == DioExceptionType.cancel) {
      errorMessage = 'Request cancelled';
    } else if (err.type == DioExceptionType.connectionError) {
      errorMessage = 'Connection error';
    }

    debugPrint('🔴 ERROR: $errorMessage');
    handler.next(err);
  }
}
