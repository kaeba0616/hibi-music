class User {
  final int id;
  final String email;
  final String nickname;
  final String roleType;
  final bool pushEnabled;

  User({
    required this.id,
    required this.email,
    required this.nickname,
    required String roleType,
    this.pushEnabled = true,
  }) : roleType = "USER";

  User.empty()
    : id = 0,
      email = "test@test.com",
      nickname = "HIBI",
      roleType = "USER",
      pushEnabled = true;

  User copywith({int? id, String? email, String? nickname}) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      nickname: nickname ?? this.nickname,
      roleType: roleType,
      pushEnabled: pushEnabled,
    );
  }

  User.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      email = json['email'],
      nickname = json["nickname"],
      roleType = "USER",
      pushEnabled = json['pushEnabled'] ?? true;
  // roleType = json["roleType"];

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "email": email,
      "nickname": nickname,
      "roleType": roleType,
      "pushEnabled": pushEnabled,
    };
  }
}
