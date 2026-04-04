class ChiTieu {
  final int? id;
  final String noiDung;
  final double soTien;
  final String ghiChu;
  final int nguoiDungId; // liên kết với tài khoản đăng nhập

  ChiTieu({
    this.id,
    required this.noiDung,
    required this.soTien,
    required this.ghiChu,
    required this.nguoiDungId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'noiDung': noiDung,
      'soTien': soTien,
      'ghiChu': ghiChu,
      'nguoiDungId': nguoiDungId,
    };
  }

  factory ChiTieu.fromMap(Map<String, dynamic> map) {
    return ChiTieu(
      id: map['id'],
      noiDung: map['noiDung'],
      soTien: map['soTien'],
      ghiChu: map['ghiChu'],
      nguoiDungId: map['nguoiDungId'],
    );
  }
}