import 'package:hostations_commerce/features/auth/domain/entities/user.dart';

class UserModel extends User {
  UserModel({
    required String id,
    required String email,
    String? firstName,
    String? lastName,
    String? phone,
    bool acceptsMarketing = false,
    String? accessToken,
  }) : super(
          id: id,
          email: email,
          firstName: firstName,
          lastName: lastName,
          phone: phone,
          acceptsMarketing: acceptsMarketing,
          accessToken: accessToken,
        );

  factory UserModel.fromJson(Map<String, dynamic> json, {String? accessToken}) {
    final customer = json['customer'] ?? json;
    return UserModel(
      id: customer['id'] ?? '',
      email: customer['email'] ?? '',
      firstName: customer['firstName'],
      lastName: customer['lastName'],
      phone: customer['phone'],
      acceptsMarketing: customer['acceptsMarketing'] ?? false,
      accessToken: accessToken,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'acceptsMarketing': acceptsMarketing,
    };
  }

  static UserModel fromJsonDummy() {
    return UserModel(
      id: 'gid://shopify/Customer/12345',
      email: 'test@example.com',
      firstName: 'John',
      lastName: 'Doe',
      phone: '+1234567890',
      acceptsMarketing: false,
      accessToken: 'sample-access-token',
    );
  }

  static UserModel sample() {
    return fromJsonDummy();
  }
}
