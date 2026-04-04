import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../model/nguoidung.dart';
import '../model/chitieu.dart';

// ===================== AUTH PROVIDER =====================
class AuthProvider extends ChangeNotifier {
  NguoiDung? _currentUser;

  NguoiDung? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  Future<String> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      return 'Vui lòng nhập email và mật khẩu';
    }
    final user = await DatabaseHelper().loginNguoiDung(email, password);
    if (user == null) {
      return 'Email hoặc mật khẩu không đúng';
    }
    _currentUser = user;
    notifyListeners();
    return 'success';
  }

  Future<String> register(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      return 'Vui lòng nhập đầy đủ thông tin';
    }
    if (password.length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    }
    final result = await DatabaseHelper()
        .registerNguoiDung(NguoiDung(email: email, password: password));
    if (result == -1) {
      return 'Email đã được sử dụng';
    }
    return 'success';
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}

// ===================== CHI TIEU PROVIDER =====================
class ChiTieuProvider extends ChangeNotifier {
  List<ChiTieu> _chiTieus = [];

  List<ChiTieu> get chiTieus => _chiTieus;

  double get tongChiTieu =>
      _chiTieus.fold(0, (sum, ct) => sum + ct.soTien);

  Future<void> loadChiTieus(int nguoiDungId) async {
    _chiTieus = await DatabaseHelper().getChiTieus(nguoiDungId);
    notifyListeners();
  }

  Future<void> addChiTieu(ChiTieu ct) async {
    await DatabaseHelper().insertChiTieu(ct);
    await loadChiTieus(ct.nguoiDungId);
  }

  Future<void> deleteChiTieu(int id, int nguoiDungId) async {
    await DatabaseHelper().deleteChiTieu(id);
    await loadChiTieus(nguoiDungId);
  }

  Future<void> updateChiTieu(ChiTieu ct) async {
    await DatabaseHelper().updateChiTieu(ct);
    await loadChiTieus(ct.nguoiDungId);
  }

  void clear() {
    _chiTieus = [];
    notifyListeners();
  }
}