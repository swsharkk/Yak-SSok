import '../../models/medicine.dart';
import '../medicine_repository.dart';

/// 로컬 mock 구현. 백엔드 확정 전까지 메모리에 보관.
class LocalMedicineRepository implements MedicineRepository {
  final List<Medicine> _myMedicines = const [
    Medicine(
      id: 'lipitor',
      name: '리피토',
      company: '한국화이자',
      dosage: '10mg',
    ),
    Medicine(
      id: 'metformin',
      name: '메트포르민',
      company: '대웅제약',
      dosage: '500mg',
    ),
    Medicine(
      id: 'lisinopril',
      name: '리시노프릴',
      company: '종근당',
      dosage: '5mg',
    ),
    Medicine(
      id: 'tylenol-500',
      name: '타이레놀정',
      company: '한국얀센',
      dosage: '500mg',
      description: '해열 및 진통 완화',
      cautions: '과량 복용하지 말고, 간 질환이 있다면 전문가와 상담하세요.',
    ),
    Medicine(
      id: 'ibuprofen-200',
      name: '이부프로펜정',
      company: '대웅제약',
      dosage: '200mg',
      description: '소염, 진통, 해열 완화',
      cautions: '위장 장애가 있거나 항응고제를 복용 중이면 전문가와 상담하세요.',
    ),
    Medicine(
      id: 'panpyrin',
      name: '판피린큐액',
      company: '동아제약',
      dosage: '20ml',
      description: '감기 증상 완화',
      cautions: '졸음이 올 수 있어 운전이나 기계 조작 시 주의하세요.',
    ),
    Medicine(
      id: 'bearse',
      name: '베아제정',
      company: '대웅제약',
      dosage: '1정',
      description: '소화불량 증상 완화',
      cautions: '증상이 지속되면 전문가와 상담하세요.',
    ),
  ];

  @override
  Future<List<Medicine>> search(String query) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final keyword = query.trim().toLowerCase();
    if (keyword.isEmpty) return const [];

    return _myMedicines.where((m) {
      return m.name.toLowerCase().contains(keyword) ||
          (m.company?.toLowerCase().contains(keyword) ?? false) ||
          (m.dosage?.toLowerCase().contains(keyword) ?? false);
    }).toList(growable: false);
  }

  @override
  Future<List<Medicine>> getMyMedicines() async =>
      List.unmodifiable(_myMedicines);

  @override
  Future<Medicine> register(Medicine medicine) async {
    // mock: 실제 저장 없이 그대로 반환.
    return medicine;
  }

  @override
  Future<void> remove(String id) async {}
}
