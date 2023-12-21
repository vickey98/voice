import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../api_util.dart';

class ApiConfig {
  static const String baseUrl =
      "http://localhost:8080/api/";

  static final ApiConfig _instance = ApiConfig._internal();

  factory ApiConfig() => _instance;

  ApiConfig._internal();

  late String _baseUrl;

  late Map<String, String> _headers;

  init(String baseUrl) {
    _baseUrl = baseUrl;
    _headers = {
      "Content-Type": "application/json",
      'Accept': 'application/json',
      'grant_type': 'client_credentials',
      "Access-Control-Allow-Origin": "*",
      // Required for CORS support to work
      "Access-Control-Allow-Credentials": "true",
      // Required for cookies, authorization headers with HTTPS
      "Access-Control-Allow-Headers":
          "Origin,Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,locale",
      "Access-Control-Allow-Methods": "POST, OPTIONS"
    };
  }

  updateHeaders({String? token}) {
    _headers['Authorization'] = token ?? '';
  }

  removeAuthHeader() {
    if (_headers.containsKey('Authorization')) {
      _headers.removeWhere((key, value) => key == 'Authorization');
    }
  }

  @pragma('vm:entry-point')
  Future<http.Response> get(
    String path,
  ) async {
    log('******  get request :  $path  ******');
    late http.Response res;
    try {
      res = await http.get(Uri.parse(_baseUrl + path), headers: _headers);
      log('getRequestStatusCode : ${res.statusCode}');
    } catch (e) {
      return http.Response(
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
        },
        json.encode({'status': false, 'message': "server failed"}),
        500,
      );
    }

    log('response body : ${res.body}');
    log('******  get request end : $path  ******');

    return await ApiUtil.getResponseWithCode(res: res, path: _baseUrl + path);
  }

  ///give [path]
  @pragma('vm:entry-point')
  Future<http.Response> post(String path, Object body,
      {bool refreshToken = true}) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      log('\n\n**********  post request START :  $baseUrl$path  **********\n');
      log('postRequestBody : $body');
      log('postRequestHeader : $_headers');
      late http.Response res;
      try {
        res = await http.post(Uri.parse(_baseUrl + path),
            body: jsonEncode(body), headers: _headers);
        log('postRequestStatusCode : ${res.statusCode}');
      } catch (e) {
        return http.Response(
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
          },
          json.encode({'status': false, 'message': "server failed"}),
          500,
        );
      }

      return await ApiUtil.getResponseWithCode(
          res: res, path: _baseUrl + path, requestBody: body);
    } else {
      Get.snackbar("Error", "Unable to connect internet");
      return http.Response(
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
        },
        json.encode({'status': false, 'message': "searver failed"}),
        500,
      );
    }
  }
}
