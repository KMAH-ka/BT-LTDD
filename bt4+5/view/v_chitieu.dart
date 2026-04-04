import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/chitieu.dart';
import '../provider/providers.dart';
import 'v_auth.dart';

class ChiTieuScreen extends StatefulWidget {
  const ChiTieuScreen({super.key});

  @override
  State<ChiTieuScreen> createState() => _ChiTieuScreenState();
}

class _ChiTieuScreenState extends State<ChiTieuScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().currentUser;
      if (user != null) {
        context.read<ChiTieuProvider>().loadChiTieus(user.id!);
      }
    });
  }

  void _showAddDialog() {
    final noiDungCtrl = TextEditingController();
    final soTienCtrl = TextEditingController();
    final ghiChuCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Thêm Chi Tiêu'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: noiDungCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nội dung chi tiêu',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: soTienCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Số tiền (VNĐ)',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ghiChuCtrl,
                decoration: const InputDecoration(
                  labelText: 'Ghi chú',
                  prefixIcon: Icon(Icons.note),
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              final noiDung = noiDungCtrl.text.trim();
              final soTien =
                  double.tryParse(soTienCtrl.text.trim()) ?? 0;
              final ghiChu = ghiChuCtrl.text.trim();
              final user = context.read<AuthProvider>().currentUser;

              if (noiDung.isEmpty || soTien <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content:
                      Text('Vui lòng nhập nội dung và số tiền hợp lệ')),
                );
                return;
              }

              context.read<ChiTieuProvider>().addChiTieu(ChiTieu(
                noiDung: noiDung,
                soTien: soTien,
                ghiChu: ghiChu,
                nguoiDungId: user!.id!,
              ));
              Navigator.pop(ctx);
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(ChiTieu ct) {
    final noiDungCtrl = TextEditingController(text: ct.noiDung);
    final soTienCtrl =
    TextEditingController(text: ct.soTien.toStringAsFixed(0));
    final ghiChuCtrl = TextEditingController(text: ct.ghiChu);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cập nhật Chi Tiêu'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: noiDungCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nội dung chi tiêu',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: soTienCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Số tiền (VNĐ)',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ghiChuCtrl,
                decoration: const InputDecoration(
                  labelText: 'Ghi chú',
                  prefixIcon: Icon(Icons.note),
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              final updated = ChiTieu(
                id: ct.id,
                noiDung: noiDungCtrl.text.trim(),
                soTien:
                double.tryParse(soTienCtrl.text.trim()) ?? ct.soTien,
                ghiChu: ghiChuCtrl.text.trim(),
                nguoiDungId: ct.nguoiDungId,
              );
              context.read<ChiTieuProvider>().updateChiTieu(updated);
              Navigator.pop(ctx);
            },
            child: const Text('Cập nhật'),
          ),
        ],
      ),
    );
  }

  void _logout() {
    context.read<AuthProvider>().logout();
    context.read<ChiTieuProvider>().clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AuthScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final chiTieuProvider = context.watch<ChiTieuProvider>();
    final list = chiTieuProvider.chiTieus;
    final tong = chiTieuProvider.tongChiTieu;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi Tiêu Cá Nhân'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Đăng xuất',
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        children: [
          // Thẻ tổng chi tiêu
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.blue, Colors.blueAccent],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Xin chào, ${auth.currentUser?.email ?? ''}',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 4),
                const Text('Tổng chi tiêu',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 4),
                Text(
                  '${tong.toStringAsFixed(0)} VNĐ',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // Danh sách chi tiêu
          Expanded(
            child: list.isEmpty
                ? const Center(child: Text('Chưa có khoản chi tiêu nào'))
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final ct = list[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade50,
                      child: const Icon(Icons.receipt_long,
                          color: Colors.blue),
                    ),
                    title: Text(
                      ct.noiDung,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${ct.soTien.toStringAsFixed(0)} VNĐ',
                          style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w600),
                        ),
                        if (ct.ghiChu.isNotEmpty)
                          Text(ct.ghiChu,
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                    isThreeLine: ct.ghiChu.isNotEmpty,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit,
                              color: Colors.orange),
                          onPressed: () => _showEditDialog(ct),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete,
                              color: Colors.red),
                          onPressed: () =>
                              chiTieuProvider.deleteChiTieu(
                                  ct.id!, ct.nguoiDungId),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}