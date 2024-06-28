import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:heshamm/admin.dart';
import 'package:heshamm/football_fields_screen.dart';
import 'package:heshamm/home.dart';
import 'package:heshamm/login.dart';
import 'package:heshamm/play_station_room_management_screen.dart';
import 'package:heshamm/play_station_screen.dart';
import 'start_page.dart';
import 'admin_login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => StartPage(),
        '/adminLogin': (context) => AdminLoginScreen(),
        '/userLogin': (context) => UserLoginScreen(),
        '/home': (context) => HomeScreen(),
        '/adminDashboard': (context) => AdminDashboardScreen(),
        '/footballFields': (context) => FootballFieldFormScreen(
              adminId: '', role: '',
            ),
        '/playStation': (context) => PlayStationFormScreen(),
        // Add route for PlayStationRoomManagementScreen
        '/playStationRoomManagement': (context) =>
            PlayStationRoomManagementScreen(playStationId: ''), // Dummy ID
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
