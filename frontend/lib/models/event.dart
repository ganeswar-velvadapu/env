class Event {
  final String id;
  final String title;
  final String description;
  final String location;
  final int ngoId;
  final String ngoEmail;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.ngoEmail,
    required this.ngoId,  
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      location: json['location'],
      ngoEmail: json['email'],
      ngoId: json['ngo_id'],
    );
  }
}
