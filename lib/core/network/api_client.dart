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
    return _requestWithRefresh(
      () => dio.post<T>(
        '',
        data: {'query': query, if (variables != null) 'variables': variables},
      ),
    );
  }

  Future<Response<T>> _requestWithRefresh<T>(
    Future<Response<T>> Function() request,
  ) async {
    try {
      return await request();
    } on DioException catch (error) {
      if (error.response?.statusCode != 401 || _refreshAuthToken == null) {
        rethrow;
      }

      final token = await _refreshAuthToken!.call();
      if (token == null || token.isEmpty) {
        rethrow;
      }
      setAuthToken(token);
      return request();
    }
  }
}
