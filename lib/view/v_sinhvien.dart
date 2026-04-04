import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/sinhvien.dart';
import '../provider/sinhvien_provider.dart';
import 'v_detail_sinhvien.dart';

class SinhVienListScreen extends StatefulWidget {
  const SinhVienListScreen({super.key});

  @override
  State<SinhVienListScreen> createState() => _SinhVienListScreenState();
}

class _SinhVienListScreenState extends State<SinhVienListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    // Load dữ liệu sau khi widget build xong
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SinhVienProvider>().loadSinhViens();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Hiển thị dialog thêm sinh viên
  void _showAddDialog(BuildContext context, SinhVienProvider provider) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Thêm Sinh Viên'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Tên Sinh Viên'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final email = emailController.text.trim();
              if (name.isNotEmpty && email.isNotEmpty) {
                provider.addSinhVien(SinhVien(name: name, email: email));
                Navigator.pop(ctx);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin')),
                );
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SinhVienProvider>();

    // Lọc danh sách theo từ khóa tìm kiếm
    final filtered = provider.sinhViens
        .where((sv) =>
    sv.name.toLowerCase().contains(_searchText.toLowerCase()) ||
        sv.email.toLowerCase().contains(_searchText.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Tìm kiếm sinh viên...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.black54),
          ),
          onChanged: (value) {
            setState(() {
              _searchText = value;
            });
          },
        ),
        actions: [
          if (_searchText.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                _searchController.clear();
                setState(() => _searchText = '');
              },
            ),
        ],
      ),
      body: filtered.isEmpty
          ? const Center(child: Text('Chưa có thông tin sinh viên'))
          : ListView.builder(
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          final sv = filtered[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.person),
              ),
              title: Text(
                sv.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              subtitle: Text(sv.email),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  provider.deleteSinhVien(sv.id!);
                },
              ),
              onTap: () {
                // Mở màn hình chi tiết / cập nhật
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailSinhVienScreen(sinhVien: sv),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, provider),
        child: const Icon(Icons.add),
      ),
    );
  }
}