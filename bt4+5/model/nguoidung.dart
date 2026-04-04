class NguoiDung {
  final int? id;
  final String email;
  final String password;

  NguoiDung({
    this.id,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'password': password,
    };
  }

  factory NguoiDung.fromMap(Map<String, dynamic> map) {
    return NguoiDung(
      id: map['id'],
      email: map['email'],
      password: map['password'],
    );
  }
}