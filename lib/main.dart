import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'models/timetable_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize the timetable model and load data
  final timetableModel = TimetableModel();
  await timetableModel.load();
  
  runApp(
    ChangeNotifierProvider.value(
      value: timetableModel,
      child: const TimeWiseApp(),
    ),
  );
}

class TimeWiseApp extends StatelessWidget {
  const TimeWiseApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TimeWise',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const SplashScreen(),
      routes: {
        '/home': (context) => const HomeScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
