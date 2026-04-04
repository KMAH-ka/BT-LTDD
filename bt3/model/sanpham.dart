class SanPham {
  final int? id;
  final String ma;
  final String ten;
  final double gia;
  final double giamGia;

  SanPham({
    this.id,
    required this.ma,
    required this.ten,
    required this.gia,
    required this.giamGia,
  });

  // Phương thức 1: Tính thuế nhập khẩu (10% giá sản phẩm)
  double tinhThueNhapKhau() => gia * 0.1;

  // Phương thức 2: Xuất thông tin ra màn hình
  String xuatThongTin() {
    return 'Mã: $ma | Tên: $ten | Giá: ${gia.toStringAsFixed(0)} VNĐ | Giảm: ${giamGia.toStringAsFixed(0)} VNĐ | Thuế NK: ${tinhThueNhapKhau().toStringAsFixed(0)} VNĐ';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ma': ma,
      'ten': ten,
      'gia': gia,
      'giamGia': giamGia,
    };
  }

  factory SanPham.fromMap(Map<String, dynamic> map) {
    return SanPham(
      id: map['id'],
      ma: map['ma'],
      ten: map['ten'],
      gia: map['gia'],
      giamGia: map['giamGia'],
    );
  }
}