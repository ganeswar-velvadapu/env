import 'package:flutter/material.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/screens/add_a_event.dart';
import 'package:frontend/screens/add_a_report.dart';
import 'package:frontend/screens/all_events.dart';
import 'package:frontend/screens/home_screen.dart';
import 'package:frontend/screens/map_ngos.dart';
import 'package:frontend/screens/my_events.dart';
import 'package:frontend/screens/profile_screen.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class Layout extends StatefulWidget {
  const Layout({super.key});

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  int _currentNavIndex = 0;
  int _currentDrawerIndex = 0;

  List<Widget> _navScreens = [];
  List<Widget> _drawerScreens = [];

  Widget? _activeScreen;

  bool _isInitialized = false;

  // Green color palette for NGO app
  final primaryGreen = const Color(0xFF2E7D32); // Dark green
  final secondaryGreen = const Color(0xFF4CAF50); // Medium green
  final lightGreen = const Color(0xFF8BC34A); // Light green
  final accentGreen = const Color(0xFF00C853); // Bright green

  @override
  void initState() {
    super.initState();

    _navScreens = [const HomeScreen()];
    _activeScreen = _navScreens[0];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _setupScreens();
  }

  void _setupScreens() {
    final authProvider = context.read<AuthProvider>();
    final isAuthenticated = authProvider.isAuthenticated;
    final isNGO = authProvider.user?.userType == UserType.ngo;

    setState(() {
      if (isAuthenticated) {
        _navScreens = [
          const HomeScreen(),
          const AddReportScreen(),
          const ProfileScreen(),
          const MapNGOs(),
        ];

        // Default drawer screens for all authenticated users
        _drawerScreens = [
          const HomeScreen(),
          const AllEventsScreen(),
          const MapNGOs(),
        ];
        
        // Add NGO-specific screens if the user is an NGO
        if (isNGO) {
          _drawerScreens.insertAll(2, [
            AddEventScreen(),
            MyEvents(),
          ]);
        }
      } else {
        _navScreens = [
          const HomeScreen(),
          const ProfileScreen(),
          const MapNGOs(),
        ];

        _drawerScreens = [
          const HomeScreen(),
          const AllEventsScreen(),
          const MapNGOs(),
        ];
      }

      if (_activeScreen != null && _navScreens.contains(_activeScreen)) {
        _currentNavIndex = _navScreens.indexOf(_activeScreen!);
      } else {
        _activeScreen = _navScreens[0];
        _currentNavIndex = 0;
      }

      _isInitialized = true;
    });
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _currentNavIndex = index;
      _activeScreen = _navScreens[index];
    });
  }

  void _onDrawerItemTapped(int index) {
    setState(() {
      _currentDrawerIndex = index;
      _activeScreen = _drawerScreens[index];

      if (_navScreens.contains(_activeScreen)) {
        _currentNavIndex = _navScreens.indexOf(_activeScreen!);
      }
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isAuthenticated = authProvider.isAuthenticated;
    final isNGO = authProvider.user?.userType == UserType.ngo;

    if (_isInitialized &&
        ((isAuthenticated && _navScreens.length == 3) ||
            (!isAuthenticated && _navScreens.length == 4))) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _setupScreens();
      });
    }

    if (!_isInitialized) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: primaryGreen,
          )
        )
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryGreen,
        centerTitle: true,
        elevation: 0,
        title: const Text(
          "BIOVERSE",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.2,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              final profileIndex = isAuthenticated ? 2 : 1;
              setState(() {
                _currentNavIndex = profileIndex;
                _activeScreen = _navScreens[profileIndex];
              });
            },
          ),
        ],
      ),
      drawer: _buildDrawer(isAuthenticated, isNGO),
      body: _activeScreen,
      bottomNavigationBar: _buildBottomNavBar(isAuthenticated),
    );
  }

  Widget _buildDrawer(bool isAuthenticated, bool isNGO) {
    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            color: primaryGreen,
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.eco,
                  color: Colors.white,
                  size: 40,
                ),
                const SizedBox(height: 10),
                Text(
                  isAuthenticated
                      ? 'Welcome, ${context.read<AuthProvider>().user?.email ?? "User"}'
                      : 'BIOVERSE Menu',
                  style: const TextStyle(
                    color: Colors.white, 
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (isNGO)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: accentGreen,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      'NGO Account',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Home
          _buildDrawerItem(
            icon: Icons.home,
            title: 'Home',
            index: 0,
          ),
          
          _buildDrawerItem(
            icon: Icons.event,
            title: 'All Events',
            index: 1,
          ),
          
          // NGO-specific menu items
          if (isAuthenticated && isNGO) ...[
            _buildDrawerItem(
              icon: Icons.add_box,
              title: 'Add an Event',
              index: 2,
            ),
            _buildDrawerItem(
              icon: Icons.event_note,
              title: 'My Events',
              index: 3,
            ),
          ],
          
          _buildDrawerItem(
            icon: Icons.location_on,
            title: 'Map NGOs',
            index: isAuthenticated && isNGO ? 4 : 2,
          ),
          const Spacer(),
          if (isAuthenticated)
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () async {
                await storage.delete(key: 'token');
                context.read<AuthProvider>().setUser(null);
                context.go('/login');
              },
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required int index,
  }) {
    final isSelected = _currentDrawerIndex == index;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? primaryGreen : Colors.grey[700],
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? primaryGreen : Colors.grey[800],
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () => _onDrawerItemTapped(index),
    );
  }

  Widget _buildBottomNavBar(bool isAuthenticated) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Home
            _buildNavItem(0, Icons.home, 'Home'),

            // Add Report (only if authenticated)
            if (isAuthenticated)
              _buildNavItem(1, Icons.assignment, 'Add Report'),

            // Profile
            _buildNavItem(isAuthenticated ? 2 : 1, Icons.person, 'Profile'),

            // Map NGOs
            _buildNavItem(
              isAuthenticated ? 3 : 2,
              Icons.location_on,
              'Map NGOs',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentNavIndex == index;

    return GestureDetector(
      onTap: () => _onNavItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? primaryGreen : Colors.grey,
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? primaryGreen : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}