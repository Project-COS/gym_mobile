import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_exception.dart';

typedef AccessTokenProvider = Future<String?> Function();

class ApiClient {
  ApiClient({
    required this.baseUri,
    http.Client? client,
    this.accessTokenProvider,
    this.timeout = const Duration(seconds: 15),
  }) : _client = client ?? http.Client();

  final Uri baseUri;
  final AccessTokenProvider? accessTokenProvider;
  final Duration timeout;
  final http.Client _client;

  Future<Object?> get(
    String path, {
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
    bool authenticated = true,
  }) {
    return _send(
      method: 'GET',
      path: path,
      queryParameters: queryParameters,
      headers: headers,
      authenticated: authenticated,
    );
  }

  Future<Object?> post(
    String path, {
    Object? body,
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
    bool authenticated = true,
  }) {
    return _send(
      method: 'POST',
      path: path,
      body: body,
      queryParameters: queryParameters,
      headers: headers,
      authenticated: authenticated,
    );
  }

  Future<Object?> put(
    String path, {
    Object? body,
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
    bool authenticated = true,
  }) {
    return _send(
      method: 'PUT',
      path: path,
      body: body,
      queryParameters: queryParameters,
      headers: headers,
      authenticated: authenticated,
    );
  }

  Future<Object?> patch(
    String path, {
    Object? body,
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
    bool authenticated = true,
  }) {
    return _send(
      method: 'PATCH',
      path: path,
      body: body,
      queryParameters: queryParameters,
      headers: headers,
      authenticated: authenticated,
    );
  }

  Future<Object?> delete(
    String path, {
    Object? body,
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
    bool authenticated = true,
  }) {
    return _send(
      method: 'DELETE',
      path: path,
      body: body,
      queryParameters: queryParameters,
      headers: headers,
      authenticated: authenticated,
    );
  }

  void close() {
    _client.close();
  }

  Future<Object?> _send({
    required String method,
    required String path,
    required bool authenticated,
    Object? body,
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
  }) async {
    final request = http.Request(method, _buildUri(path, queryParameters));

    request.headers.addAll(
      await _buildHeaders(
        headers: headers,
        authenticated: authenticated,
        hasBody: body != null,
      ),
    );

    if (body != null) {
      request.body = jsonEncode(body);
    }

    try {
      final response = await _sendRequest(request).timeout(timeout);
      final data = _decodeResponse(response);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException.fromResponse(
          statusCode: response.statusCode,
          data: data,
        );
      }

      return data;
    } on ApiException {
      rethrow;
    } on TimeoutException catch (error) {
      throw ApiException.timeout(cause: error);
    } on http.ClientException catch (error) {
      throw ApiException.network(cause: error);
    } on FormatException catch (error) {
      throw ApiException.invalidResponse(cause: error);
    }
  }

  Future<http.Response> _sendRequest(http.BaseRequest request) async {
    final streamedResponse = await _client.send(request);
    return http.Response.fromStream(streamedResponse);
  }

  Uri _buildUri(String path, Map<String, String>? queryParameters) {
    final base = baseUri.toString().endsWith('/')
        ? baseUri
        : Uri.parse('${baseUri.toString()}/');
    final normalizedPath = path.startsWith('/') ? path.substring(1) : path;
    final uri = base.resolve(normalizedPath);

    if (queryParameters == null || queryParameters.isEmpty) {
      return uri;
    }

    return uri.replace(
      queryParameters: {...uri.queryParameters, ...queryParameters},
    );
  }

  Future<Map<String, String>> _buildHeaders({
    required Map<String, String>? headers,
    required bool authenticated,
    required bool hasBody,
  }) async {
    final requestHeaders = <String, String>{
      'Accept': 'application/json',
      if (hasBody) 'Content-Type': 'application/json; charset=UTF-8',
      ...?headers,
    };

    if (authenticated && accessTokenProvider != null) {
      final token = (await accessTokenProvider!())?.trim();

      if (token != null && token.isNotEmpty) {
        requestHeaders['Authorization'] = 'Bearer $token';
      }
    }

    return requestHeaders;
  }

  Object? _decodeResponse(http.Response response) {
    final responseBody = utf8.decode(response.bodyBytes).trim();

    if (responseBody.isEmpty) {
      return null;
    }

    try {
      return jsonDecode(responseBody);
    } on FormatException {
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return responseBody;
      }

      rethrow;
    }
  }
}
