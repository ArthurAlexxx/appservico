import 'package:appservico/screens/profile/edit_profile_screen.dart';
import 'package:appservico/screens/profile/register_worker_screen.dart';
import 'package:appservico/screens/profile/user_service.dart';
import 'package:appservico/services/auth_service.dart';
import 'package:appservico/services/subscription/subscription_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:appservico/services/auth_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/search/search_screen.dart';
import 'services/worker_service.dart';
import 'services/subscription_service.dart';
import 'utils/theme.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => WorkerService()),
        ChangeNotifierProvider(create: (_) => UserService()),
        ChangeNotifierProvider(create: (_) => SubscriptionService()),
      ],
      child: MaterialApp(
        title: 'ServiçoJá',
        debugShowCheckedModeBanner: false,
        theme: appTheme,
        home: LoginScreen(),
        routes: {
          '/login': (context) => LoginScreen(),
          '/register': (context) => RegisterScreen(),
          '/home': (context) => HomeScreen(),
          '/search': (context) => const SearchScreen(),
          '/edit-profile': (context) => const EditProfileScreen(),
          '/register-worker': (context) => const RegisterWorkerScreen(),
          '/subscription': (context) => const SubscriptionScreen(),
        },
      ),
    );
  }
}
