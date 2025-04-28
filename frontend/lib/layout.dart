import 'package:flutter/material.dart';
import 'package:frontend/screens/add_a_report.dart';
import 'package:frontend/screens/home_screen.dart';
import 'package:frontend/screens/map_ngos.dart';
import 'package:frontend/screens/profile_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Layout extends StatefulWidget {
  const Layout({super.key});

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  int _currentIndex = 0;
  bool _hasValidToken = false; 
  final FlutterSecureStorage storage = FlutterSecureStorage();

  List<Widget> _screens = [];
  
  @override
  void initState() {
    super.initState();
    _checkForValidToken();
  }
  Future<void> _checkForValidToken() async {
    final token = await storage.read(key: 'token');
    if (token != null && token.isNotEmpty) {
      setState(() {
        _hasValidToken = true;
        _screens = const [
          HomeScreen(),
          AddReportScreen(),
          ProfileScreen(),
          MapNGOs(),
        ];
      });
    } else {
      setState(() {
        _hasValidToken = false;
        _screens = const [
          HomeScreen(),
          ProfileScreen(),
          MapNGOs(),
        ];
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onDrawerItemTapped(int index) {
    Navigator.of(context).pop();
    _onItemTapped(index);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        title: Text(
          "BIOVERSE",
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        iconTheme: IconThemeData(
          color: theme.colorScheme.onSurface,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () => _onItemTapped(2),
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: theme.colorScheme.onSurface,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
              child: const Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              title: Text(
                'Home',
                style: TextStyle(color: theme.colorScheme.onSurface),
              ),
              onTap: () => _onDrawerItemTapped(0),
            ),
            if (_hasValidToken) 
              ListTile(
                title: Text(
                  'Add an Event',
                  style: TextStyle(color: theme.colorScheme.onSurface),
                ),
                onTap: () => _onDrawerItemTapped(1),
              ),
            ListTile(
              title: Text(
                'Profile',
                style: TextStyle(color: theme.colorScheme.onSurface),
              ),
              onTap: () => _onDrawerItemTapped(_hasValidToken ? 2 : 1),
            ),
            ListTile(
              title: Text(
                'Map NGOs',
                style: TextStyle(color: theme.colorScheme.onSurface),
              ),
              onTap: () => _onDrawerItemTapped(_hasValidToken ? 3 : 2),
            ),
          ],
        ),
      ),
      body: _screens.isEmpty 
        ? Center(child: CircularProgressIndicator())  // Show loading indicator until the token check is done
        : _screens[_currentIndex],  // Display selected screen based on the current index
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.black12, width: 0.5),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home, 'Home'),
              if (_hasValidToken) // Show Add Report only if the token is valid
                _buildNavItem(1, Icons.add, 'Add Report'),
              _buildNavItem(2, Icons.person, 'Profile'),
              _buildNavItem(3, Icons.location_on, 'Map NGOs'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final theme = Theme.of(context);
    final isSelected = _currentIndex == index;
    
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected 
                ? theme.colorScheme.onSurface 
                : Colors.grey,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected 
                  ? theme.colorScheme.onSurface 
                  : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
