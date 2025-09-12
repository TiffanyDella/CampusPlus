import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:schedule_wizard/view/ScheduleWizard.dart';

import 'ViewModel/schedule_provider.dart';
import 'ViewModel/selected_teacher_provider.dart';
import 'model/firebase_options.dart';





void main() async {
  await initializeDateFormatting('ru_RU', null);
  WidgetsFlutterBinding.ensureInitialized();
Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);


  runApp(
    
    MultiProvider(
      providers: [
      
        ChangeNotifierProvider(create: (_) => ScheduleProvider(),),
        ChangeNotifierProvider(create: (_) => SelectedTeacherProvider()),
        
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: ScheduleWizard(),
      ),
    ),
  );
}
