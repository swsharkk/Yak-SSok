import 'package:flutter/material.dart';

class GuardianMainScreen extends StatefulWidget {
  const GuardianMainScreen({Key? key}) : super(key: key);

  @override
  State<GuardianMainScreen> createState() => _GuardianMainScreenState();
}

class _GuardianMainScreenState extends State<GuardianMainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F5), 
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A5A96), 
        elevation: 2,
        automaticallyImplyLeading: false, 
        title: Row(
          children: [
            const Text(
              'YAK-SSOK',
              style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 20, letterSpacing: 1.2),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                '보호자 서비스', 
                style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {},
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            //알림 바
            Container(
              width: double.infinity,
              color: const Color(0xFFE6F0FA),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Icon(Icons.gite, color: Color(0xFF1A5A96), size: 20),
                  const SizedBox(width: 8),
                  RichText(
                    text: const TextSpan(
                      text: '',
                      style: TextStyle(color: Colors.black87, fontSize: 13),
                      children: [
                        TextSpan(text: '홍길동 님', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A5A96))),
                        TextSpan(text: '의 복약 상태를 모니터링 중입니다.'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            //오늘의 복약 마감 달성률
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4), 
                border: Border.all(color: const Color(0xFFDCDDE0), width: 1.5), 
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '오늘의 복약 달성률',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2), 
                  ),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      
                      const Text(
                        '66%',
                        style: TextStyle(fontSize: 38, fontWeight: FontWeight.w900, color: Color(0xFF0D9488)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: const LinearProgressIndicator(
                                value: 2 / 3,
                                backgroundColor: Color(0xFFEAEAEA),
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0D9488)), // 로켓 청록색 게이지
                                minHeight: 14,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              '총 3회 중 2회 완료 / 저녁 약 1회 남음',
                              style: TextStyle(fontSize: 13, color: Colors.black54, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),

            // 바 분리
            const SizedBox(height: 4),
            Container(height: 8, color: const Color(0xFFEAECEF)),
            const SizedBox(height: 4),

            // 조회식 복약 스텝 그래프
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: const Color(0xFFDCDDE0), width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('실시간 복약 현황 조회', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildDeliveryStep(title: '아침약 [08:00]', status: '복용완료', time: '08:05 완료', isDone: true, isCurrent: false),
                      _buildStepArrow(),
                      _buildDeliveryStep(title: '점심약 [13:00]', status: '복용완료', time: '13:15 완료', isDone: true, isCurrent: false),
                      _buildStepArrow(),
                      _buildDeliveryStep(title: '저녁약 [19:00]', status: '미복용', time: '', isDone: false, isCurrent: true),
                    ],
                  ),
                ],
              ),
            ),

            // 바 분리
            const SizedBox(height: 4),
            Container(height: 8, color: const Color(0xFFEAECEF)),
            const SizedBox(height: 4),

            //오늘의 복약 리스트
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: const Color(0xFFDCDDE0), width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('오늘의 복약 리스트', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Divider(thickness: 2, color: Colors.black87), // 상단 구분선
                  
                  _buildBulletItem(time: '아침 [08:00]', name: '혈압약 (1알)', isDone: true, log: '08:05 정상 복용 완료'),
                  const Divider(thickness: 1, color: Color(0xFFEAEAEA)),
                  _buildBulletItem(time: '점심 [13:00]', name: '멀티비타민 (2알)', isDone: true, log: '13:15 정상 복용 완료'),
                  const Divider(thickness: 1, color: Color(0xFFEAEAEA)),
                  _buildBulletItem(time: '저녁 [19:00]', name: '고지혈증 약 (1알)', isDone: false, log: '복약 시간 지연'),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

 
  Widget _buildDeliveryStep({required String title, required String status, required String time, required bool isDone, required bool isCurrent}) {
    Color mainColor = isDone ? const Color(0xFF0D9488) : (isCurrent ? const Color(0xFFB91C1C) : Colors.grey);
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54)),
        const SizedBox(height: 6),
        
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isDone ? const Color(0xFFEBF7F5) : (isCurrent ? const Color(0xFFFEF2F2) : Colors.grey[100]),
            shape: BoxShape.circle,
            border: Border.all(color: mainColor, width: 2),
          ),
          child: Icon(
            isDone ? Icons.check_circle : (isCurrent ? Icons.error_outline : Icons.radio_button_unchecked),
            color: mainColor,
            size: 20,
          ),
        ),
        const SizedBox(height: 6),
        Text(status, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: mainColor)),
        Text(time, style: TextStyle(fontSize: 11, color: isCurrent ? const Color(0xFFB91C1C) : Colors.grey, fontWeight: FontWeight.w500)),
      ],
    );
  }

  // 화살표
  Widget _buildStepArrow() {
    return const Expanded(
      child: Padding(
        padding: EdgeInsets.only(bottom: 24.0),
        child: Text(
          '━━━━▶',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFFDCDDE0), fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildBulletItem({required String time, required String name, required bool isDone, required String log}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
         
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: isDone ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2),
              border: Border.all(color: isDone ? const Color(0xFF32D3C1) : const Color(0xFFFF8A8A), width: 1.5),
            ),
            child: Text(
              isDone ? '복용완료' : '미복용',
              style: TextStyle(color: isDone ? const Color(0xFF15803D) : const Color(0xFFB91C1C), fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          // 품목 및 시간
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(time, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.black)),
                const SizedBox(height: 1),
                Text(log, style: TextStyle(fontSize: 12, color: isDone ? Colors.blueGrey : const Color(0xFFB91C1C), fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          // 복약 알림 보내기
          isDone
              ? const Icon(Icons.check_circle, color: Color(0xFF15803D), size: 26)
              : ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('[$name] 님께 복약 알림을 보내드렸습니다.'),
                        backgroundColor: const Color(0xFF1A5A96),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB91C1C), // 마트 당일 한정 수량 특가 느낌의 강렬한 레드
                    elevation: 1,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)), // 각진 모양
                  ),
                  child: const Text(
                    '복약 알림 보내기', 
                    style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900),
                  ),
                ),
        ],
      ),
    );
  }
}