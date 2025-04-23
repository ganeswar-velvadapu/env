import 'package:dio/dio.dart';

class ReportApi {
  static const String BaseUrl = "http://192.168.23.186:8000/api";
  static final Dio dio = Dio(BaseOptions(baseUrl: BaseUrl));

  static Future<Response> getAllReports() async {
    return await dio.get("/report");
  }

 static Future<Response> addReport(Map<String, dynamic> reportData, String token) async {
  try {
    final response = await dio.post(
      '/report',
      data: reportData,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
    return response;
  } catch (e) {
    print('Error adding report: $e');
    rethrow;
  }
}

}
