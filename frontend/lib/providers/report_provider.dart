import 'package:flutter/material.dart';
import 'package:frontend/api/report_api.dart';
import 'package:frontend/models/report.dart';

class ReportProvider with ChangeNotifier {
  List<Report> _reports = [];

  List<Report> get reports => _reports;

  Future<void> fetchReports() async {
    try {
      final response = await ReportApi.getAllReports();

      if (response.data is Map<String, dynamic>) {
        final fetchedReports = response.data['fetched_all'];

        if (fetchedReports is List) {
          _reports = fetchedReports.map((reportData) {
            return Report.fromMap(reportData);
          }).toList();
        }
      }

      notifyListeners();
    } catch (e) {
      print("Error fetching reports: $e");
    }
  }

  Future<void> addReport(Map<String, dynamic> reportData,String token) async {
    try {
      final response = await ReportApi.addReport(reportData,token);
      print("Report added: ${response.data}");

      await fetchReports();
    } catch (e) {
      print("Error adding report: $e");
    }
  }
}
