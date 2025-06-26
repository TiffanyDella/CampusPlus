export 'dart:convert';

// Flutter core packages
export 'package:flutter/material.dart';
export 'package:flutter/services.dart';

// Third-party packages
export 'package:intl/date_symbol_data_local.dart';
export 'package:intl/intl.dart' hide TextDirection;
export 'package:provider/provider.dart';
export 'package:shared_preferences/shared_preferences.dart';
export 'package:flutter/foundation.dart';

// Project modules
export 'package:campus_plus/home/home.dart';
export 'package:campus_plus/schedule/schedule.dart';
export 'package:campus_plus/schedule/week.dart';
export 'package:campus_plus/schedule/week_swiper.dart';
export 'package:campus_plus/settings/searchTeacher.dart';
export 'package:campus_plus/settings/settings.dart';
export 'package:campus_plus/settings/about.dart';
export 'package:campus_plus/selected_teacher_provider.dart' hide TeacherSearchWidget;