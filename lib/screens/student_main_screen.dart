import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/app_notification_provider.dart';
import 'student_home_screen.dart';
import 'all_complaints_screen.dart';
import 'notifications_screen.dart';
import 'settings_screen.dart';

class StudentMainScreen extends StatefulWidget {
  const StudentMainScreen({super.key});

  @override
  State<StudentMainScreen> createState() => _StudentMainScreenState();
}

class _StudentMainScreenState extends State<StudentMainScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const StudentHomeScreen(),
      const AllComplaintsScreen(),
      const NotificationsScreen(),
      const SettingsScreen(),
    ];

    // Start watching notifications for this user
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final notifProvider =
          Provider.of<AppNotificationProvider>(context, listen: false);
      final userId = authProvider.currentUser?.uid;
      if (userId != null) {
        notifProvider.watchNotifications(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifProvider = Provider.of<AppNotificationProvider>(context);

    return Scaffold(
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
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          const NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt),
            label: 'All Complaints',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: notifProvider.unreadCount > 0,
              label: Text(
                notifProvider.unreadCount > 99
                    ? '99+'
                    : notifProvider.unreadCount.toString(),
              ),
              child: const Icon(Icons.notifications_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: notifProvider.unreadCount > 0,
              label: Text(
                notifProvider.unreadCount > 99
                    ? '99+'
                    : notifProvider.unreadCount.toString(),
              ),
              child: const Icon(Icons.notifications),
            ),
            label: 'Notifications',
          ),
          const NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
