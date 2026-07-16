import 'package:dio/dio.dart';

import '../config/app_config.dart';

class ApiClient {
  ApiClient({Dio? dio})
    : dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: AppConfig.apiBaseUrl,
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 15),
              headers: const {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
              },
            ),
          );

  final Dio dio;
  Future<String?> Function()? _refreshAuthToken;

  void setAuthToken(String? token) {
    if (token == null || token.isEmpty) {
      dio.options.headers.remove('Authorization');
      return;
    }

    dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void setRefreshAuthTokenHandler(Future<String?> Function()? handler) {
    _refreshAuthToken = handler;
  }

  Future<Response<T>> postGraphQL<T>(
    String query, {
    Map<String, dynamic>? variables,
  }) {
    return _requestWithRefresh<T>(
      () => dio.post<T>(
        '',
        data: {'query': query, if (variables != null) 'variables': variables},
      ),
      shouldRefresh: _hasGraphQLAuthError,
    );
  }

  Future<Response<T>> _requestWithRefresh<T>(
    Future<Response<T>> Function() request, {
    bool Function(Response<T> response)? shouldRefresh,
  }) async {
    await _refreshIfAuthHeaderMissing();
    try {
      final response = await request();
      if (shouldRefresh?.call(response) ?? false) {
        final token = await _refreshAndSetAuthToken();
        if (token != null) {
          return request();
        }
      }
      return response;
    } on DioException catch (error) {
      if (error.response?.statusCode != 401 || _refreshAuthToken == null) {
        rethrow;
      }

      final token = await _refreshAndSetAuthToken();
      if (token == null) {
        rethrow;
      }
      return request();
    }
  }

  Future<void> _refreshIfAuthHeaderMissing() async {
    if (_refreshAuthToken == null || _hasAuthHeader) {
      return;
    }
    await _refreshAndSetAuthToken();
  }

  Future<String?> _refreshAndSetAuthToken() async {
    final token = await _refreshAuthToken?.call();
    if (token == null || token.isEmpty) {
      return null;
    }
    setAuthToken(token);
    return token;
  }

  bool get _hasAuthHeader {
    final value = dio.options.headers['Authorization'];
    return value is String && value.trim().isNotEmpty;
  }

  bool _hasGraphQLAuthError<T>(Response<T> response) {
    final data = response.data;
    if (data is! Map) {
      return false;
    }
    final errors = data['errors'];
    if (errors is! List) {
      return false;
    }
    return errors.any((error) {
      if (error is! Map) {
        return false;
      }
      final message = (error['message'] as String?)?.toLowerCase() ?? '';
      final extensions = error['extensions'];
      final code =
          extensions is Map
              ? (extensions['code'] as String?)?.toUpperCase()
              : null;
      return code == 'UNAUTHENTICATED' ||
          message.contains('missing bearer token') ||
          message.contains('invalid or expired authentication token');
    });
  }
}
