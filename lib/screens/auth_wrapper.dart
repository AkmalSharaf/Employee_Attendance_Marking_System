import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'employee_registration_screen.dart';
import 'attendance_screen.dart';

/// Auth Wrapper - Handles authentication state navigation
///
/// Monitors Firebase Authentication state and automatically navigates
/// between Login screen (when not authenticated) and Home screen (when authenticated).
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authService.authStateChanges,
      builder: (context, snapshot) {
        // Loading state - show splash while checking auth
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Checking authentication...'),
                ],
              ),
            ),
          );
        }

        // Check if user is authenticated
        final User? user = snapshot.data;

        if (user != null) {
          // User is authenticated - show home screen
          debugPrint('User authenticated: ${user.email}');
          return const HomeScreenWithLogout();
        } else {
          // User is not authenticated - show login screen
          debugPrint('User not authenticated - showing login');
          return const LoginScreen();
        }
      },
    );
  }
}

/// Home Screen with Logout functionality
///
/// Wraps the original HomeScreen with an AppBar that includes
/// a logout button for the admin.
class HomeScreenWithLogout extends StatelessWidget {
  const HomeScreenWithLogout({super.key});

  @override
  Widget build(BuildContext context) {
    return const _HomeScreenWithBottomNav();
  }
}

/// Custom Home Screen with Bottom Navigation and Logout
class _HomeScreenWithBottomNav extends StatefulWidget {
  const _HomeScreenWithBottomNav();

  @override
  State<_HomeScreenWithBottomNav> createState() => _HomeScreenWithBottomNavState();
}

class _HomeScreenWithBottomNavState extends State<_HomeScreenWithBottomNav> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    EmployeeRegistrationScreen(),
    AttendanceScreen(),
  ];

  Future<void> _handleLogout() async {
    final bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Colors.white,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true && mounted) {
      try {
        final AuthService authService = AuthService();
        await authService.signOut();
        debugPrint('Admin logged out successfully');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Logged out successfully'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error logging out: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Attendance'),
        actions: [
          // User email display
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Center(
              child: FutureBuilder<String?>(
                future: Future.value(AuthService().getCurrentUserEmail()),
                builder: (context, snapshot) {
                  final email = snapshot.data ?? 'Admin';
                  return Text(
                    email,
                    style: const TextStyle(fontSize: 14),
                  );
                },
              ),
            ),
          ),
          // Logout button
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.person_add_outlined),
            selectedIcon: Icon(Icons.person_add),
            label: 'Register',
          ),
          NavigationDestination(
            icon: Icon(Icons.check_circle_outline),
            selectedIcon: Icon(Icons.check_circle),
            label: 'Attendance',
          ),
        ],
      ),
    );
  }
}
