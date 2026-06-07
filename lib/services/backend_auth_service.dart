import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants.dart';

class BackendAuthService {
  BackendAuthService._();

  static const _accessTokenKey = 'backend_access_token';
  static const _refreshTokenKey = 'backend_refresh_token';
  static const _uidKey = 'backend_uid';
  static const _roleKey = 'backend_role';
  static const _nicknameKey = 'backend_nickname';
  static const _nameKey = 'backend_name';
  static const _emailKey = 'backend_email';

  static Dio get _dio => Dio(
        BaseOptions(
          baseUrl: AppConstants.apiBaseUrl,
          connectTimeout: const Duration(seconds: 6),
          receiveTimeout: const Duration(seconds: 8),
        ),
      );

  static bool get isEnabled => AppConstants.apiBaseUrl.isNotEmpty;

  static Future<String?> currentRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_roleKey);
  }

  static Future<void> signUpAndLogin({
    required String email,
    required String password,
    required String nickname,
    String role = 'elder',
    String? linkCode,
  }) async {
    if (!isEnabled) return;

    final response = await _dio.post<Map<String, dynamic>>(
      '/signup',
      queryParameters: {
        'email': email,
        'role': role,
        'nickname': nickname,
        'password': password,
        if (linkCode != null) 'link_code': linkCode,
      },
    );

    final data = response.data ?? const <String, dynamic>{};
    final status = data['status']?.toString();
    final message = data['message']?.toString() ?? '';
    if (status != null && status != 'success' && !message.contains('이미 존재')) {
      throw Exception(message.isEmpty ? '백엔드 회원가입에 실패했습니다.' : message);
    }

    await login(email: email, password: password);
  }

  static Future<void> login({
    required String email,
    required String password,
  }) async {
    if (!isEnabled) return;

    final response = await _dio.post<Map<String, dynamic>>(
      '/login',
      queryParameters: {
        'email': email,
        'password': password,
      },
    );

    final data = response.data ?? const <String, dynamic>{};
    if (data['status'] != 'success') {
      throw Exception(data['message']?.toString() ?? '백엔드 로그인에 실패했습니다.');
    }

    final tokens = data['tokens'];
    final userInfo = data['user_info'];
    if (tokens is! Map || userInfo is! Map) {
      throw Exception('백엔드 로그인 응답 형식이 올바르지 않습니다.');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, tokens['access_token'].toString());
    await prefs.setString(_refreshTokenKey, tokens['refresh_token'].toString());
    await prefs.setString(_uidKey, userInfo['uid'].toString());
    await prefs.setString(_roleKey, userInfo['role']?.toString() ?? '');
    await prefs.setString(_nicknameKey, userInfo['nickname']?.toString() ?? '');
    await prefs.setString(_nameKey, userInfo['name']?.toString() ?? '');
    await prefs.setString(_emailKey, email);
  }

  static Future<bool> hasSession() async {
    final token = await accessToken();
    if (token == null || token.isEmpty) return false;

    try {
      await _dio.get<Map<String, dynamic>>(
        '/profile',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return true;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await clear();
        return false;
      }
      return true;
    }
  }

  static Future<String?> accessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  static Future<String?> currentEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailKey);
  }

  static Future<String?> currentNickname() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_nicknameKey);
  }

  static Future<String?> currentName() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_nameKey);
    if (name != null && name.isNotEmpty) return name;
    return prefs.getString(_nicknameKey);
  }

  static Future<String?> currentUid() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_uidKey);
  }

  static Future<void> saveNickname(String nickname) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nicknameKey, nickname);
  }

  static Future<String> uidOrFallback() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_uidKey) ?? AppConstants.backendTestUid;
  }

  static Future<Options?> authOptions() async {
    final token = await accessToken();
    if (token == null || token.isEmpty) return null;
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.remove(_accessTokenKey),
      prefs.remove(_refreshTokenKey),
      prefs.remove(_uidKey),
      prefs.remove(_roleKey),
      prefs.remove(_nicknameKey),
      prefs.remove(_emailKey),
    ]);
  }
}
