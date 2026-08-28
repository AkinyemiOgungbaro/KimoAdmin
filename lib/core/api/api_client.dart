import 'package:dio/dio.dart';
import '../config.dart';
import 'api_exception.dart';
import 'token_store.dart';

/// Thin wrapper around a single [Dio] instance.
///
/// - A request interceptor attaches `Authorization: Bearer <access>`.
/// - An error interceptor catches `401` on non-auth paths, performs a
///   **single-flight** token refresh (via a separate bare Dio so it can't
///   recurse through this interceptor), retries the original request once, and
///   — if refresh fails — clears tokens and fires [onSessionExpired].
///
/// The `get`/`post`/`patch`/`delete` helpers unwrap the `{"message","data"}`
/// envelope and return the `data` payload, throwing [ApiException] on failure.
class ApiClient {
  final TokenStore _tokenStore;
  late final Dio _dio;
  late final Dio _refreshDio;

  /// Invoked when the session cannot be recovered (refresh failed).
  void Function()? onSessionExpired;

  ApiClient(this._tokenStore) {
    BaseOptions options() => BaseOptions(
          baseUrl: AppConfig.apiBaseUrl,
          connectTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 30),
          contentType: Headers.jsonContentType,
        );
    _dio = Dio(options());
    _refreshDio = Dio(options());

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _tokenStore.accessToken;
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (e, handler) async {
          final req = e.requestOptions;
          final isAuthPath = req.path.contains('/admin/auth/');
          final alreadyRetried = req.extra['__retried'] == true;
          if (e.response?.statusCode == 401 && !isAuthPath && !alreadyRetried) {
            try {
              final newToken = await _refreshToken();
              final retried = await _retry(req, newToken);
              return handler.resolve(retried);
            } catch (_) {
              await _tokenStore.clear();
              onSessionExpired?.call();
            }
          }
          handler.next(e);
        },
      ),
    );
  }

  Dio get dio => _dio;

  // ---- token refresh (single-flight) --------------------------------------

  Future<String>? _refreshFuture;

  Future<String> _refreshToken() {
    return _refreshFuture ??= _doRefresh().whenComplete(() => _refreshFuture = null);
  }

  Future<String> _doRefresh() async {
    final refresh = _tokenStore.refreshToken;
    if (refresh == null || refresh.isEmpty) {
      throw ApiException('No refresh token', statusCode: 401);
    }
    final res = await _refreshDio.post('/admin/auth/refresh', data: {'refresh_token': refresh});
    final data = (res.data['data'] ?? res.data) as Map<String, dynamic>;
    final access = data['access_token'] as String;
    final newRefresh = data['refresh_token'] as String?;
    if (newRefresh != null && newRefresh.isNotEmpty) {
      await _tokenStore.saveTokens(access: access, refresh: newRefresh);
    } else {
      await _tokenStore.saveAccess(access);
    }
    return access;
  }

  Future<Response<dynamic>> _retry(RequestOptions o, String token) {
    return _dio.request<dynamic>(
      o.path,
      data: o.data,
      queryParameters: o.queryParameters,
      options: Options(
        method: o.method,
        headers: {...o.headers, 'Authorization': 'Bearer $token'},
        contentType: o.contentType,
        responseType: o.responseType,
        extra: {...o.extra, '__retried': true},
      ),
    );
  }

  // ---- verb helpers (return unwrapped `data`) ------------------------------

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) =>
      _send(() => _dio.get<dynamic>(path, queryParameters: query));

  Future<dynamic> post(String path, {dynamic data}) =>
      _send(() => _dio.post<dynamic>(path, data: data));

  Future<dynamic> patch(String path, {dynamic data}) =>
      _send(() => _dio.patch<dynamic>(path, data: data));

  Future<dynamic> delete(String path, {dynamic data}) =>
      _send(() => _dio.delete<dynamic>(path, data: data));

  Future<dynamic> _send(Future<Response<dynamic>> Function() run) async {
    try {
      final res = await run();
      final data = res.data;
      if (data is Map && data.containsKey('data')) return data['data'];
      return data;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// Raw GET, e.g. for CSV export. Returns the full [Response].
  Future<Response<T>> getRaw<T>(
    String path, {
    Map<String, dynamic>? query,
    ResponseType responseType = ResponseType.plain,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: query,
        options: Options(responseType: responseType),
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
