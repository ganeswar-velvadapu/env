class User {
  final String id;
  final String email;
  final String token;
  final UserType userType;

  User({required this.id, required this.email, required this.token, required this.userType});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      email: json['email'],
      token: json['token'],
      userType: _parseUserType(json['user_type']),
    );
  }

  static UserType _parseUserType(String userTypeString) {
    switch (userTypeString.toLowerCase()) {
      case 'ngo':
        return UserType.ngo;
      case 'normal':
        return UserType.normal;
      default:
        throw Exception('Unknown user type: $userTypeString');
    }
  }

}

enum UserType {
  normal,
  ngo,
}
