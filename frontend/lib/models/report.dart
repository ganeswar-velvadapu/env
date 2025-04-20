class Report {
  final String title;
  final String description;
  final String status;
  final String location;
  final String userId;

  Report({
    required this.title,
    required this.description,
    required this.status,
    required this.location,
    required this.userId,
  });

  // Convert from JSON (from API to Dart object)
  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      title: json['title'],
      description: json['description'],
      status: json['status'],
      location: json['location'],
      userId: json['user_id'].toString(), 
    );
  }

  // Convert to JSON (from Dart object to send to API)
  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "description": description,
      "status": status,
      "location": location,
      "user_id": userId,
    };
  }
}
