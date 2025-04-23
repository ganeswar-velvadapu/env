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
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;

    if (reportProvider.reports.isEmpty) {
      return Center(
        child: Text(
          "No reports found",
          style: TextStyle(
            color: textColor,
            fontSize: 16,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: reportProvider.reports.length,
      itemBuilder: (context, index) {
        final report = reportProvider.reports[index];
        return Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black12),
            color: Colors.white,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report.title,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                _buildReportDetail("Description", report.description, textColor),
                _buildReportDetail("Location", report.location, textColor),
                _buildReportDetail("Status", report.status, textColor),
                _buildReportDetail("Added by", report.email, textColor),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReportDetail(String label, String value, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: textColor),
            ),
          ),
        ],
      ),
    );
  }
}