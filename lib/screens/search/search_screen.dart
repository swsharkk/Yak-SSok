import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/responsive.dart';
import '../../core/theme.dart';
import '../../models/medicine.dart';
import '../../providers/medicine_provider.dart';
import '../../providers/recent_medicine_search_provider.dart';
import '../../widgets/emergency_button.dart';
import '../medicine_detail/medicine_detail_screen.dart';
import 'camera_screen.dart';
import 'chatbot_screen.dart';
import 'voice_search_screen.dart';

/// 검색 탭 — 음성/카메라/챗봇 진입과 최근 검색 목록.
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            automaticallyImplyLeading: false,
            backgroundColor: AppColors.background,
            elevation: 0,
            floating: true,
            snap: true,
            scrolledUnderElevation: 0,
            surfaceTintColor: Colors.transparent,
            title: _SearchHeader(),
            titleSpacing: 0,
            toolbarHeight: 64,
          ),
          SliverPadding(
            padding: AppResponsive.pagePadding(context),
            sliver: const SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SearchTitle(),
                  SizedBox(height: AppDimensions.paddingXl),
                  _TextSearchSection(),
                  SizedBox(height: AppDimensions.paddingXxl),
                  _SearchMethodGrid(),
                  SizedBox(height: AppDimensions.paddingXxl),
                  _RecentSearchSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TextSearchSection extends ConsumerStatefulWidget {
  const _TextSearchSection();

  @override
  ConsumerState<_TextSearchSection> createState() => _TextSearchSectionState();
}

class _TextSearchSectionState extends ConsumerState<_TextSearchSection> {
  final _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    setState(() {});
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      ref.read(medicineSearchProvider.notifier).search(value);
    });
  }

  Future<void> _open(Medicine medicine) {
    return _openMedicineDetail(context, ref, medicine);
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(medicineSearchProvider);
    final query = _controller.text.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _controller,
          onChanged: _onQueryChanged,
          textInputAction: TextInputAction.search,
          onSubmitted: (value) {
            _debounce?.cancel();
            ref.read(medicineSearchProvider.notifier).search(value);
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surface,
            hintText: '약 이름을 검색해보세요',
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: AppColors.textSecondary,
            ),
            suffixIcon: query.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.close_rounded),
                    color: AppColors.textSecondary,
                    onPressed: () {
                      _debounce?.cancel();
                      _controller.clear();
                      ref.read(medicineSearchProvider.notifier).search('');
                      setState(() {});
                    },
                  ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingLg,
              vertical: AppDimensions.paddingLg,
            ),
          ),
        ),
        if (query.isNotEmpty) ...[
          const SizedBox(height: AppDimensions.paddingMd),
          searchState.when(
            data: (medicines) {
              if (medicines.isEmpty) {
                return const _SearchEmptyResult();
              }

              return _SearchResultList(
                medicines: medicines,
                onTap: _open,
              );
            },
            loading: () => const _SearchLoadingResult(),
            error: (error, _) => _SearchErrorResult(message: '$error'),
          ),
        ],
      ],
    );
  }
}

class _SearchResultList extends StatelessWidget {
  const _SearchResultList({
    required this.medicines,
    required this.onTap,
  });

  final List<Medicine> medicines;
  final ValueChanged<Medicine> onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingSm),
        itemCount: medicines.length,
        separatorBuilder: (_, __) => const Divider(
          height: 1,
          color: AppColors.divider,
        ),
        itemBuilder: (context, index) {
          final medicine = medicines[index];

          return ListTile(
            leading: const Icon(
              Icons.medication_rounded,
              color: AppColors.progressTeal,
            ),
            title: Text(
              medicine.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Text(
              [
                if (medicine.company != null) medicine.company,
                if (medicine.dosage != null) medicine.dosage,
              ].join(' · '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => onTap(medicine),
          );
        },
      ),
    );
  }
}

class _SearchLoadingResult extends StatelessWidget {
  const _SearchLoadingResult();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.paddingXl),
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}

class _SearchEmptyResult extends StatelessWidget {
  const _SearchEmptyResult();

  @override
  Widget build(BuildContext context) {
    return const _SearchMessageBox(message: '검색 결과가 없어요');
  }
}

class _SearchErrorResult extends StatelessWidget {
  const _SearchErrorResult({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return _SearchMessageBox(message: '검색 중 문제가 생겼어요: $message');
  }
}

class _SearchMessageBox extends StatelessWidget {
  const _SearchMessageBox({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _SearchHeader extends StatelessWidget {
  const _SearchHeader();

  static const _logoPath = 'assets/yakssok_logo_final.png';

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Transform.translate(
          offset: Offset(AppResponsive.headerLogoOffset(context), 0),
          child: Image.asset(
            _logoPath,
            width: AppResponsive.logoWidth(context),
            height: AppResponsive.logoHeight(context),
            fit: BoxFit.cover,
            alignment: Alignment.center,
            semanticLabel: AppStrings.appName,
          ),
        ),
        const Spacer(),
        const EmergencyButton(),
        const SizedBox(width: AppDimensions.paddingMd),
      ],
    );
  }
}

class _SearchTitle extends StatelessWidget {
  const _SearchTitle();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.searchTitle,
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: 34,
                fontWeight: FontWeight.w500,
                height: 1.2,
              ),
        ),
        const SizedBox(height: AppDimensions.paddingSm),
        Text(
          AppStrings.searchSubtitle,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}

