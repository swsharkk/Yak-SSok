// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'interaction_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$drugInteractionsHash() => r'034ac23d8bbace3e968e3edca6e5ef91bf7f0bc5';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// 사용자 등록 약 목록의 상호작용 위험 조합 반환.
///
/// Copied from [drugInteractions].
@ProviderFor(drugInteractions)
const drugInteractionsProvider = DrugInteractionsFamily();

/// 사용자 등록 약 목록의 상호작용 위험 조합 반환.
///
/// Copied from [drugInteractions].
class DrugInteractionsFamily extends Family<AsyncValue<List<DrugInteraction>>> {
  /// 사용자 등록 약 목록의 상호작용 위험 조합 반환.
  ///
  /// Copied from [drugInteractions].
  const DrugInteractionsFamily();

  /// 사용자 등록 약 목록의 상호작용 위험 조합 반환.
  ///
  /// Copied from [drugInteractions].
  DrugInteractionsProvider call(
    List<String> medicineNames,
  ) {
    return DrugInteractionsProvider(
      medicineNames,
    );
  }

  @override
  DrugInteractionsProvider getProviderOverride(
    covariant DrugInteractionsProvider provider,
  ) {
    return call(
      provider.medicineNames,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'drugInteractionsProvider';
}

/// 사용자 등록 약 목록의 상호작용 위험 조합 반환.
///
/// Copied from [drugInteractions].
class DrugInteractionsProvider
    extends AutoDisposeFutureProvider<List<DrugInteraction>> {
  /// 사용자 등록 약 목록의 상호작용 위험 조합 반환.
  ///
  /// Copied from [drugInteractions].
  DrugInteractionsProvider(
    List<String> medicineNames,
  ) : this._internal(
          (ref) => drugInteractions(
            ref as DrugInteractionsRef,
            medicineNames,
          ),
          from: drugInteractionsProvider,
          name: r'drugInteractionsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$drugInteractionsHash,
          dependencies: DrugInteractionsFamily._dependencies,
          allTransitiveDependencies:
              DrugInteractionsFamily._allTransitiveDependencies,
          medicineNames: medicineNames,
        );

  DrugInteractionsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.medicineNames,
  }) : super.internal();

  final List<String> medicineNames;

  @override
  Override overrideWith(
    FutureOr<List<DrugInteraction>> Function(DrugInteractionsRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DrugInteractionsProvider._internal(
        (ref) => create(ref as DrugInteractionsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        medicineNames: medicineNames,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<DrugInteraction>> createElement() {
    return _DrugInteractionsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DrugInteractionsProvider &&
        other.medicineNames == medicineNames;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, medicineNames.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin DrugInteractionsRef
    on AutoDisposeFutureProviderRef<List<DrugInteraction>> {
  /// The parameter `medicineNames` of this provider.
  List<String> get medicineNames;
}

class _DrugInteractionsProviderElement
    extends AutoDisposeFutureProviderElement<List<DrugInteraction>>
    with DrugInteractionsRef {
  _DrugInteractionsProviderElement(super.provider);

  @override
  List<String> get medicineNames =>
      (origin as DrugInteractionsProvider).medicineNames;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
