import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'schedule_provider.dart';

class SelectedTeacherProvider extends ChangeNotifier {
  String? _teacher;
  bool _isLoading = true;
  String? _error;

  String? get teacher => _teacher;
  bool get isLoading => _isLoading;
  String? get error => _error;

 
  bool get hasTeacher => _teacher != null && _teacher!.isNotEmpty;

  SelectedTeacherProvider() {
    _loadTeacher();
  }

  Future<void> _loadTeacher() async {
    _isLoading = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      _teacher = prefs.getString('selected_teacher');
      _error = null;
    } catch (e) {
      _error = 'Ошибка загрузки преподавателя';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> setTeacher(String teacher, BuildContext context) async {
    _isLoading = true;
    notifyListeners();
    try {
      _teacher = teacher;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_teacher', teacher);
      _error = null;
    } catch (e) {
      _error = 'Ошибка сохранения преподавателя';
    }
    _isLoading = false;
    notifyListeners();

  
    try {
      await Provider.of<ScheduleProvider>(context, listen: false).reloadFromServer(teacher);
    } catch (e) {
     
    }


  }

  Future<void> clearTeacher() async {
    _isLoading = true;
    notifyListeners();
    try {
      _teacher = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('selected_teacher');
      _error = null;
    } catch (e) {
      _error = 'Ошибка сброса преподавателя';
    }
    _isLoading = false;
    notifyListeners();
  }
}