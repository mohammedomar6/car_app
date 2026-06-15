class RegisterRequestModel {
  final String fullName;
  final String email;
  final String password;
  final String role;
  final String phone;
  final String address;

  RegisterRequestModel({
    required this.fullName,
    required this.email,
    required this.password,
    required this.role,
    required this.phone,
    required this.address,
  });

  Map<String, dynamic> toJson() {
    return {
      "fullName": fullName,
      "email": email,
      "password": password,
      "role": role,
      "phone": phone,
      "address": address,
    };
  }

  factory RegisterRequestModel.fromJson(Map<String, dynamic> map) {
    return RegisterRequestModel(
      fullName: map["fullName"],
      email: map["email"],
      password: map["password"],
      role: map["role"],
      phone: map["phone"],
      address: map["address"],
    );
  }
}
