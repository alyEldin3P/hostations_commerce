class User {
  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final bool acceptsMarketing;
  final String? accessToken;

  User({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.phone,
    this.acceptsMarketing = false,
    this.accessToken,
  });

  User copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? phone,
    bool? acceptsMarketing,
    String? accessToken,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      acceptsMarketing: acceptsMarketing ?? this.acceptsMarketing,
      accessToken: accessToken ?? this.accessToken,
    );
  }
}
