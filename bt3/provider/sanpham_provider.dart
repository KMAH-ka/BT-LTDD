import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../model/sanpham.dart';

class SanPhamProvider extends ChangeNotifier {
  List<SanPham> _sanPhams = [];

  List<SanPham> get sanPhams => _sanPhams;

  Future<void> loadSanPhams() async {
    _sanPhams = await DatabaseHelper().getSanPhams();
    notifyListeners();
  }

  Future<void> addSanPham(SanPham sp) async {
    await DatabaseHelper().insertSanPham(sp);
    await loadSanPhams();
  }

  Future<void> deleteSanPham(int id) async {
    await DatabaseHelper().deleteSanPham(id);
    await loadSanPhams();
  }

  Future<void> updateSanPham(SanPham sp) async {
    await DatabaseHelper().updateSanPham(sp);
    await loadSanPhams();
  }
}