import 'package:flutter/material.dart';
import 'package:frontend/providers/report_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<String> _routes = [
    '/',            // Reports screen
    '/report/add',  // Add Report (to be created)
    '/profile',     // Profile screen
  ];

  @override
  void initState() {
    super.initState();
    Provider.of<ReportProvider>(context, listen: false).fetchReports();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    context.go(_routes[index]); // Navigate using GoRouter
  }

  Widget _buildReportList(BuildContext context) {
    final reportProvider = Provider.of<ReportProvider>(context);
    return reportProvider.reports.isEmpty
        ? const Center(child: Text("No reports found"))
        : ListView.builder(
            itemCount: reportProvider.reports.length,
            itemBuilder: (context, index) {
              final report = reportProvider.reports[index];
              return Card(
                margin: const EdgeInsets.all(8),
                elevation: 4,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    report.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Description: ${report.description}'),
                      Text('Location: ${report.location}'),
                      Text('Status: ${report.status}'),
                      Text('Added by: ${report.email}'),
                    ],
                  ),
                ),
              );
            },
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reports")),
      body: _buildReportList(context),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Add Report',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
