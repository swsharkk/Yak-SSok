import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../models/health_profile.dart';
import '../../providers/health_profile_provider.dart';
import '../../widgets/loading_indicator.dart';

class HealthInfoScreen extends ConsumerWidget {
  const HealthInfoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(healthProfileControllerProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(AppStrings.healthInfoTitle),
        scrolledUnderElevation: 0,
      ),
      body: profileAsync.when(
        loading: () => const Center(child: LoadingIndicator()),
        error: (e, _) => const Center(child: Text('불러오기 실패')),
        data: (profile) => _HealthInfoForm(profile: profile),
      ),
    );
  }
}

class _HealthInfoForm extends ConsumerStatefulWidget {
  const _HealthInfoForm({required this.profile});

  final HealthProfile profile;

  @override
  ConsumerState<_HealthInfoForm> createState() => _HealthInfoFormState();
}

class _HealthInfoFormState extends ConsumerState<_HealthInfoForm> {
  late final TextEditingController _heightCtrl;
  late final TextEditingController _weightCtrl;
  late final TextEditingController _ageCtrl;
  late final TextEditingController _waterGoalCtrl;
  late String _gender;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _heightCtrl = TextEditingController(
        text: widget.profile.heightCm.toStringAsFixed(0));
    _weightCtrl = TextEditingController(
        text: widget.profile.weightKg.toStringAsFixed(0));
    _ageCtrl =
        TextEditingController(text: widget.profile.age.toString());
    _waterGoalCtrl = TextEditingController(
        text: widget.profile.dailyWaterGoalMl.toString());
    _gender = widget.profile.gender;
  }

  @override
  void dispose() {
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _ageCtrl.dispose();
    _waterGoalCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final profile = HealthProfile(
      heightCm: double.tryParse(_heightCtrl.text) ?? widget.profile.heightCm,
      weightKg: double.tryParse(_weightCtrl.text) ?? widget.profile.weightKg,
      age: int.tryParse(_ageCtrl.text) ?? widget.profile.age,
      gender: _gender,
      dailyWaterGoalMl:
          int.tryParse(_waterGoalCtrl.text) ?? widget.profile.dailyWaterGoalMl,
    );
    await ref.read(healthProfileControllerProvider.notifier).save(profile);
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('저장되었습니다')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.paddingXl,
        AppDimensions.paddingMd,
        AppDimensions.paddingXl,
        AppDimensions.paddingXxl,
      ),
      children: [
        const _SectionLabel(AppStrings.healthInfoBodySection),
        const SizedBox(height: AppDimensions.paddingSm),
        _Card(
          children: [
            _FormRow(
              label: AppStrings.healthInfoHeight,
              controller: _heightCtrl,
              unit: 'cm',
            ),
            const _Divider(),
            _FormRow(
              label: AppStrings.healthInfoWeight,
              controller: _weightCtrl,
              unit: 'kg',
            ),
            const _Divider(),
            _FormRow(
              label: AppStrings.healthInfoAge,
              controller: _ageCtrl,
              unit: '세',
            ),
            const _Divider(),
            _GenderRow(
              value: _gender,
              onChanged: (v) => setState(() => _gender = v),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.paddingXl),
        const _SectionLabel(AppStrings.healthInfoWaterSection),
        const SizedBox(height: AppDimensions.paddingSm),
        _Card(
          children: [
            _FormRow(
              label: AppStrings.healthInfoWaterGoal,
              controller: _waterGoalCtrl,
              unit: 'mL',
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.paddingXxl),
        SizedBox(
          height: 54,
          child: ElevatedButton(
            onPressed: _saving ? null : _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.progressTeal,
              foregroundColor: AppColors.surface,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusXl),
              ),
            ),
            child: _saving
                ? const SizedBox(
                    width: AppDimensions.iconLg,
                    height: AppDimensions.iconLg,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.surface,
                    ),
                  )
                : const Text(
                    AppStrings.healthInfoSave,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppDimensions.paddingXs),
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
      elevation: 0,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        child: Column(children: children),
      ),
    );
  }
}

class _FormRow extends StatelessWidget {
  const _FormRow({
    required this.label,
    required this.controller,
    required this.unit,
  });

  final String label;
  final TextEditingController controller;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingXl,
        vertical: AppDimensions.paddingMd,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: TextField(
                    controller: controller,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.paddingXs),
                Text(
                  unit,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GenderRow extends StatelessWidget {
  const _GenderRow({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingXl,
        vertical: AppDimensions.paddingMd,
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 80,
            child: Text(
              AppStrings.healthInfoGender,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Spacer(),
          _GenderChip(
            label: AppStrings.healthInfoMale,
            selected: value == 'male',
            onTap: () => onChanged('male'),
          ),
          const SizedBox(width: AppDimensions.paddingSm),
          _GenderChip(
            label: AppStrings.healthInfoFemale,
            selected: value == 'female',
            onTap: () => onChanged('female'),
          ),
        ],
      ),
    );
  }
}

class _GenderChip extends StatelessWidget {
  const _GenderChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingLg,
          vertical: AppDimensions.paddingSm,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.progressTeal : AppColors.background,
          borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.surface : AppColors.textSecondary,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      color: AppColors.divider,
      indent: AppDimensions.paddingXl,
    );
  }
}
