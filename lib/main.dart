import 'package:campus_plus/selected_teacher_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'campus_plus.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ru_RU', null);
  runApp(
    ChangeNotifierProvider(
      create: (_) => SelectedTeacherProvider(),
      child: const CampusPlus(),
    ),
  );
}

