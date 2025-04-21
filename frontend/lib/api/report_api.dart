import 'package:dio/dio.dart';

class ReportApi {

  static const String BaseUrl = "http://192.168.23.186:8000/api";
  static final Dio dio = Dio(BaseOptions(baseUrl: BaseUrl));


  static Future<Response> getAllReports()  async{
    return await dio.get("/report");
  }

    static Future<Response> postReport(Map<String, dynamic> reportData) async {
    return await dio.post("/report", data: reportData);
  }

}