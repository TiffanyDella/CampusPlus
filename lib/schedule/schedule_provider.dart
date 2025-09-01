import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'scheduleParse.dart';

class ScheduleProvider extends ChangeNotifier {
  List<Map<String, dynamic>>? _schedule;
  String? _teacher;
  bool _loading = false;
  String? _error;

  List<Map<String, dynamic>>? get schedule => _schedule;
  String? get teacher => _teacher;
  bool get loading => _loading;
  String? get error => _error;

  ScheduleProvider() {
    Connectivity().onConnectivityChanged.listen((conn) async {
      if (conn != ConnectivityResult.none && _teacher != null && _teacher!.isNotEmpty) {
        await reloadFromServer(_teacher!);
      }
    });
  }

  Future<void> loadCache(String teacher) async {
    _teacher = teacher;
    _error = null;
    _loading = false;
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('schedule_cache_$teacher');
    if (jsonString != null) {
      final List<dynamic> decoded = jsonDecode(jsonString);
      _schedule = decoded.cast<Map<String, dynamic>>();
    } else {
      _schedule = null;
    }
    notifyListeners();
  }

  Future<void> reloadFromServer(String teacher) async {
    _teacher = teacher;
    _loading = true;
    _error = null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none || teacher.isEmpty) {
      _error = 'Нет соединения';
      _loading = false;
      notifyListeners();
      return;
    }
    try {
      final url = 'https://rasps.nsuem.ru/teacher/${Uri.encodeComponent(teacher)}';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        throw Exception('Ошибка загрузки: ${response.statusCode}');
      }
      final scheduleList = parseSchedule(
        ScheduleParseInput(html: response.body, selectedTeacher: teacher)
      );
      _schedule = scheduleList;
      prefs.setString('schedule_cache_$teacher', jsonEncode(scheduleList));
      _loading = false;
      _error = null;
      notifyListeners();
    } catch (e) {
      // если кэш есть, просто "молчим" о сетевой ошибке и позволяем UI показать кэш, иначе выводим ошибку
      final localCache = prefs.getString('schedule_cache_$teacher');
      if (localCache != null) {
        _loading = false;
        notifyListeners();
      } else {
        _error = 'Ошибка: ${e.toString()}';
        _loading = false;
        notifyListeners();
      }
    }
  }
}
