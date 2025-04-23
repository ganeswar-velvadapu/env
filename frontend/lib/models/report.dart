class Report {
  final int id;
  final String title;
  final String description;
  final String location;
  final String status;
  final int userId;
  final String email;

  Report({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.status,
    required this.userId,
    required this.email,
  });

  factory Report.fromMap(Map<String, dynamic> map) {
    return Report(
      id: map['id'],
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      location: map['location'] ?? '',
      status: map['status'] ?? '',
      userId: map['user_id'],
      email: map['email'] ?? '',
    );
  }
}
