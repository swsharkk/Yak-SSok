import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme.dart';
import 'calendar/calendar_screen.dart';
import 'home/home_screen.dart';
import 'home/widgets/add_medicine_sheet.dart';
import 'more/more_screen.dart';
import 'search/search_screen.dart';

/// 하단 탭(홈/검색/달력/더보기)을 가진 루트 화면.
/// 라우팅 단계에서 GoRouter ShellRoute로 교체할 수 있도록 별도 위젯으로 분리.
class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _index = 0;

  static const _tabs = <Widget>[
    HomeScreen(),
    SearchScreen(),
    CalendarScreen(),
    MoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(index: _index, children: _tabs),
      floatingActionButton: _index == 0
          ? FloatingActionButton(
              onPressed: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const AddMedicineSheet(),
              ),
              backgroundColor: AppColors.progressTeal,
              foregroundColor: Colors.white,
              elevation: 4,
              child: const Icon(Icons.add_rounded),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: AppStrings.tabHome,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_rounded),
            label: AppStrings.tabSearch,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_rounded),
            label: AppStrings.tabCalendar,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz_rounded),
            label: AppStrings.tabMore,
          ),
        ],
      ),
    );
  }
}
