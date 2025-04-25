import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthApi {


  static String baseUrl = '${dotenv.env["BACKEND_BASE_URL"]}/api/auth';
  static final Dio dio = Dio(BaseOptions(baseUrl: baseUrl));

  static Future<Response> login(String email, String password) async {
  return await dio.post('/login', data: {
    'email': email,
    'password': password,
  });
}

static Future<Response> signup(String email, String password) async {
  return await dio.post('/signup', data: {
    'email': email,
    'password': password,
  });
}
}
