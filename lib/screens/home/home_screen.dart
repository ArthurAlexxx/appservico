import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'worker_list.dart';
import '../favorites/favorites_screen.dart';
import '../profile/profile_screen.dart';
import '../profile/user_service.dart';
import '../../services/worker_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late final PageController _pageController;

  final List<Widget> _screens = [
    const WorkerListScreen(),
    const FavoritesScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  Future<bool> _onWillPop() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deseja sair do app?'),
        content: const Text('Tem certeza que quer sair?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Não'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sim'),
          ),
        ],
      ),
    );
    return shouldExit ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userService = Provider.of<UserService>(context);
    final workerService = Provider.of<WorkerService>(context, listen: false);

    return FutureBuilder<bool>(
      future: workerService.userHasWorker(userService.currentUserId),
      builder: (context, snapshot) {
        final hasWorker = snapshot.data ?? false;
        final showFab = _currentIndex == 0 &&
            userService.profileType == 'worker' &&
            !hasWorker;

        return WillPopScope(
          onWillPop: _onWillPop,
          child: Scaffold(
            body: PageView(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _currentIndex = index),
              physics: const BouncingScrollPhysics(),
              children: _screens,
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _currentIndex,
              selectedItemColor: theme.colorScheme.primary,
              unselectedItemColor: theme.colorScheme.onSurface.withOpacity(0.5),
              showUnselectedLabels: true,
              onTap: _onTabTapped,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favoritos'),
                BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
              ],
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              elevation: 8,
            ),
            floatingActionButton: showFab
                ? FloatingActionButton.extended(
                    onPressed: () {
                      Navigator.pushNamed(context, '/register-worker');
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Cadastrar'),
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 6,
                    tooltip: 'Cadastrar novo profissional',
                  )
                : null,
          ),
        );
      },
    );
  }
}
