// update_checker.dart
import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateChecker {
  static const String repoOwner = 'your-username';
  static const String repoName = 'your-repo-name';
  
  // Проверка обновлений с кешированием
  static Future<Map<String, dynamic>?> checkForUpdate() async {
    try {
      // Проверяем, нужно ли делать запрос (не чаще чем раз в день)
      if (!await _shouldCheckForUpdate()) {
        return null;
      }

      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      
      final response = await http.get(
        Uri.parse('https://api.github.com/repos/$repoOwner/$repoName/releases/latest'),
        headers: {'Accept': 'application/vnd.github.v3+json'},
      );
      
      if (response.statusCode == 200) {
        final releaseData = json.decode(response.body);
        final latestVersion = releaseData['tag_name'].toString().replaceFirst('v', '');
        final releaseNotes = releaseData['body'];
        final apkUrl = _getApkDownloadUrl(releaseData);
        
        final hasUpdate = _compareVersions(currentVersion, latestVersion) < 0;
        
        // Сохраняем время последней проверки
        await _setLastUpdateCheck();
        
        if (hasUpdate) {
          // Проверяем, не пропустили ли мы уже эту версию
          final shouldShowUpdate = !await _isVersionSkipped(latestVersion);
          
          return {
            'hasUpdate': true,
            'currentVersion': currentVersion,
            'latestVersion': latestVersion,
            'releaseNotes': releaseNotes,
            'downloadUrl': apkUrl,
            'shouldShow': shouldShowUpdate,
            'releaseData': releaseData,
          };
        }
      }
    } catch (e) {
      print('Error checking for updates: $e');
    }
    return null;
  }
  
  static String? _getApkDownloadUrl(Map<String, dynamic> releaseData) {
    final assets = releaseData['assets'] as List<dynamic>?;
    if (assets != null) {
      for (final asset in assets) {
        final name = asset['name'].toString().toLowerCase();
        if (name.endsWith('.apk')) {
          return asset['browser_download_url'];
        }
      }
    }
    return null;
  }
  
  static int _compareVersions(String v1, String v2) {
    final v1Parts = v1.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final v2Parts = v2.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    
    for (int i = 0; i < math.max(v1Parts.length, v2Parts.length); i++) {
      final v1Part = i < v1Parts.length ? v1Parts[i] : 0;
      final v2Part = i < v2Parts.length ? v2Parts[i] : 0;
      
      if (v1Part != v2Part) {
        return v1Part.compareTo(v2Part);
      }
    }
    return 0;
  }
  
  // Проверка необходимости проверки обновлений
  static Future<bool> _shouldCheckForUpdate() async {
    final prefs = await SharedPreferences.getInstance();
    final lastCheck = prefs.getInt('last_update_check') ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    
    // Проверяем не чаще чем раз в 12 часов
    return (now - lastCheck) > 12 * 60 * 60 * 1000;
  }
  
  // Сохранение времени последней проверки
  static Future<void> _setLastUpdateCheck() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_update_check', 
        DateTime.now().millisecondsSinceEpoch);
  }
  
  // Проверка, была ли версия пропущена
  static Future<bool> _isVersionSkipped(String version) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('skipped_version') == version;
  }
  
  // Пропустить версию
  static Future<void> skipVersion(String version) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('skipped_version', version);
  }
}