import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:voice_app/app/data/model/katakana_request_model.dart';
import 'package:voice_app/app/data/model/katakana_response_model.dart';

import '../config/api_config.dart';

class ApiService extends GetxService {
  ApiConfig apiConfig = ApiConfig();

  Future<ApiService> init() async {
    apiConfig.init(ApiConfig.baseUrl);
    return this;
  }

  Future<KatakanaResponseModel> getKatakanaText(
      {required KatakanaRequestModel requestModel}) async {
    KatakanaResponseModel response;
    final http.Response res =
        await apiConfig.post('convert', requestModel.toJson());
    response = KatakanaResponseModel.fromJson(json.decode(res.body));
    return response;
  }
}
