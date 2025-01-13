class User {
  final int id;
  final String username;
  final String email;
  final String? accessToken; // Thêm accessToken

  User(
      {required this.id,
      required this.username,
      required this.email,
      this.accessToken});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        id: json['id'],
        username: json['username'],
        email: json['email'],
        accessToken: json['accessToken']);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'accessToken': accessToken
    };
  }
}
