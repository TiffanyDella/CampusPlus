import 'package:campus_plus/Settings/Settings.dart';
import 'package:campus_plus/home/home.dart';

import 'package:campus_plus/schedule/schedule.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  var _selectedPageIndex = 0;
  final _pageController = PageController(); // Initialize the PageController here

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.blue,
        hintColor: Colors.grey,
      ),
      home: Scaffold(
        body: PageView(
          onPageChanged: (value) {
            setState(() {
              _selectedPageIndex = value;
            });
          },
          controller: _pageController,  // Use the PageController initialized in the state
          children: [
            Home(),
            Schedule(),
            Settings(),
          ],
        ),
        bottomNavigationBar: Builder(
          builder: (context) {
            final theme = Theme.of(context);  // Get the theme via BuildContext

            return BottomNavigationBar(
              onTap: _openPage,
              currentIndex: _selectedPageIndex,
              selectedItemColor: theme.primaryColor,  // Use theme for the selected color
              unselectedItemColor: theme.hintColor,  // Use theme for the unselected color

              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: "Главная"),
                BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: "Расписание"),
                BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Настройки"),
              ],
            );
          },
        ),
      ),
    );
  }

  void _openPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),  // Set a reasonable duration for the animation
      curve: Curves.ease,  // You can also change the curve if you like
    );
  }
}
