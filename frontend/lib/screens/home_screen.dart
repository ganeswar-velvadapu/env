import 'package:flutter/material.dart';
import 'package:frontend/providers/report_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Green color palette for app theme
  final primaryGreen = const Color(0xFF2E7D32); // Dark green
  final secondaryGreen = const Color(0xFF4CAF50); // Medium green
  final lightGreen = const Color(0xFFE8F5E9); // Very light green background
  final accentGreen = const Color(0xFF00C853); // Bright green for accents
  
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() => _isLoading = true);
      await context.read<ReportProvider>().fetchReports();
      setState(() => _isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final reportProvider = context.watch<ReportProvider>();
    final textColor = Colors.grey[800];

    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: primaryGreen),
            const SizedBox(height: 16),
            Text(
              "Loading reports...",
              style: TextStyle(
                color: primaryGreen,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (reportProvider.reports.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 70,
              color: Colors.grey[400],
            ).animate().fade(duration: 500.ms).scale(delay: 300.ms),
            const SizedBox(height: 16),
            Text(
                  "No reports found",
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                )
                .animate()
                .fade(duration: 500.ms, delay: 200.ms)
                .slideY(begin: 0.3, end: 0),
            const SizedBox(height: 8),
            Text(
              "Check back later or add a new report",
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ).animate().fade(duration: 500.ms, delay: 400.ms),
          ],
        ),
      );
    }

    return Container(
      color: lightGreen.withOpacity(0.5),
      child: RefreshIndicator(
        color: primaryGreen,
        onRefresh: () async {
          setState(() => _isLoading = true);
          await context.read<ReportProvider>().fetchReports();
          setState(() => _isLoading = false);
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: reportProvider.reports.length,
          itemBuilder: (context, index) {
            final report = reportProvider.reports[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: ReportCard(
                report: report,
                primaryGreen: primaryGreen,
                secondaryGreen: secondaryGreen,
                lightGreen: lightGreen,
                index: index,
              ),
            );
          },
        ),
      ),
    );
  }
}

class ReportCard extends StatelessWidget {
  final dynamic report;
  final Color primaryGreen;
  final Color secondaryGreen;
  final Color lightGreen;
  final int index;

  const ReportCard({
    super.key,
    required this.report,
    required this.primaryGreen,
    required this.secondaryGreen,
    required this.lightGreen,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
          elevation: 3,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Report header with status indicator
                Container(
                  decoration: BoxDecoration(
                    color: lightGreen,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.article_outlined,
                        color: primaryGreen,
                        size: 24,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          report.title,
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      _buildStatusBadge(report.status),
                    ],
                  ),
                ),

                // Report content
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Description
                      _buildReportDetailWithIcon(
                        Icons.description_outlined,
                        "Description",
                        report.description,
                        primaryGreen,
                      ),
                      const SizedBox(height: 12),

                      // Location
                      _buildReportDetailWithIcon(
                        Icons.location_on_outlined,
                        "Location",
                        report.location,
                        primaryGreen,
                      ),
                      const SizedBox(height: 12),

                      // Added by
                      _buildReportDetailWithIcon(
                        Icons.person_outline,
                        "Added by",
                        report.email,
                        primaryGreen,
                      ),
                    ],
                  ),
                ),

                
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 400.ms, delay: (50 * index).ms)
        .slideY(begin: 0.2, end: 0, duration: 400.ms, delay: (50 * index).ms)
        .shimmer(
          duration: 1000.ms,
          delay: 1000.ms,
          color: Colors.white.withOpacity(0.1),
        );
  }

  Widget _buildStatusBadge(String status) {
    Color badgeColor;
    IconData statusIcon;

    switch (status.toLowerCase()) {
      case 'completed':
        badgeColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'in progress':
        badgeColor = Colors.orange;
        statusIcon = Icons.pending;
        break;
      case 'pending':
        badgeColor = Colors.blue;
        statusIcon = Icons.hourglass_empty;
        break;
      default:
        badgeColor = Colors.grey;
        statusIcon = Icons.info_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeColor.withOpacity(0.5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: 14, color: badgeColor),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportDetailWithIcon(
    IconData icon,
    String label,
    String value,
    Color primaryColor,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: primaryColor),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(color: Colors.grey[800], fontSize: 15),
              ),
            ],
          ),
        ),
      ],
    );
  }
}