class _SearchMethodGrid extends StatelessWidget {
  const _SearchMethodGrid();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 상단: 음성 + 카메라 (동일 크기 2열)
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _SearchMethodCard(
                  backgroundColor: AppColors.searchVoiceBg,
                  iconBackgroundColor: AppColors.searchVoiceIconBg,
                  foregroundColor: AppColors.searchVoicePrimary,
                  icon: Icons.mic_rounded,
                  title: '음성 검색',
                  description: '말씀만 하시면\n찾아드려요',
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const VoiceSearchScreen())),
                ),
              ),
              const SizedBox(width: AppDimensions.paddingMd),
              Expanded(
                child: _SearchMethodCard(
                  backgroundColor: AppColors.searchCameraBg,
                  iconBackgroundColor: AppColors.searchCameraIconBg,
                  foregroundColor: AppColors.searchCameraPrimary,
                  icon: Icons.camera_alt_rounded,
                  title: '카메라 촬영',
                  description: '사진으로\n확인',
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const CameraScreen())),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.paddingMd),
        // 하단: 챗봇 (1열 와이드)
        _SearchMethodCard(
          backgroundColor: AppColors.searchChatBg,
          iconBackgroundColor: AppColors.searchChatIconBg,
          foregroundColor: AppColors.searchChatPrimary,
          icon: Icons.smart_toy_rounded,
          title: 'AI 챗봇 상담',
          description: '약에 대해 무엇이든 물어보세요',
          isWide: true,
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const ChatbotScreen())),
        ),
      ],
    );
  }
}

class _SearchMethodCard extends StatelessWidget {
  const _SearchMethodCard({
    required this.backgroundColor,
    required this.iconBackgroundColor,
    required this.foregroundColor,
    required this.icon,
    required this.title,
    required this.description,
    this.isWide = false,
    this.onTap,
  });

  final Color backgroundColor;
  final Color iconBackgroundColor;
  final Color foregroundColor;
  final IconData icon;
  final String title;
  final String description;
  final bool isWide;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingLg),
          child: isWide
              ? Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: iconBackgroundColor,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                      ),
                      child: Icon(icon, color: foregroundColor, size: 22),
                    ),
                    const SizedBox(width: AppDimensions.paddingLg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              color: foregroundColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            description,
                            style: TextStyle(
                              color: foregroundColor.withValues(alpha: 0.65),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: foregroundColor.withValues(alpha: 0.4),
                      size: 14,
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: iconBackgroundColor,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                      ),
                      child: Icon(icon, color: foregroundColor, size: 22),
                    ),
                    const SizedBox(height: AppDimensions.paddingXl),
                    Text(
                      title,
                      style: TextStyle(
                        color: foregroundColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      description,
                      style: TextStyle(
                        color: foregroundColor.withValues(alpha: 0.65),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _RecentSearchSection extends ConsumerWidget {
  const _RecentSearchSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentState = ref.watch(recentMedicineSearchProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                AppStrings.recentSearchMedicine,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: 25,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
            TextButton(
              onPressed: recentState.valueOrNull?.isEmpty ?? true
                  ? null
                  : () =>
                      ref.read(recentMedicineSearchProvider.notifier).clear(),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.searchRecentBlue,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingXs,
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              child: const Text(AppStrings.clearAll),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.paddingXl),
        recentState.when(
          data: (items) {
            if (items.isEmpty) {
              return const _SearchMessageBox(message: '최근 검색한 약이 없어요');
            }

            return Column(
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  if (i > 0) const SizedBox(height: AppDimensions.paddingLg),
                  _RecentMedicineCard(
                    item: items[i],
                    accentColor: _recentAccentColor(i),
                  ),
                ],
              ],
            );
          },
          loading: () => const _SearchLoadingResult(),
          error: (error, _) => const _SearchMessageBox(
            message: '최근 검색을 불러오지 못했어요',
          ),
        ),
      ],
    );
  }
}

class _RecentMedicineCard extends ConsumerWidget {
  const _RecentMedicineCard({
    required this.item,
    required this.accentColor,
  });

  final RecentMedicineSearch item;
  final Color accentColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medicine = item.medicine;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
      child: InkWell(
        onTap: () => _openMedicineDetail(context, ref, medicine),
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.paddingXxl,
            AppDimensions.paddingXl,
            AppDimensions.paddingLg,
            AppDimensions.paddingXl,
          ),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 64,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
                ),
              ),
              const SizedBox(width: AppDimensions.paddingXxl),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medicine.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            height: 1.25,
                          ),
                    ),
                    if (medicine.dosage != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        medicine.dosage!,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontSize: 23,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                            ),
                      ),
                    ],
                    const SizedBox(height: AppDimensions.paddingXs),
                    Text(
                      '${AppStrings.searchedAt}: ${_formatDate(item.searchedAt)}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.searchChevron,
                size: 44,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _openMedicineDetail(
  BuildContext context,
  WidgetRef ref,
  Medicine medicine,
) async {
  await ref.read(recentMedicineSearchProvider.notifier).add(medicine);
  if (!context.mounted) return;

  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => MedicineDetailScreen(medicine: medicine),
    ),
  );
}

Color _recentAccentColor(int index) {
  const colors = [
    AppColors.searchRecentGreen,
    AppColors.searchRecentBlue,
    AppColors.searchRecentRed,
  ];

  return colors[index % colors.length];
}

String _formatDate(DateTime dateTime) {
  final local = dateTime.toLocal();
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');

  return '${local.year}.$month.$day';
}
