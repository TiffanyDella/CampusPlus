import 'package:campus_plus/export/export.dart';


class SelectedTeacherProvider extends ChangeNotifier {
  static const String _prefsKey = '_selectedTeacher';

  String? _teacher;
  bool _isLoading = false;
  String? _error;

  String? get teacher => _teacher;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasTeacher => _teacher?.isNotEmpty == true;

  
  Future<void> init() async {
    await _runWithLoading(_loadFromPrefs);
  }

  
  Future<void> setTeacher(String teacher) async {
    await _runWithLoading(() async {
      _teacher = teacher;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, teacher);
      _error = null;
    });
  }


  Future<void> clearTeacher() async {
    await _runWithLoading(() async {
      _teacher = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefsKey);
      _error = null;
    });
  }

   Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _teacher = prefs.getString(_prefsKey);
    _error = null;
  }

  
  Future<void> _runWithLoading(Future<void> Function() action) async {
    _setLoading(true);
    try {
      await action();
    } catch (e, stack) {
      _error = 'Ошибка: ${e.toString()}';
      
    }
    _setLoading(false);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}