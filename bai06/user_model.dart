class User {
  int? id;
  String name;
  String email;
  String phone;
  String? avatarPath; // đường dẫn ảnh lưu trên thiết bị

  User({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.avatarPath,
  });

  // Chuyển User thành Map để lưu vào SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatarPath': avatarPath,
    };
  }

  // Tạo User từ Map lấy từ SQLite
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      avatarPath: map['avatarPath'],
    );
  }
}