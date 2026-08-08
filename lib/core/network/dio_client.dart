import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:ecom/core/constants/api_constants.dart';

class DioClient {
  final Dio dio;

  DioClient() : dio = Dio(
         BaseOptions(
           baseUrl: ApiConstants.baseUrl,
           connectTimeout: ApiConstants.connectTimeout,
           receiveTimeout: ApiConstants.receiveTimeout,
         ),
       ) {
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(requestBody: false, responseBody: false),
      );
    }
  }
}
