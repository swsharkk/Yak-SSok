import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../repositories/auth_repository.dart';
import '../repositories/health_repository.dart';
import '../repositories/impl/backend_auth_repository.dart';
import '../repositories/impl/backend_medicine_repository.dart';
import '../repositories/impl/backend_schedule_repository.dart';
import '../repositories/impl/backend_interaction_repository.dart';
import '../repositories/impl/native_health_repository.dart';
import '../repositories/interaction_repository.dart';
import '../repositories/medicine_repository.dart';
import '../repositories/schedule_repository.dart';

part 'repository_providers.g.dart';

@Riverpod(keepAlive: true)
AuthRepository authRepository(AuthRepositoryRef ref) =>
    BackendAuthRepository();

@Riverpod(keepAlive: true)
MedicineRepository medicineRepository(MedicineRepositoryRef ref) =>
    BackendMedicineRepository();

@Riverpod(keepAlive: true)
ScheduleRepository scheduleRepository(ScheduleRepositoryRef ref) =>
    BackendScheduleRepository();

@Riverpod(keepAlive: true)
HealthRepository healthRepository(HealthRepositoryRef ref) =>
    NativeHealthRepository();

@Riverpod(keepAlive: true)
InteractionRepository interactionRepository(InteractionRepositoryRef ref) =>
    BackendInteractionRepository();
