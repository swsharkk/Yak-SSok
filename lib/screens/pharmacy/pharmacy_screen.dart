import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../models/pharmacy.dart';
import '../../services/pharmacy_service.dart';

class PharmacyScreen extends StatefulWidget {
  const PharmacyScreen({super.key});

  @override
  State<PharmacyScreen> createState() => _PharmacyScreenState();
}

class _PharmacyScreenState extends State<PharmacyScreen> {
  final _pharmacyService = PharmacyService();
  NaverMapController? _mapController;
  Position? _currentPosition;
  double _compassHeading = 0;
  bool _locationLoading = true;
  String _locationLabel = '위치 확인 중...';
  StreamSubscription<MagnetometerEvent>? _magnetometerSub;
  List<Pharmacy> _pharmacies = [];
  Pharmacy? _nearestPharmacy;

  @override
  void initState() {
    super.initState();
    _initLocation();
    _initCompass();
  }

  @override
  void dispose() {
    _magnetometerSub?.cancel();
    super.dispose();
  }

  static const double _defaultLat = 37.5665;
  static const double _defaultLng = 126.9780;

  Future<void> _initLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _useDefaultLocation('위치 서비스를 켜주세요 (서울 기준 표시)');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _useDefaultLocation('위치 권한 없음 (서울 기준 표시)');
          return;
        }
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final region = await _regionKeyword(pos.latitude, pos.longitude);

      setState(() {
        _currentPosition = pos;
        _locationLabel = region != null ? '$region 기준' : '현재 위치 확인됨';
      });

      _mapController?.updateCamera(
        NCameraUpdate.withParams(
          target: NLatLng(pos.latitude, pos.longitude),
          zoom: 15,
        ),
      );

      await _loadPharmacies(pos.latitude, pos.longitude, regionKeyword: region);
    } catch (e) {
      _useDefaultLocation('위치를 가져올 수 없음 (서울 기준 표시)');
    }
  }

  /// GPS 좌표를 "수원시 영통구" 같은 지역명으로 변환한다.
  /// 네이버 지역검색이 좌표를 못 받기 때문에 검색어에 지역명을 넣기 위함.
  Future<String?> _regionKeyword(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isEmpty) return null;
      final p = placemarks.first;
      final parts = <String>[
        if ((p.locality ?? '').isNotEmpty) p.locality!,
        if ((p.subLocality ?? '').isNotEmpty) p.subLocality!,
      ];
      if (parts.isEmpty && (p.administrativeArea ?? '').isNotEmpty) {
        parts.add(p.administrativeArea!);
      }
      return parts.isEmpty ? null : parts.join(' ');
    } catch (_) {
      return null;
    }
  }

  Future<void> _loadPharmacies(
    double latitude,
    double longitude, {
    String? regionKeyword,
  }) async {
    try {
      final pharmacies = await _pharmacyService.searchNearby(
        latitude: latitude,
        longitude: longitude,
        regionKeyword: regionKeyword,
      );
      if (!mounted) return;
      setState(() {
        _pharmacies = pharmacies;
        _nearestPharmacy = pharmacies.isNotEmpty ? pharmacies.first : null;
        _locationLoading = false;
        if (pharmacies.isEmpty &&
            (AppConstants.naverSearchClientId.isEmpty ||
                AppConstants.naverSearchClientSecret.isEmpty)) {
          _locationLabel = '네이버 지역 검색 API 키가 필요해요';
        } else if (pharmacies.isEmpty) {
          _locationLabel = '주변 약국을 찾지 못했어요';
        }
      });
      _addMarkers();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _pharmacies = [];
        _nearestPharmacy = null;
        _locationLoading = false;
        _locationLabel = '약국 정보를 불러오지 못했어요';
      });
    }
  }

  void _useDefaultLocation(String label) {
    setState(() {
      _locationLabel = label;
      _currentPosition = null;
    });
    _mapController?.updateCamera(
      NCameraUpdate.withParams(
        target: const NLatLng(_defaultLat, _defaultLng),
        zoom: 15,
      ),
    );
    _loadPharmacies(_defaultLat, _defaultLng, regionKeyword: '서울');
  }

  void _initCompass() {
    _magnetometerSub = magnetometerEventStream().listen((event) {
      final heading = atan2(event.y, event.x) * (180 / pi);
      setState(() => _compassHeading = heading);
    });
  }

  void _addMarkers() {
    final controller = _mapController;
    if (controller == null || _pharmacies.isEmpty) return;

    for (final p in _pharmacies) {
      controller.addOverlay(
        NMarker(
          id: p.name,
          position: NLatLng(p.latitude, p.longitude),
          caption: NOverlayCaption(text: p.name),
          iconTintColor: p == _nearestPharmacy
              ? AppColors.progressTeal
              : AppColors.textSecondary,
        ),
      );
    }

    final myLat = _currentPosition?.latitude ?? _defaultLat;
    final myLng = _currentPosition?.longitude ?? _defaultLng;
    controller.addOverlay(
      NMarker(
        id: 'me',
        position: NLatLng(myLat, myLng),
        caption: const NOverlayCaption(text: '내 위치'),
        iconTintColor: AppColors.alertPrimary,
      ),
    );
  }

  double _bearingTo(Pharmacy p) {
    if (_currentPosition == null) return 0;
    final dLng = p.longitude - _currentPosition!.longitude;
    final dLat = p.latitude - _currentPosition!.latitude;
    return atan2(dLng, dLat) * (180 / pi);
  }

  String _distanceLabel(Pharmacy p) {
    final meters = p.distanceMeters ??
        (_currentPosition == null
            ? 0
            : Geolocator.distanceBetween(
                _currentPosition!.latitude,
                _currentPosition!.longitude,
                p.latitude,
                p.longitude,
              ));
    if (meters <= 0) return '';
    return meters < 1000
        ? '${meters.toStringAsFixed(0)}m'
        : '${(meters / 1000).toStringAsFixed(1)}km';
  }

  Future<void> _openNaverMaps(Pharmacy p) async {
    final uri = Uri.parse(
      'nmap://route/walk?dlat=${p.latitude}&dlng=${p.longitude}&dname=${Uri.encodeComponent(p.name)}&appname=com.example.yakssok_front',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      final webUri = Uri.parse(
        'https://map.naver.com/v5/directions/-/-/-/walk?c=${p.longitude},${p.latitude},15,0,0,0,dh',
      );
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('약국 찾기'),
      ),
      body: Column(
        children: [
          _LocationBar(
            label: _locationLabel,
            isLoading: _locationLoading,
          ),
          _MapSection(
            currentPosition: _currentPosition,
            onMapCreated: (controller) {
              _mapController = controller;
              final lat = _currentPosition?.latitude ?? _defaultLat;
              final lng = _currentPosition?.longitude ?? _defaultLng;
              controller.updateCamera(
                NCameraUpdate.withParams(
                  target: NLatLng(lat, lng),
                  zoom: 15,
                ),
              );
              _addMarkers();
            },
          ),
          if (_nearestPharmacy != null)
            _CompassSection(
              pharmacy: _nearestPharmacy!,
              compassHeading: _compassHeading,
              bearing: _bearingTo(_nearestPharmacy!),
              distance: _distanceLabel(_nearestPharmacy!),
              onNavigate: () => _openNaverMaps(_nearestPharmacy!),
            ),
          Expanded(
            child: _PharmacyList(
              pharmacies: _pharmacies,
              nearest: _nearestPharmacy,
              distanceLabel: _distanceLabel,
              onNavigate: _openNaverMaps,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── 위치 바 ──────────────────────────────────────────────
class _LocationBar extends StatelessWidget {
  const _LocationBar({required this.label, required this.isLoading});
  final String label;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingXl,
        vertical: AppDimensions.paddingMd,
      ),
      child: Row(
        children: [
          const Icon(Icons.my_location_rounded,
              color: AppColors.progressTeal, size: 18),
          const SizedBox(width: AppDimensions.paddingSm),
          if (isLoading)
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppColors.progressTeal),
            )
          else
            const Icon(Icons.circle, color: AppColors.progressTeal, size: 8),
          const SizedBox(width: AppDimensions.paddingSm),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── 지도 ─────────────────────────────────────────────────
class _MapSection extends StatelessWidget {
  const _MapSection({
    required this.currentPosition,
    required this.onMapCreated,
  });
  final Position? currentPosition;
  final void Function(NaverMapController) onMapCreated;

  @override
  Widget build(BuildContext context) {
    final initial = currentPosition != null
        ? NCameraPosition(
            target:
                NLatLng(currentPosition!.latitude, currentPosition!.longitude),
            zoom: 15,
          )
        : const NCameraPosition(
            target: NLatLng(37.5665, 126.9780),
            zoom: 14,
          );

    return SizedBox(
      height: 240,
      child: NaverMap(
        options: NaverMapViewOptions(
          initialCameraPosition: initial,
          locationButtonEnable: true,
        ),
        onMapReady: onMapCreated,
      ),
    );
  }
}

// ─── 나침반 섹션 ───────────────────────────────────────────
class _CompassSection extends StatelessWidget {
  const _CompassSection({
    required this.pharmacy,
    required this.compassHeading,
    required this.bearing,
    required this.distance,
    required this.onNavigate,
  });

  final Pharmacy pharmacy;
  final double compassHeading;
  final double bearing;
  final String distance;
  final VoidCallback onNavigate;

  @override
  Widget build(BuildContext context) {
    final arrowAngle = (bearing - compassHeading) * (pi / 180);

    return Container(
      margin: const EdgeInsets.all(AppDimensions.paddingMd),
      padding: const EdgeInsets.all(AppDimensions.paddingLg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
      ),
      child: Row(
        children: [
          Transform.rotate(
            angle: arrowAngle,
            child: const Icon(
              Icons.navigation_rounded,
              color: AppColors.progressTeal,
              size: 40,
            ),
          ),
          const SizedBox(width: AppDimensions.paddingLg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '가장 가까운 약국',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  pharmacy.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  distance,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.progressTeal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: onNavigate,
            icon: const Icon(Icons.directions_walk_rounded, size: 16),
            label: const Text('길찾기'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.progressTeal,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingLg,
                vertical: AppDimensions.paddingMd,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── 약국 목록 ────────────────────────────────────────────
class _PharmacyList extends StatelessWidget {
  const _PharmacyList({
    required this.pharmacies,
    required this.nearest,
    required this.distanceLabel,
    required this.onNavigate,
  });

  final List<Pharmacy> pharmacies;
  final Pharmacy? nearest;
  final String Function(Pharmacy) distanceLabel;
  final void Function(Pharmacy) onNavigate;

  @override
  Widget build(BuildContext context) {
    if (pharmacies.isEmpty) {
      return const Center(
        child: Text('주변 약국을 찾는 중이에요.',
            style: TextStyle(color: AppColors.textSecondary)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.paddingXl,
            AppDimensions.paddingMd,
            AppDimensions.paddingXl,
            AppDimensions.paddingSm,
          ),
          child: Text(
            '주변 약국',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingMd,
            ),
            itemCount: pharmacies.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppDimensions.paddingXs),
            itemBuilder: (context, i) => _PharmacyCard(
              pharmacy: pharmacies[i],
              isNearest: pharmacies[i] == nearest,
              distance: distanceLabel(pharmacies[i]),
              onNavigate: () => onNavigate(pharmacies[i]),
            ),
          ),
        ),
      ],
    );
  }
}

class _PharmacyCard extends StatelessWidget {
  const _PharmacyCard({
    required this.pharmacy,
    required this.isNearest,
    required this.distance,
    required this.onNavigate,
  });

  final Pharmacy pharmacy;
  final bool isNearest;
  final String distance;
  final VoidCallback onNavigate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        border: isNearest
            ? Border.all(color: AppColors.progressTeal, width: 1.5)
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isNearest
                  ? AppColors.progressTealLight
                  : AppColors.background,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.local_pharmacy_rounded,
              color:
                  isNearest ? AppColors.progressTeal : AppColors.textSecondary,
              size: 22,
            ),
          ),
          const SizedBox(width: AppDimensions.paddingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      pharmacy.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    if (isNearest) ...[
                      const SizedBox(width: AppDimensions.paddingXs),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.progressTeal,
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusPill),
                        ),
                        child: const Text(
                          '가장 가까움',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  pharmacy.address ?? '주소 정보 없음',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                distance,
                style: const TextStyle(
                  color: AppColors.progressTeal,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: onNavigate,
                child: const Icon(Icons.directions_rounded,
                    color: AppColors.progressTeal, size: 22),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
