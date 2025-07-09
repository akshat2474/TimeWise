// In lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'models/timetable_model.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // CORRECTED: Initialize and set up timezones at the top level.
  // This ensures the timezone database is loaded before any scheduling occurs.
  tz.initializeTimeZones();
  final String timeZoneName = tz.local.name;
  tz.setLocalLocation(tz.getLocation(timeZoneName));

  // Initialize the notification service
  await NotificationService().init();
  
  final timetableModel = TimetableModel();
  await timetableModel.load();

  runApp(
    ChangeNotifierProvider(
      create: (context) => timetableModel,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TimeWise',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
