import 'package:appservico/screens/profile/edit_profile_screen.dart';
import 'package:appservico/screens/profile/user_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/search/search_screen.dart'; // nova importação
import 'services/auth_service.dart';
import 'services/worker_service.dart';
import 'utils/theme.dart';

void main() {
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
        ChangeNotifierProvider(create: (_) => UserService()), // novo
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
          '/edit-profile': (context) => const EditProfileScreen(), // nova rota
        },
      ),
    );
  }
}
