import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/counselor_register_screen.dart';
import 'screens/client/client_dashboard.dart';
import 'screens/counselor/counselor_dashboard.dart';
import 'screens/client/counselor_list_screen.dart';
import 'screens/client/counselor_profile_screen.dart';
import 'screens/common/messaging_screen.dart';
import 'screens/common/profile_screen.dart';
import 'screens/client/booking_screen.dart';
import 'screens/common/social_feed_screen.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Christian Counseling',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.grey,
        primaryColor: Colors.black,
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/counselor-register': (context) => const CounselorRegisterScreen(),
        '/client-dashboard': (context) => const ClientDashboard(),
        '/counselor-dashboard': (context) => const CounselorDashboard(),
        '/counselor-list': (context) => const CounselorListScreen(),
        '/messaging': (context) => const MessagingScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/social-feed': (context) => const SocialFeedScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/counselor-profile') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => CounselorProfileScreen(counselor: args),
          );
        } else if (settings.name == '/booking') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => BookingScreen(counselor: args),
          );
        }
        return null;
      },
    );
  }
}