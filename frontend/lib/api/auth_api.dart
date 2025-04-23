import 'package:dio/dio.dart';

class AuthApi {
  static const String baseUrl = 'http://192.168.0.102:8000/api/auth';
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
