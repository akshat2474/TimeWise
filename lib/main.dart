// In lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'models/timetable_model.dart';
import 'services/notification_service.dart'; // Import the service

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize the notification service
  await NotificationService().init();
  
  final timetableModel = TimetableModel();
  await timetableModel.load(); // Load data at startup

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
        // Add other theme customizations if needed
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
