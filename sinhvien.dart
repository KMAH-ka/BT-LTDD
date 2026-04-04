class SinhVien {
  final int? id;
  final String name;
  String email;

  SinhVien({this.id, required this.name, required this.email});

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'email': email};
  }

  factory SinhVien.fromMap(Map<String, dynamic> map) {
    return SinhVien(
      id: map['id'],
      name: map['name'],
      email: map['email'],
    );
  }
}