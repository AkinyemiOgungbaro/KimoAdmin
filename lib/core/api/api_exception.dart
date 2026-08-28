import 'package:dio/dio.dart';

/// A normalised error surfaced to the UI. Wraps the backend's `{"message": …}`
/// error envelope and network/timeout failures behind a single type.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  factory ApiException.fromDio(DioException e) {
    final res = e.response;
    if (res != null) {
      String? msg;
      final data = res.data;
      if (data is Map && data['message'] is String) {
        msg = data['message'] as String;
      }
      return ApiException(msg ?? _statusMessage(res.statusCode), statusCode: res.statusCode);
    }
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException('The request timed out. Please try again.');
      case DioExceptionType.connectionError:
        return ApiException('Cannot reach the server. Check your connection and that the API is running.');
      case DioExceptionType.cancel:
        return ApiException('Request cancelled.');
      default:
        return ApiException(e.message ?? 'Something went wrong.');
    }
  }

  static String _statusMessage(int? code) {
    switch (code) {
      case 400:
        return 'Bad request.';
      case 401:
        return 'Your session has expired. Please sign in again.';
      case 403:
        return 'You do not have permission to do that.';
      case 404:
        return 'Not found.';
      case 409:
        return 'That conflicts with existing data.';
      case 422:
        return 'Some fields are invalid.';
      case 500:
      case 502:
      case 503:
        return 'Server error. Please try again later.';
      default:
        return 'Something went wrong.';
    }
  }

  @override
  String toString() => message;
}
