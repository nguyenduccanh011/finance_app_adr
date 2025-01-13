import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:provider/provider.dart';

import '../main.dart';
import '../providers/auth_provider.dart';

class ApiClient {
  final String baseUrl;

  ApiClient({required this.baseUrl});

  Future<List<dynamic>> get(String endpoint,
      {Map<String, String>? headers,
        Map<String, dynamic>? queryParameters}) async {
    final url = Uri.parse('$baseUrl$endpoint')
        .replace(queryParameters: queryParameters);
    final response = await http.get(url, headers: headers);
    return _handleResponse(response);
  }

  Future<dynamic> post(String endpoint,
      {Map<String, String>? headers, dynamic body}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final updatedHeaders = {
      ...?headers,
      'Content-Type': 'application/json',
    };
    print('Updated headers in post: $updatedHeaders');
    final response =
    await http.post(url, headers: updatedHeaders, body: jsonEncode(body));
    return _handleResponse(response);
  }

  Future<dynamic> put(String endpoint,
      {Map<String, String>? headers, dynamic body}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final updatedHeaders = {
      ...?headers,
      'Content-Type': 'application/json',
    };
    final response =
    await http.put(url, headers: updatedHeaders, body: jsonEncode(body)); // Sửa thành updatedHeaders
    return _handleResponse(response);
  }

  Future<dynamic> delete(String endpoint,
      {Map<String, String>? headers}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final response = await http.delete(url, headers: headers);
    return _handleResponse(response);
  }

  Future<dynamic> postMultipart(String endpoint,
      {Map<String, String>? headers,
        required Map<String, String> fields,
        required List<http.MultipartFile> files}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    var request = http.MultipartRequest('POST', url);

    if (headers != null) {
      request.headers.addAll(headers);
    }

    request.fields.addAll(fields);
    request.files.addAll(files);

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    return _handleResponse(response);
  }

  dynamic _handleResponse(http.Response response) {
    print('Response status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isNotEmpty) {
        final data = jsonDecode(response.body);
        print('Data type in _handleResponse: ${data.runtimeType}'); // Thêm dòng này
        return data;
      } else {
        return {};
      }
    } else {
      // Xử lý lỗi
      print("Error response body: ${response.body}");
      if (response.statusCode == 401) {
        // Token hết hạn hoặc không hợp lệ
        final authProvider =
        Provider.of<AuthProvider>(navigatorKey.currentContext!, listen: false);
        authProvider.clearToken();

        // Chuyển hướng đến màn hình đăng nhập
        Navigator.pushNamedAndRemoveUntil(
          navigatorKey.currentContext!,
          '/login',
              (route) => false,
        );

        throw ApiException('Token hết hạn hoặc không hợp lệ',
            statusCode: response.statusCode);
      } else if (response.body.isNotEmpty) {
        throw ApiException.fromJson(jsonDecode(response.body));
      } else {
        throw ApiException('Unknown error', statusCode: response.statusCode);
      }
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  factory ApiException.fromJson(Map<String, dynamic> json) {
    return ApiException(json['message'] ?? 'Unknown error',
        statusCode: json['statusCode']);
  }

  @override
  String toString() => 'ApiException: $message (Status Code: $statusCode)';
}
