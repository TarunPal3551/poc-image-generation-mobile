// ignore_for_file: implementation_imports

import 'dart:developer';
import 'dart:io';
// import 'package:apnabillbook/components/utils_widget.dart';
// import 'package:apnabillbook/configs/page_routes.dart';
// import 'package:apnabillbook/configs/session_manager.dart';
// import 'package:apnabillbook/controllers/store_controller.dart';
import 'package:dio/dio.dart';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/foundation.dart';
// import 'package:dio/src/response.dart' as dio_response;
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:get/get.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:pretty_dio_logger/pretty_dio_logger.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:apnabillbook/api_routes.dart';
// import 'package:apnabillbook/config.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:apnabillbook/models/addressmap/address_predictions.dart';
// import 'package:apnabillbook/models/addressmap/map_address.dart';

// import '../components/DialogTracker.dart';
// import '../screens/splash_screen.dart';

class BaseService extends GetxService {
  BaseService();

  // static Dio _dioGoogleAddress() {
  //   return Dio(
  //     BaseOptions(
  //       baseUrl: ApiRoutes.googleBaseUrl,
  //       headers: {
  //         Headers.acceptHeader: Headers.jsonContentType,
  //       },
  //     ),
  //   )..interceptors.addAll([
  //       PrettyDioLogger(
  //           requestBody: true, requestHeader: true, responseBody: true)
  //     ]);
  // }

  // static Dio _dioPlaceAddress() {
  //   return Dio(
  //     BaseOptions(baseUrl: ApiRoutes.googlePlaceBaseUrl, headers: {
  //       Headers.acceptHeader: Headers.jsonContentType,
  //     }),
  //   )..interceptors.addAll([
  //       PrettyDioLogger(
  //           requestBody: true, requestHeader: true, responseBody: true)
  //     ]);
  // }

  postMultiPartData({
    required String endPoint,
    required bool isTokenRequired,
    required Map<String, dynamic>? body,
    Map<String, File>? files,
  }) async {
    try {
      // sharedPreferences ??= await SharedPreferences.getInstance();
      // String token = sharedPreferences!.getString(WebXConfig.TOKEN) ?? '';
      String token = '';
      // create form data body
      dio.FormData formData = dio.FormData.fromMap(body!);
      // add files in form data
      files?.forEach((key, value) async {
        try {
          formData.files.add(
            MapEntry(
              key,
              await dio.MultipartFile.fromFile(
                value.path,
                filename: value.path.split("/").last,
              ),
            ),
          );
        } catch (e) {
          log(e.toString());
        }
      });
      dio.Response response = await _dioMultiPart(
        token,
      ).post(endPoint, data: formData);
      return response;
    } on dio.DioError catch (e) {
      // throw error
      return Future.error(e);
    }
  }

  static Dio _dioMultiPart(String? accessToken) {
    Dio dio = Dio();
    dio.options.baseUrl = 'https://dev.apnabillbook.com/api/';
    dio.options.headers = {
      'Authorization': 'Bearer $accessToken',
      Headers.acceptHeader: Headers.jsonContentType,
      'Content-Type': 'multipart/form-data',
      'os': '',
    };
    if (kDebugMode) {
      dio.interceptors.add(
        PrettyDioLogger(
          requestBody: true,
          requestHeader: true,
          responseBody: true,
        ),
      );
    }
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = '';
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (DioError error, ErrorInterceptorHandler handler) async {
          if (!handler.isCompleted) {
            return handler.next(error);
          }
        },
      ),
    );

    return dio;
  }
}
