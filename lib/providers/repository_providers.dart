import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../core/constants.dart';
import '../repositories/auth_repository.dart';
import '../repositories/health_repository.dart';
import '../repositories/impl/backend_schedule_repository.dart';
import '../repositories/impl/firebase_auth_repository.dart';
import '../repositories/impl/local_interaction_repository.dart';
import '../repositories/impl/local_medicine_repository.dart';
import '../repositories/impl/local_schedule_repository.dart';
import '../repositories/impl/native_health_repository.dart';
import '../repositories/interaction_repository.dart';
import '../repositories/medicine_repository.dart';
import '../repositories/schedule_repository.dart';
import '../services/medicine_service.dart';

part 'repository_providers.g.dart';

@Riverpod(keepAlive: true)
AuthRepository authRepository(AuthRepositoryRef ref) =>
    FirebaseAuthRepository();

@Riverpod(keepAlive: true)
MedicineRepository medicineRepository(MedicineRepositoryRef ref) =>
    LocalMedicineRepository();

@Riverpod(keepAlive: true)
ScheduleRepository scheduleRepository(ScheduleRepositoryRef ref) {
  if (AppConstants.apiBaseUrl.isNotEmpty) {
    return BackendScheduleRepository();
  }
  return LocalScheduleRepository();
}

@Riverpod(keepAlive: true)
HealthRepository healthRepository(HealthRepositoryRef ref) =>
    NativeHealthRepository();

@Riverpod(keepAlive: true)
InteractionRepository interactionRepository(InteractionRepositoryRef ref) =>
    LocalInteractionRepository();

/// 식약처 API 서비스. 백엔드와 무관하게 항상 사용.
@Riverpod(keepAlive: true)
MedicineService medicineService(MedicineServiceRef ref) => MedicineService();
