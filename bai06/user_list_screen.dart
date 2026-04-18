import 'dart:io';
import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'user_model.dart';
import 'user_detail_screen.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<User> _users = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  // Tải danh sách từ CSDL
  Future<void> _loadUsers() async {
    final users = await _dbHelper.getAllUsers();
    setState(() {
      _users = users;
    });
  }

  // Xóa user với xác nhận
  Future<void> _deleteUser(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc muốn xóa người dùng này?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Hủy')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Xóa', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      await _dbHelper.deleteUser(id);
      _loadUsers();
    }
  }

  // Mở màn hình thêm user mới
  Future<void> _addUser() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserDetailScreen(user: null),
      ),
    );
    if (result == true) _loadUsers();
  }

  // Mở màn hình chi tiết / chỉnh sửa
  Future<void> _openDetail(User user) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserDetailScreen(user: user),
      ),
    );
    if (result == true) _loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý người dùng'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: _users.isEmpty
          ? const Center(
          child: Text('Chưa có người dùng nào.',
              style: TextStyle(fontSize: 16, color: Colors.grey)))
          : ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: _users.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final user = _users[index];
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              // Avatar nhỏ
              leading: CircleAvatar(
                radius: 28,
                backgroundColor: Colors.indigo.shade100,
                backgroundImage: (user.avatarPath != null &&
                    File(user.avatarPath!).existsSync())
                    ? FileImage(File(user.avatarPath!))
                    : null,
                child: (user.avatarPath == null ||
                    !File(user.avatarPath!).existsSync())
                    ? Text(
                  user.name.isNotEmpty
                      ? user.name[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo),
                )
                    : null,
              ),
              // Mã người dùng và tên
              title: Text(
                user.name,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Text(
                'ID: ${user.id}  |  ${user.phone}',
                style: const TextStyle(color: Colors.grey),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => _deleteUser(user.id!),
              ),
              onTap: () => _openDetail(user),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addUser,
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }
}