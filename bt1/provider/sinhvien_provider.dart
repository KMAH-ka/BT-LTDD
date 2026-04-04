import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../model/sinhvien.dart';

class SinhVienProvider extends ChangeNotifier {
  List<SinhVien> _sinhViens = [];

  List<SinhVien> get sinhViens => _sinhViens;

  Future<void> loadSinhViens() async {
    _sinhViens = await DatabaseHelper().getSinhViens();
    notifyListeners();
  }

  Future<void> addSinhVien(SinhVien sv) async {
    await DatabaseHelper().insertSinhVien(sv);
    await loadSinhViens();
  }

  Future<void> deleteSinhVien(int id) async {
    await DatabaseHelper().deleteSinhVien(id);
    await loadSinhViens();
  }

  Future<void> updateSinhVien(SinhVien sv) async {
    await DatabaseHelper().updateSinhVien(sv);
    await loadSinhViens();
  }
}