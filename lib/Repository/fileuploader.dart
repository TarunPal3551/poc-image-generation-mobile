
import 'dart:io';
import 'package:dio/dio.dart' as dio_response; 
import 'package:quick_pick/API_Service/baseservice.dart';

class FileUploadRepo {
  Future<String> uploadFile(File data) async {
    dio_response.Response response = await BaseService().postMultiPartData(
      endPoint: 'uploadFiles',
      isTokenRequired: true,
      files: {
        "file": data,
      },
      body: {},
    );
    if (response.statusCode == 200) {
      return response.data["data"][0]["path"];
    } else {
      return "";
    }
  }
}