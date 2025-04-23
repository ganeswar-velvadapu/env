import 'package:dio/dio.dart';

class ReportApi {
  static const String BaseUrl = "http://172.24.82.107:8000/api";
  static final Dio dio = Dio(BaseOptions(baseUrl: BaseUrl));

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
