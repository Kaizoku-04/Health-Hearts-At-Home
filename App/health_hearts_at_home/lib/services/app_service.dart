import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../models/child_model.dart';
import '../models/tracking_model.dart';
import '../models/content_model.dart';
import 'api_service.dart';

class AppService extends ChangeNotifier {
  final ApiService api;

  String _currentLanguage = 'en';
  Child? _currentChild;
  List<ChildTracking> _trackingData = [];
  List<ContentItem> _contentItems = [];
  bool _isLoading = false;
  String? _errorMessage;

  AppService({required this.api});

  // Getters
  String get currentLanguage => _currentLanguage;
  Child? get currentChild => _currentChild;
  List<ChildTracking> get trackingData => _trackingData;
  List<ContentItem> get contentItems => _contentItems;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void toggleLanguage() {
    _currentLanguage = _currentLanguage == 'en' ? 'ar' : 'en';
    notifyListeners();
  }

  // ✅ Fetch all children
  Future<List<Child>> fetchChildren() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await api.get('/api/children');

      List<Child> children = (response as List)
          .map((item) => Child.fromJson(item as Map<String, dynamic>))
          .toList();

      _isLoading = false;
      notifyListeners();
      return children;
    } on DioException catch (e) {
      _isLoading = false;
      _errorMessage = _getDioErrorMessage(e);
      notifyListeners();
      debugPrint('Dio Error: $_errorMessage');
      return [];
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return [];
    }
  }

  // ✅ Fetch tracking data
  Future<void> fetchTrackingData(String childId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await api.get('/api/tracking/$childId');

      _trackingData = (response as List)
          .map((item) => ChildTracking.fromJson(item as Map<String, dynamic>))
          .toList();

      _isLoading = false;
      notifyListeners();
    } on DioException catch (e) {
      _isLoading = false;
      _errorMessage = _getDioErrorMessage(e);
      notifyListeners();
    }
  }

  // ✅ Add tracking entry
  Future<bool> addTrackingEntry(ChildTracking entry) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await api.post('/api/tracking', data: entry.toJson());

      _trackingData.insert(0, entry);
      _isLoading = false;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _isLoading = false;
      _errorMessage = _getDioErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  // ✅ Update tracking entry
  Future<bool> updateTrackingEntry(ChildTracking entry) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await api.put('/api/tracking/${entry.id}', data: entry.toJson());

      int index = _trackingData.indexWhere((t) => t.id == entry.id);
      if (index != -1) {
        _trackingData[index] = entry;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _isLoading = false;
      _errorMessage = _getDioErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  // ✅ Delete tracking entry
  Future<bool> deleteTrackingEntry(String entryId) async {
    try {
      await api.delete('/api/tracking/$entryId');

      _trackingData.removeWhere((t) => t.id == entryId);
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _errorMessage = _getDioErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  // ✅ Fetch content by category
  Future<void> fetchContent(String category) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await api.get(
        '/api/content',
        queryParameters: {'category': category, 'language': _currentLanguage},
      );

      _contentItems = (response as List)
          .map((item) => ContentItem.fromJson(item as Map<String, dynamic>))
          .toList();

      _isLoading = false;
      notifyListeners();
    } on DioException catch (e) {
      _isLoading = false;
      _errorMessage = _getDioErrorMessage(e);
      notifyListeners();
    }
  }

  // ✅ Fetch tutorials
  Future<void> fetchTutorials() async {
    await fetchContent('tutorials');
  }

  // ✅ Fetch spiritual content
  Future<void> fetchSpiritualContent() async {
    await fetchContent('spiritual');
  }

  // ✅ Fetch hospital info
  Future<Map<String, dynamic>> fetchHospitalInfo() async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await api.get('/api/hospital-info');

      _isLoading = false;
      notifyListeners();
      return response as Map<String, dynamic>;
    } on DioException catch (e) {
      _isLoading = false;
      _errorMessage = _getDioErrorMessage(e);
      notifyListeners();
      return {};
    }
  }

  // ✅ Fetch contacts
  Future<List<Map<String, dynamic>>> fetchContacts() async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await api.get('/api/contacts');

      _isLoading = false;
      notifyListeners();
      return List<Map<String, dynamic>>.from(response);
    } on DioException catch (e) {
      _isLoading = false;
      _errorMessage = _getDioErrorMessage(e);
      notifyListeners();
      return [];
    }
  }

  // ✅ Helper method to convert DioException to readable message
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
        return 'Unknown error occurred.';
      default:
        return 'An error occurred: ${e.message}';
    }
  }

  // ✅ Set auth token (call this after user login)
  void setAuthToken(String token) {
    api.setAuthToken(token);
  }

  // ✅ Remove auth token (call this on logout)
  void removeAuthToken() {
    api.removeAuthToken();
  }

  void setLanguage(String languageCode) {
    _currentLanguage = languageCode; // Or however you store your language variable
    notifyListeners(); // Important to update the UI
  }
}
