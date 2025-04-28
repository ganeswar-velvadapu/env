import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EventApi {
  static String baseUrl = '${dotenv.env["BACKEND_BASE_URL"]}/api';
  static final Dio dio = Dio(BaseOptions(baseUrl: baseUrl));

  // Fetch all events
  static Future<Response> getAllEvents() async {
    return await dio.get('/events');
  }


  static Future<Response> addEvent(
    Map<String, dynamic> eventData,
    String token,
  ) async {
    try {
      final response = await dio.post(
        '/events',
        data: eventData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response;
    } catch (e) {
      print('Error adding event: $e'); 
      rethrow;
    }
  }

  static Future<Response> editEvent(
    Map<String, dynamic> eventData,
    String token,
    int id,
  ) async {
    try {
      final response = await dio.put(
        '/events/$id',
        data: eventData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response;
    } catch (e) {
      print('Error editing event: $e');
      rethrow;
    }
  }

  static Future<Response> deleteEvent(String token, int id) async {
    try {
      final response = await dio.delete(
        '/events/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response;
    } catch (e) {
      print('Error deleting event: $e');
      rethrow;
    }
  }
}
