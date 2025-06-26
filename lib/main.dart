import 'package:intl/date_symbol_data_local.dart';
import 'export/export.dart';

void main() async {
  await initializeDateFormatting('ru_RU', null);
  runApp(
    
    ChangeNotifierProvider(
      create: (_) => SelectedTeacherProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
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
    final theme = Theme.of(context);

    return MaterialApp(
    debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.blue,
        hintColor: Colors.grey,
      ),
      home: Scaffold(
        body: PageView(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          children: _pages,
          physics: const BouncingScrollPhysics(),
        ),
        bottomNavigationBar: BottomNavigationBar(
          onTap: _onNavBarTap,
          currentIndex: _selectedPageIndex,
          selectedItemColor: theme.primaryColor,
          unselectedItemColor: theme.hintColor,
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