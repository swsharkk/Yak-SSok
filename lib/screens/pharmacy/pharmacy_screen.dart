import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme.dart';

class PharmacyScreen extends StatefulWidget {
  const PharmacyScreen({super.key});

  @override
  State<PharmacyScreen> createState() => _PharmacyScreenState();
}

class _PharmacyScreenState extends State<PharmacyScreen> {
  NaverMapController? _mapController;
  Position? _currentPosition;
  double _compassHeading = 0;
  bool _locationLoading = true;
  String _locationLabel = '위치 확인 중...';
  StreamSubscription<MagnetometerEvent>? _magnetometerSub;
  // 임시 약국 목록 (추후 API 연동)
  List<_Pharmacy> _pharmacies = [];
  _Pharmacy? _nearestPharmacy;

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

      setState(() {
        _currentPosition = pos;
        _locationLabel = '현재 위치 확인됨';
        _locationLoading = false;
        _pharmacies = _mockPharmacies(pos.latitude, pos.longitude);
        _nearestPharmacy = _pharmacies.isNotEmpty ? _pharmacies.first : null;
      });

      _mapController?.updateCamera(
        NCameraUpdate.withParams(
          target: NLatLng(pos.latitude, pos.longitude),
          zoom: 15,
        ),
      );

      _addMarkers();
    } catch (e) {
      _useDefaultLocation('위치를 가져올 수 없음 (서울 기준 표시)');
    }
  }

  void _useDefaultLocation(String label) {
    setState(() {
      _locationLabel = label;
      _locationLoading = false;
      _pharmacies = _mockPharmacies(_defaultLat, _defaultLng);
      _nearestPharmacy = _pharmacies.isNotEmpty ? _pharmacies.first : null;
    });
    _mapController?.updateCamera(
      NCameraUpdate.withParams(
        target: const NLatLng(_defaultLat, _defaultLng),
        zoom: 15,
      ),
    );
    _addMarkers();
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
          position: NLatLng(p.lat, p.lng),
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

  List<_Pharmacy> _mockPharmacies(double lat, double lng) {
    final mock = [
      _Pharmacy(
          name: '행복약국', lat: lat + 0.002, lng: lng + 0.001,
          address: '서울시 강남구 테헤란로 1길', phone: '02-1234-5678'),
      _Pharmacy(
          name: '건강약국', lat: lat - 0.001, lng: lng + 0.002,
          address: '서울시 강남구 테헤란로 2길', phone: '02-2345-6789'),
      _Pharmacy(
          name: '든든약국', lat: lat + 0.003, lng: lng - 0.001,
          address: '서울시 강남구 테헤란로 3길', phone: '02-3456-7890'),
    ];

    mock.sort((a, b) => _distance(lat, lng, a.lat, a.lng)
        .compareTo(_distance(lat, lng, b.lat, b.lng)));
    return mock;
  }

  double _distance(double lat1, double lng1, double lat2, double lng2) {
    return sqrt(pow(lat2 - lat1, 2) + pow(lng2 - lng1, 2));
  }

  double _bearingTo(_Pharmacy p) {
    if (_currentPosition == null) return 0;
    final dLng = p.lng - _currentPosition!.longitude;
    final dLat = p.lat - _currentPosition!.latitude;
    return atan2(dLng, dLat) * (180 / pi);
  }

  String _distanceLabel(_Pharmacy p) {
    if (_currentPosition == null) return '';
    final meters = Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      p.lat,
      p.lng,
    );
    return meters < 1000
        ? '${meters.toStringAsFixed(0)}m'
        : '${(meters / 1000).toStringAsFixed(1)}km';
  }

  Future<void> _openNaverMaps(_Pharmacy p) async {
    final uri = Uri.parse(
      'nmap://route/walk?dlat=${p.lat}&dlng=${p.lng}&dname=${Uri.encodeComponent(p.name)}&appname=com.example.yakssok_front',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      final webUri = Uri.parse(
        'https://map.naver.com/v5/directions/-/-/-/walk?c=${p.lng},${p.lat},15,0,0,0,dh',
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
            target: NLatLng(
                currentPosition!.latitude, currentPosition!.longitude),
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

  final _Pharmacy pharmacy;
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

  final List<_Pharmacy> pharmacies;
  final _Pharmacy? nearest;
  final String Function(_Pharmacy) distanceLabel;
  final void Function(_Pharmacy) onNavigate;

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

  final _Pharmacy pharmacy;
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
              color: isNearest
                  ? AppColors.progressTeal
                  : AppColors.textSecondary,
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
                          borderRadius: BorderRadius.circular(
                              AppDimensions.radiusPill),
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
                  pharmacy.address,
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

// ─── 데이터 모델 ──────────────────────────────────────────
class _Pharmacy {
  const _Pharmacy({
    required this.name,
    required this.lat,
    required this.lng,
    required this.address,
    required this.phone,
  });

  final String name;
  final double lat;
  final double lng;
  final String address;
  final String phone;
}
