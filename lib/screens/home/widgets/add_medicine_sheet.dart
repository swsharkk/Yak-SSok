import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme.dart';
import '../../../models/medicine.dart';
import '../../../models/schedule.dart';
import '../../../providers/medicine_provider.dart';
import '../../../providers/repository_providers.dart';
import '../../../providers/saved_medicine_provider.dart';
import '../../../providers/schedule_provider.dart';
import '../../warning/warning_screen.dart';

class AddMedicineSheet extends ConsumerStatefulWidget {
  const AddMedicineSheet({super.key, this.prefillName});

  final String? prefillName;

  @override
  ConsumerState<AddMedicineSheet> createState() => _AddMedicineSheetState();
}

enum _FrequencyType { daily, weekly, interval }

enum _DurationPreset { none, sevenDays, fourteenDays, thirtyDays, custom }

class _AddMedicineSheetState extends ConsumerState<AddMedicineSheet> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  Medicine? _selectedMedicine;
  final Set<ScheduleSlot> _selectedSlots = {};
  int _doseCount = 1;

  _FrequencyType _frequencyType = _FrequencyType.daily;
  final Set<int> _selectedDays = {0, 1, 2, 3, 4, 5, 6}; // 0=월 ~ 6=일
  int _intervalDays = 2;

  _DurationPreset _durationPreset = _DurationPreset.none;
  DateTime? _customStartDate;
  DateTime? _customEndDate;

  DateTime get _effectiveStartDate => _customStartDate ?? DateTime.now();

  DateTime? get _effectiveEndDate => switch (_durationPreset) {
        _DurationPreset.none => null,
        _DurationPreset.sevenDays =>
          DateTime.now().add(const Duration(days: 6)),
        _DurationPreset.fourteenDays =>
          DateTime.now().add(const Duration(days: 13)),
        _DurationPreset.thirtyDays =>
          DateTime.now().add(const Duration(days: 29)),
        _DurationPreset.custom => _customEndDate,
      };

  String _formatDate(DateTime d) =>
      '${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}';

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _customStartDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _customStartDate = picked);
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _customEndDate ?? (_customStartDate ?? DateTime.now()),
      firstDate: _customStartDate ?? DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _customEndDate = picked);
  }

  static const _slots = [
    (slot: ScheduleSlot.morning, label: '아침'),
    (slot: ScheduleSlot.lunch, label: '점심'),
    (slot: ScheduleSlot.evening, label: '저녁'),
    (slot: ScheduleSlot.bedtime, label: '취침 전'),
    (slot: ScheduleSlot.custom, label: '직접 설정'),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.prefillName != null && widget.prefillName!.isNotEmpty) {
      _searchController.text = widget.prefillName!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(medicineSearchProvider.notifier).search(widget.prefillName!);
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref.read(medicineSearchProvider.notifier).search(query);
    });
  }

  Future<void> _onAdd() async {
    if (_selectedMedicine == null || _selectedSlots.isEmpty) return;
    try {
      // 1. 저장 전 병용금기 체크
      final interactions = await ref
          .read(interactionRepositoryProvider)
          .checkInteractions([_selectedMedicine!.name]);

      // 2. 경고가 있으면 사용자 확인 요청
      if (interactions.isNotEmpty && mounted) {
        final proceed = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => WarningScreen(interactions: interactions),
          ),
        );
        if (proceed != true) return; // 취소 선택 시 저장 안 함
      }

      // 3. 확인 후 저장
      for (final slot in _selectedSlots) {
        await ref.read(savedMedicineControllerProvider.notifier).add(
              medicineName: _selectedMedicine!.name,
              company: _selectedMedicine!.company,
              description: _selectedMedicine!.description,
              imageUrl: _selectedMedicine!.imageUrl,
              slot: slot,
              doseCount: _doseCount,
              frequencyType: _frequencyType.name,
              daysOfWeek: _frequencyType == _FrequencyType.weekly
                  ? (_selectedDays.toList()..sort())
                  : null,
              intervalDays: _frequencyType == _FrequencyType.interval
                  ? _intervalDays
                  : null,
              startDate: _durationPreset != _DurationPreset.none
                  ? _effectiveStartDate
                  : null,
              endDate: _effectiveEndDate,
            );
      }

      ref.invalidate(todaySchedulesProvider);
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('저장 실패: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(medicineSearchProvider);
    final canAdd = _selectedMedicine != null && _selectedSlots.isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimensions.radiusXl),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppDimensions.paddingSm),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.paddingXxl,
                AppDimensions.paddingLg,
                AppDimensions.paddingMd,
                AppDimensions.paddingLg,
              ),
              child: Row(
                children: [
                  Text(
                    '약 추가하기',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded,
                        color: AppColors.textPrimary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingXxl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _SearchField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                    ),
                    searchState.when(
                      loading: () => const Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: AppDimensions.paddingMd),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (_, __) => const SizedBox.shrink(),
                      data: (results) {
                        if (results.isNotEmpty) {
                          return _SearchResultFrame(
                            children: results
                                .map((m) => _MedicineResultCard(
                                      medicine: m,
                                      isSelected:
                                          _selectedMedicine?.id == m.id,
                                      onTap: () => setState(() {
                                        _selectedMedicine =
                                            _selectedMedicine?.id == m.id
                                                ? null
                                                : m;
                                      }),
                                    ))
                                .toList(),
                          );
                        }
                        final query = _searchController.text.trim();
                        if (query.isNotEmpty) {
                          return Padding(
                            padding: const EdgeInsets.only(
                                top: AppDimensions.paddingMd),
                            child: _DirectInputCard(
                              name: query,
                              isSelected:
                                  _selectedMedicine?.id == 'custom_$query',
                              onTap: () => setState(() {
                                _selectedMedicine =
                                    _selectedMedicine?.id == 'custom_$query'
                                        ? null
                                        : Medicine(
                                            id: 'custom_$query',
                                            name: query,
                                          );
                              }),
                            ),
                          );
                        }
                        if (_selectedMedicine != null) {
                          return Padding(
                            padding: const EdgeInsets.only(
                                top: AppDimensions.paddingMd),
                            child: _MedicineResultCard(
                              medicine: _selectedMedicine!,
                              isSelected: true,
                              onTap: () =>
                                  setState(() => _selectedMedicine = null),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    const SizedBox(height: AppDimensions.paddingXxl),
                    Text(
                      '복용 시간',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: AppDimensions.paddingMd),
                    Wrap(
                      spacing: AppDimensions.paddingSm,
                      runSpacing: AppDimensions.paddingSm,
                      children: _slots
                          .map((s) => _SlotChip(
                                label: s.label,
                                isSelected: _selectedSlots.contains(s.slot),
                                onTap: () => setState(() {
                                  if (_selectedSlots.contains(s.slot)) {
                                    _selectedSlots.remove(s.slot);
                                  } else {
                                    _selectedSlots.add(s.slot);
                                  }
                                }),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: AppDimensions.paddingXxl),
                    Text(
                      '복용 주기',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: AppDimensions.paddingMd),
                    Wrap(
                      spacing: AppDimensions.paddingSm,
                      children: [
                        _SlotChip(
                          label: '매일',
                          isSelected: _frequencyType == _FrequencyType.daily,
                          onTap: () => setState(
                              () => _frequencyType = _FrequencyType.daily),
                        ),
                        _SlotChip(
                          label: '요일 선택',
                          isSelected: _frequencyType == _FrequencyType.weekly,
                          onTap: () => setState(
                              () => _frequencyType = _FrequencyType.weekly),
                        ),
                        _SlotChip(
                          label: 'N일마다',
                          isSelected:
                              _frequencyType == _FrequencyType.interval,
                          onTap: () => setState(
                              () => _frequencyType = _FrequencyType.interval),
                        ),
                      ],
                    ),
                    if (_frequencyType == _FrequencyType.weekly) ...[
                      const SizedBox(height: AppDimensions.paddingMd),
                      _DayOfWeekPicker(
                        selectedDays: _selectedDays,
                        onToggle: (d) => setState(() {
                          if (_selectedDays.contains(d)) {
                            _selectedDays.remove(d);
                          } else {
                            _selectedDays.add(d);
                          }
                        }),
                      ),
                    ],
                    if (_frequencyType == _FrequencyType.interval) ...[
                      const SizedBox(height: AppDimensions.paddingMd),
                      _DoseCounter(
                        count: _intervalDays,
                        unit: '일마다',
                        onDecrement: () {
                          if (_intervalDays > 2) {
                            setState(() => _intervalDays--);
                          }
                        },
                        onIncrement: () => setState(() => _intervalDays++),
                      ),
                    ],
                    const SizedBox(height: AppDimensions.paddingXxl),
                    Text(
                      '복용량',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: AppDimensions.paddingMd),
                    _DoseCounter(
                      count: _doseCount,
                      onDecrement: () {
                        if (_doseCount > 1) setState(() => _doseCount--);
                      },
                      onIncrement: () => setState(() => _doseCount++),
                    ),
                    const SizedBox(height: AppDimensions.paddingXxl),
                    Text(
                      '복용 기간',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: AppDimensions.paddingMd),
                    Wrap(
                      spacing: AppDimensions.paddingSm,
                      runSpacing: AppDimensions.paddingSm,
                      children: [
                        _SlotChip(
                          label: '기간 없음',
                          isSelected:
                              _durationPreset == _DurationPreset.none,
                          onTap: () => setState(
                              () => _durationPreset = _DurationPreset.none),
                        ),
                        _SlotChip(
                          label: '7일',
                          isSelected:
                              _durationPreset == _DurationPreset.sevenDays,
                          onTap: () => setState(() =>
                              _durationPreset = _DurationPreset.sevenDays),
                        ),
                        _SlotChip(
                          label: '14일',
                          isSelected:
                              _durationPreset == _DurationPreset.fourteenDays,
                          onTap: () => setState(() =>
                              _durationPreset = _DurationPreset.fourteenDays),
                        ),
                        _SlotChip(
                          label: '30일',
                          isSelected:
                              _durationPreset == _DurationPreset.thirtyDays,
                          onTap: () => setState(() =>
                              _durationPreset = _DurationPreset.thirtyDays),
                        ),
                        _SlotChip(
                          label: '직접 설정',
                          isSelected:
                              _durationPreset == _DurationPreset.custom,
                          onTap: () => setState(() {
                            _durationPreset = _DurationPreset.custom;
                            _customStartDate ??= DateTime.now();
                          }),
                        ),
                      ],
                    ),
                    if (_durationPreset != _DurationPreset.none) ...[
                      const SizedBox(height: AppDimensions.paddingMd),
                      _DateRangeRow(
                        startDate: _effectiveStartDate,
                        endDate: _effectiveEndDate,
                        isCustom: _durationPreset == _DurationPreset.custom,
                        onTapStart: _pickStartDate,
                        onTapEnd: _pickEndDate,
                        formatDate: _formatDate,
                      ),
                    ],
                    const SizedBox(height: AppDimensions.paddingXxl),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.paddingXxl,
                0,
                AppDimensions.paddingXxl,
                AppDimensions.paddingXxl,
              ),
              child: _AddButton(
                onPressed: canAdd ? _onAdd : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        gradient: LinearGradient(
          colors: enabled
              ? [AppColors.primaryMedium, AppColors.progressTeal]
              : [
                  AppColors.primaryMedium.withValues(alpha: 0.35),
                  AppColors.progressTeal.withValues(alpha: 0.35),
                ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: enabled ? AppShadows.button : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
          splashColor: Colors.white.withValues(alpha: 0.15),
          highlightColor: Colors.white.withValues(alpha: 0.08),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.medication_rounded,
                color: Colors.white.withValues(alpha: enabled ? 1.0 : 0.6),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '약 추가하기',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withValues(alpha: enabled ? 1.0 : 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: '약 이름을 입력하세요',
        hintStyle: const TextStyle(color: AppColors.textMuted),
        filled: true,
        fillColor: AppColors.background,
        suffixIcon: const Icon(Icons.search_rounded,
            color: AppColors.progressTeal),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingXl,
          vertical: AppDimensions.paddingLg,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _MedicineResultCard extends StatelessWidget {
  const _MedicineResultCard({
    required this.medicine,
    required this.isSelected,
    required this.onTap,
  });

  final Medicine medicine;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingLg,
            vertical: AppDimensions.paddingMd,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medicine.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    if (medicine.company != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        medicine.company!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppDimensions.paddingSm),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.progressTeal
                      : AppColors.background,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusMd),
                ),
                child: Icon(
                  Icons.check_rounded,
                  color: isSelected ? Colors.white : AppColors.textMuted,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SlotChip extends StatelessWidget {
  const _SlotChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingXl,
          vertical: AppDimensions.paddingMd,
        ),
        decoration: BoxDecoration(
          color:
              isSelected ? AppColors.progressTealLight : AppColors.background,
          borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? AppColors.progressTeal
                : AppColors.textSecondary,
            fontWeight:
                isSelected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}

class _DoseCounter extends StatelessWidget {
  const _DoseCounter({
    required this.count,
    required this.onDecrement,
    required this.onIncrement,
    this.unit = '알',
  });

  final int count;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
      ),
      child: Row(
        children: [
          _CounterButton(icon: Icons.remove_rounded, onTap: onDecrement),
          Expanded(
            child: Center(
              child: Text(
                '$count$unit',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          _CounterButton(icon: Icons.add_rounded, onTap: onIncrement),
        ],
      ),
    );
  }
}

class _DayOfWeekPicker extends StatelessWidget {
  const _DayOfWeekPicker({
    required this.selectedDays,
    required this.onToggle,
  });

  final Set<int> selectedDays;
  final ValueChanged<int> onToggle;

  static const _labels = ['월', '화', '수', '목', '금', '토', '일'];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final selected = selectedDays.contains(i);
        return GestureDetector(
          onTap: () => onToggle(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.progressTeal
                  : AppColors.background,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              _labels[i],
              style: TextStyle(
                color: selected ? Colors.white : AppColors.textSecondary,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _CounterButton extends StatelessWidget {
  const _CounterButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        child: SizedBox(
          width: 56,
          height: 56,
          child: Icon(icon, color: AppColors.textPrimary, size: 22),
        ),
      ),
    );
  }
}

class _DirectInputCard extends StatelessWidget {
  const _DirectInputCard({
    required this.name,
    required this.isSelected,
    required this.onTap,
  });

  final String name;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingLg),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
                child: const Icon(Icons.edit_rounded,
                    color: AppColors.textSecondary, size: 28),
              ),
              const SizedBox(width: AppDimensions.paddingLg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      '직접 입력',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.progressTeal
                      : AppColors.background,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusMd),
                ),
                child: Icon(
                  Icons.check_rounded,
                  color: isSelected ? Colors.white : AppColors.textMuted,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateRangeRow extends StatelessWidget {
  const _DateRangeRow({
    required this.startDate,
    required this.endDate,
    required this.isCustom,
    required this.onTapStart,
    required this.onTapEnd,
    required this.formatDate,
  });

  final DateTime startDate;
  final DateTime? endDate;
  final bool isCustom;
  final VoidCallback onTapStart;
  final VoidCallback onTapEnd;
  final String Function(DateTime) formatDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingLg,
        vertical: AppDimensions.paddingMd,
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: isCustom ? onTapStart : null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '시작일',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formatDate(startDate),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isCustom
                          ? AppColors.progressTeal
                          : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Icon(Icons.arrow_forward_rounded,
              size: 16, color: AppColors.textMuted),
          Expanded(
            child: GestureDetector(
              onTap: isCustom ? onTapEnd : null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    '종료일',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    endDate != null ? formatDate(endDate!) : '미설정',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isCustom
                          ? AppColors.progressTeal
                          : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchResultFrame extends StatelessWidget {
  const _SearchResultFrame({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: AppDimensions.paddingMd),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
      ),
      constraints: const BoxConstraints(maxHeight: 260),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingSm),
          shrinkWrap: true,
          itemCount: children.length,
          separatorBuilder: (_, __) => const Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: AppColors.divider,
          ),
          itemBuilder: (_, i) => children[i],
        ),
      ),
    );
  }
}
