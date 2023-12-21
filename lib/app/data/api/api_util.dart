import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../model/common_response.dart';

class ApiUtil {
  static Future<http.Response> getResponseWithCode(
      {required http.Response res,
      required String path,
      Object? requestBody}) async {
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 500) {
      return http.Response(
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
        },
        json.encode({'status': false, 'message': "internal server error"}),
        500,
      );
    } else {
      String message = await otherStatusCodeHandle(res);
      message += res.statusCode.toString();

      return http.Response(
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
        },
        json.encode({'status': false, 'message': message}),
        res.statusCode,
      );
    }
  }

  static Future<String> otherStatusCodeHandle(http.Response res) async {
    try {
      CommonResponse response = CommonResponse.fromJson(json.decode(res.body));
      return response.message ?? "";
    } catch (e) {
      debugPrint("***other status code catch error : ${e.toString()}");
      return "server failed";
    }
  }
}
