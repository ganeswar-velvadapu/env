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
          _reports =
              fetchedReports.map((reportData) {
                return Report.fromMap(reportData);
              }).toList();
        }
      }

      notifyListeners();
    } catch (e) {
      print("Error fetching reports: $e");
    }
  }

  Future<void> addReport(Map<String, dynamic> reportData, String token) async {
    try {
      final response = await ReportApi.addReport(reportData, token);
      print("Report added: ${response.data}");

      await fetchReports();
    } catch (e) {
      print("Error adding report: $e");
    }
  }

  Future<void> fetchUserReports(String token) async {
    try {
      final response = await ReportApi.getUserReports(token);
      final userReports = response.data['user_reports'];
      if (userReports is List) {
        _reports = userReports.map((r) => Report.fromMap(r)).toList();
      }
      notifyListeners();
    } catch (e) {
      print("Error fetching user reports: $e");
    }
  }

  Future<void> deleteReport(int reportId, String token) async {
    try {
      await ReportApi.deleteReport(reportId, token);
      _reports.removeWhere((r) => r.id == reportId);
      notifyListeners();
    } catch (e) {
      print("Error deleting report: $e");
    }
  }

  Future<void> updateReport(
    int id,
    Map<String, dynamic> updatedData,
    String token,
  ) async {
    try {
      await ReportApi.updateReport(id, updatedData, token);
      await fetchUserReports(token);
    } catch (e) {
      print("Error updating report: $e");
    }
  }

  Report getReportById(int reportId) {
    try {
      return _reports.firstWhere((report) => report.id == reportId);
    } catch (e) {
      print("Report with ID $reportId not found.");
      rethrow; // Optionally, you can throw an error if the report is not found
    }
  }
}
