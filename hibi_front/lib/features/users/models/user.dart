class User {
  final int id;
  final String email;
  final String nickname;
  final String roleType;

  User({
    required this.id,
    required this.email,
    required this.nickname,
    required String roleType,
  }) : roleType = "USER";

  User.empty()
    : id = 0,
      email = "test@test.com",
      nickname = "HIBI",
      roleType = "USER";

  User copywith({int? id, String? email, String? nickname}) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      nickname: nickname ?? this.nickname,
      roleType: roleType,
    );
  }

  User.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      email = json['email'],
      nickname = json["nickname"],
      roleType = "USER";
  // roleType = json["roleType"];

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "email": email,
      "nickname": nickname,
      "roleType": roleType,
    };
  }
}
