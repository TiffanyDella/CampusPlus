

import 'package:flutter/material.dart';
import 'Settings/widgets/settingsScreen/Settings.dart';

import 'home/homeWidget.dart';
import 'schedule/schedule.dart';
import 'themes.dart';



class ScheduleWizard extends StatefulWidget {
  const ScheduleWizard({super.key});
  @override
  State<ScheduleWizard> createState() => _ScheduleWizardState();
}

class _ScheduleWizardState extends State<ScheduleWizard> {
  int _selectedPageIndex = 0;
  final PageController _pageController = PageController();

  static final List<Widget> _pages = [
    Home(),
    Schedule(),
    Settings(),
  ];


    @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    if (_selectedPageIndex != index) {
      setState(() {
        _selectedPageIndex = index;
      });
    }
  }

  void _onNavBarTap(int index) {
    if (_selectedPageIndex != index) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 200),
        curve: Curves.ease,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      home: Scaffold(
        body: PageView(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          physics: const BouncingScrollPhysics(),
          children: _pages,
        ),
        bottomNavigationBar: BottomNavigationBar(
          onTap: _onNavBarTap,
          currentIndex: _selectedPageIndex,
          selectedItemColor: lightTheme.primaryColor,
          unselectedItemColor: lightTheme.hintColor,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Главная"),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: "Расписание"),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Настройки"),
          ],
        ),
      ),
    );
  }
}