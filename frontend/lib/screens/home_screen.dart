import 'package:flutter/material.dart';
import 'package:frontend/providers/report_provider.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportProvider>().fetchReports();
    });
  }

  @override
  Widget build(BuildContext context) {
    final reportProvider = context.watch<ReportProvider>();

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
}
