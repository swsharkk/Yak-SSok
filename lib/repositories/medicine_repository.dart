import '../models/medicine.dart';

/// 약 Repository 인터페이스.
/// 검색은 식약처 API를 사용하더라도, 사용자가 등록한 약 목록은
/// 백엔드(추후) 또는 로컬에 저장한다.
abstract class MedicineRepository {
  Future<List<Medicine>> search(String query);
  Future<List<Medicine>> getMyMedicines();
  Future<Medicine> register(Medicine medicine);
  Future<void> remove(String id);
}
