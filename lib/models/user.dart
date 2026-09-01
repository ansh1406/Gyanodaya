class User {
  final String phone;
  final String? displayName;

  User({required this.phone, this.displayName});
  Map<String, dynamic> toJson() => {'phone': phone, 'displayName': displayName};
  factory User.fromJson(Map<String, dynamic> json) => User(
        phone: json['phone'] as String,
        displayName: json['displayName'] as String?,
      );
}

