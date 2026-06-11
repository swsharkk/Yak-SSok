import 'dart:math';

import 'package:dio/dio.dart';

import '../core/constants.dart';
import '../models/pharmacy.dart';

class PharmacyService {
  PharmacyService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: 'https://openapi.naver.com',
                connectTimeout: const Duration(seconds: 6),
                receiveTimeout: const Duration(seconds: 8),
              ),
            );

  final Dio _dio;

  Future<List<Pharmacy>> searchNearby({
    required double latitude,
    required double longitude,
    String? regionKeyword,
    int limit = 5,
  }) async {
    if (AppConstants.naverSearchClientId.isEmpty ||
        AppConstants.naverSearchClientSecret.isEmpty) {
      return const [];
    }

    // 네이버 지역검색은 좌표 필터를 지원하지 않으므로 지역명을 검색어에 포함한다.
    final query = (regionKeyword != null && regionKeyword.trim().isNotEmpty)
        ? '${regionKeyword.trim()} 약국'
        : '약국';

    final response = await _dio.get<Map<String, dynamic>>(
      '/v1/search/local.json',
      queryParameters: {
        'query': query,
        // local.json 의 display 최대값은 5.
        'display': limit.clamp(1, 5),
        'start': 1,
        'sort': 'random',
      },
      options: Options(
        headers: {
          'X-Naver-Client-Id': AppConstants.naverSearchClientId,
          'X-Naver-Client-Secret': AppConstants.naverSearchClientSecret,
        },
      ),
    );

    final items = response.data?['items'];
    if (items is! List) return const [];

    final pharmacies = items
        .whereType<Map<String, dynamic>>()
        .map((item) => _mapItem(item, latitude, longitude))
        .where((pharmacy) => pharmacy.name.isNotEmpty)
        .toList(growable: false);

    return pharmacies
      ..sort((a, b) => (a.distanceMeters ?? double.infinity)
          .compareTo(b.distanceMeters ?? double.infinity));
  }

  Pharmacy _mapItem(
    Map<String, dynamic> json,
    double currentLat,
    double currentLng,
  ) {
    final lat = _coordinate(json['mapy']);
    final lng = _coordinate(json['mapx']);
    final distance = lat == null || lng == null
        ? null
        : _distanceMeters(currentLat, currentLng, lat, lng);

    final name = _clean(json['title']?.toString() ?? '');
    final address = _clean(
      json['roadAddress']?.toString().isNotEmpty == true
          ? json['roadAddress'].toString()
          : json['address']?.toString() ?? '',
    );
    final phone = _clean(json['telephone']?.toString() ?? '');

    return Pharmacy(
      id: json['link']?.toString().isNotEmpty == true
          ? json['link'].toString()
          : '$name-${lat ?? ''}-${lng ?? ''}',
      name: name,
      latitude: lat ?? currentLat,
      longitude: lng ?? currentLng,
      address: address.isEmpty ? null : address,
      phone: phone.isEmpty ? null : phone,
      distanceMeters: distance,
    );
  }

  double? _coordinate(Object? raw) {
    final value = double.tryParse(raw?.toString() ?? '');
    if (value == null) return null;
    return value / 10000000;
  }

  String _clean(String value) {
    return value
        .replaceAll(RegExp('<[^>]*>'), '')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .trim();
  }

  double _distanceMeters(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    const earthRadius = 6371000.0;
    final dLat = _radians(lat2 - lat1);
    final dLng = _radians(lng2 - lng1);
    final a = pow(sin(dLat / 2), 2) +
        cos(_radians(lat1)) * cos(_radians(lat2)) * pow(sin(dLng / 2), 2);
    return earthRadius * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  double _radians(double degrees) => degrees * pi / 180;
}
