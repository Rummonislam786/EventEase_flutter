// To parse this JSON data, do
//
//     final users = usersFromMap(jsonString);

class Users {
  final int? userId;
  final String username;
  final String email;
  final String password;

  Users({
    this.userId,
    required this.username,
    required this.email,
    required this.password,
  });

  factory Users.fromMap(Map<String, dynamic> json) => Users(
        userId: json["UserID"],
        username: json["UserName"],
        email: json["UserEmail"],
        password: json["UserPassword"],
      );

  Map<String, dynamic> toMap() => {
        "UserID": userId,
        "UserName": username,
        "UserEmail": email,
        "UserPassword": password,
      };
}
