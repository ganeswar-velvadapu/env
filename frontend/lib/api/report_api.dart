import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ReportApi {
  static String baseUrl = '${dotenv.env["BACKEND_BASE_URL"]}/api';
  static final Dio dio = Dio(BaseOptions(baseUrl: baseUrl));

  static Future<Response> getAllReports() async {
    return await dio.get("/report");
  }

  static Future<Response> addReport(
    Map<String, dynamic> reportData,
    String token,
  ) async {
    try {
      final response = await dio.post(
        '/report',
        data: reportData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response;
    } catch (e) {
      print('Error adding report: $e');
      rethrow;
    }
  }

  static Future<Response> getUserReports(String token) async {
    return await dio.get(
      '/user/report',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  static Future<void> deleteReport(int reportId, String token) async {
    await dio.delete(
      '/report/$reportId',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  static Future<Response> updateReport(int id, Map<String, dynamic> updatedData, String token) async {
  return await dio.put(
    '/report/$id',
    data: updatedData,
    options: Options(headers: {
      'Authorization': 'Bearer $token',
    }),
  );
}


}
