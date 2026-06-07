import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/responsive.dart';
import '../../core/theme.dart';
import '../../models/medicine.dart';
import '../../providers/medicine_provider.dart';
import '../../providers/recent_medicine_search_provider.dart';
import '../../widgets/emergency_button.dart';
import '../home/widgets/add_medicine_sheet.dart';
import '../medicine_detail/medicine_detail_screen.dart';
import 'camera_screen.dart';
import 'chatbot_screen.dart';
import 'voice_search_screen.dart';

/// 검색 탭 — 음성/카메라/챗봇 진입과 최근 검색 목록.
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF8F9FC),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Color(0xFFF8F9FC),
            elevation: 0,
            floating: true,
            snap: false,
            scrolledUnderElevation: 0,
            surfaceTintColor: Colors.transparent,
            title: _SearchHeader(),
            titleSpacing: 0,
            toolbarHeight: 64,
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              AppDimensions.paddingLg,
              AppDimensions.paddingMd,
              AppDimensions.paddingLg,
              0,
            ),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _TextSearchSection(),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(height: AppDimensions.paddingXl),
          ),
          SliverToBoxAdapter(
            child: _SearchBodyPanel(),
          ),
        ],
      ),
    );
  }
}

class _SearchBodyPanel extends StatelessWidget {
  const _SearchBodyPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.paddingLg,
        AppDimensions.paddingXxl,
        AppDimensions.paddingLg,
        AppDimensions.padding3xl,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(34),
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SearchMethodGrid(),
          SizedBox(height: AppDimensions.paddingXxl),
          _RecentSearchSection(),
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
        Container(
          padding: const EdgeInsets.all(1.6),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF78D7FF),
                Color(0xFF4DA3FF),
                Color(0xFFE45BDF),
                Color(0xFFFF8D8D),
              ],
            ),
            borderRadius: BorderRadius.circular(28),
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(26),
            ),
            child: TextField(
              controller: _controller,
              onChanged: _onQueryChanged,
              textInputAction: TextInputAction.search,
              onSubmitted: (value) {
                _debounce?.cancel();
                ref.read(medicineSearchProvider.notifier).search(value);
              },
              decoration: InputDecoration(
                hintText: '약 이름을 검색해보세요',
                hintStyle: const TextStyle(
                  color: Color(0xFFB8BBC2),
                  fontWeight: FontWeight.w500,
                ),
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
                  borderRadius: BorderRadius.circular(26),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(26),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(26),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingLg,
                  vertical: AppDimensions.paddingLg,
                ),
              ),
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
        ExcludeSemantics(
          child: SizedBox(
            width: AppResponsive.logoWidth(context),
            height: AppResponsive.logoHeight(context),
            child: ClipRect(
              child: Image.asset(
                _logoPath,
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
          ),
        ),
        const Spacer(),
        const EmergencyButton(),
        const SizedBox(width: AppDimensions.paddingMd),
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
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const VoiceSearchScreen(),
                    ),
                  ),
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
                  onTap: () async {
                    final drugs = await Navigator.push<List<ParsedDrug>>(
                      context,
                      MaterialPageRoute(builder: (_) => const CameraScreen()),
                    );
                    if (drugs == null || drugs.isEmpty || !context.mounted) return;
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => _ParsedDrugSheet(drugs: drugs),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.paddingMd),
        _SearchMethodCard(
          backgroundColor: AppColors.searchChatBg,
          iconBackgroundColor: AppColors.searchChatIconBg,
          foregroundColor: AppColors.searchChatPrimary,
          icon: Icons.smart_toy_rounded,
          title: 'AI 챗봇 상담',
          description: '약에 대해 무엇이든 물어보세요',
          isWide: true,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ChatbotScreen()),
          ),
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
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusMd),
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
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusMd),
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
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
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
        const SizedBox(height: AppDimensions.paddingLg),
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
  });

  final RecentMedicineSearch item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medicine = item.medicine;

    final borderRadius = BorderRadius.circular(28);

    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
        side: const BorderSide(color: Color(0xFFECEEF3)),
      ),
      child: InkWell(
        onTap: () => _openMedicineDetail(context, ref, medicine),
        customBorder: RoundedRectangleBorder(borderRadius: borderRadius),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.paddingLg,
            AppDimensions.paddingLg,
            AppDimensions.paddingLg,
            AppDimensions.paddingLg,
          ),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Color(0xFFF4F5F7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.medication_rounded,
                  color: AppColors.textPrimary,
                  size: 30,
                ),
              ),
              const SizedBox(width: AppDimensions.paddingLg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatDate(item.searchedAt),
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingXs),
                    Text(
                      medicine.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
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

String _formatDate(DateTime dateTime) {
  final local = dateTime.toLocal();
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');

  return '${local.year}.$month.$day';
}

class _ParsedDrugSheet extends StatelessWidget {
  const _ParsedDrugSheet({required this.drugs});
  final List<ParsedDrug> drugs;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        AppDimensions.paddingXl,
        AppDimensions.paddingLg,
        AppDimensions.paddingXl,
        AppDimensions.padding3xl + bottomInset,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.paddingLg),
          Text(
            '인식된 약 목록',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: AppDimensions.paddingXs),
          Text(
            '추가할 약을 선택하세요',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppDimensions.paddingLg),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.5,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final drug in drugs) ...[
                    _DrugResultTile(drug: drug),
                    const SizedBox(height: AppDimensions.paddingMd),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DrugResultTile extends StatelessWidget {
  const _DrugResultTile({required this.drug});
  final ParsedDrug drug;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLg),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  drug.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '하루 ${drug.dailyFrequency}회'
                  '${drug.durationDays > 0 ? ' · ${drug.durationDays}일치' : ''}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => AddMedicineSheet(prefillName: drug.name),
              );
            },
            style: TextButton.styleFrom(
              backgroundColor: AppColors.progressTeal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingLg,
                vertical: AppDimensions.paddingSm,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
              ),
            ),
            child: const Text('추가', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
