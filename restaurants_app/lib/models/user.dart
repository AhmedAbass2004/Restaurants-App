class User {
  final int? id;
  final String name;
  final String email;
  final String? gender;
  final int? level;
  final String? token;

  User({
    this.id,
    required this.name,
    required this.email,
    this.gender,
    this.level,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final dynamic rawId = json['id'] ?? json['user_id'];
    final int? parsedId = rawId is int ? rawId : int.tryParse('$rawId');

    return User(
      id: parsedId,
      name: (json['name'] ?? json['full_name'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      gender: json['gender'] as String?,
      level: json['level'] as int?,
      token: json['token'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'gender': gender,
      'level': level,
      'token': token,
    };
  }
}
