import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/sanpham.dart';
import '../provider/sanpham_provider.dart';

// ===================== MÀN HÌNH DANH SÁCH =====================
class SanPhamListScreen extends StatefulWidget {
  const SanPhamListScreen({super.key});

  @override
  State<SanPhamListScreen> createState() => _SanPhamListScreenState();
}

class _SanPhamListScreenState extends State<SanPhamListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SanPhamProvider>().loadSanPhams();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SanPhamProvider>();
    final list = provider.sanPhams;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Sản Phẩm'),
      ),
      body: list.isEmpty
          ? const Center(child: Text('Chưa có sản phẩm nào'))
          : ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final sp = list[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue.shade100,
                child: Text(
                  sp.ma.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.blue),
                ),
              ),
              title: Text(
                sp.ten,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Mã: ${sp.ma}'),
                  Text(
                      'Giá: ${sp.gia.toStringAsFixed(0)} VNĐ  |  Giảm: ${sp.giamGia.toStringAsFixed(0)} VNĐ'),
                  Text(
                    'Thuế NK: ${sp.tinhThueNhapKhau().toStringAsFixed(0)} VNĐ',
                    style: const TextStyle(color: Colors.orange),
                  ),
                ],
              ),
              isThreeLine: true,
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => provider.deleteSanPham(sp.id!),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailSanPhamScreen(sanPham: sp),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddSanPhamScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ===================== MÀN HÌNH THÊM SẢN PHẨM =====================
class AddSanPhamScreen extends StatefulWidget {
  const AddSanPhamScreen({super.key});

  @override
  State<AddSanPhamScreen> createState() => _AddSanPhamScreenState();
}

class _AddSanPhamScreenState extends State<AddSanPhamScreen> {
  final _maCtrl = TextEditingController();
  final _tenCtrl = TextEditingController();
  final _giaCtrl = TextEditingController();
  final _giamGiaCtrl = TextEditingController();

  @override
  void dispose() {
    _maCtrl.dispose();
    _tenCtrl.dispose();
    _giaCtrl.dispose();
    _giamGiaCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final ma = _maCtrl.text.trim();
    final ten = _tenCtrl.text.trim();
    final gia = double.tryParse(_giaCtrl.text.trim()) ?? 0;
    final giamGia = double.tryParse(_giamGiaCtrl.text.trim()) ?? 0;

    if (ma.isEmpty || ten.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập Mã và Tên sản phẩm')),
      );
      return;
    }

    context
        .read<SanPhamProvider>()
        .addSanPham(SanPham(ma: ma, ten: ten, gia: gia, giamGia: giamGia));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm Sản Phẩm'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _save,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildField(_maCtrl, 'Mã sản phẩm', Icons.qr_code),
            const SizedBox(height: 12),
            _buildField(_tenCtrl, 'Tên sản phẩm', Icons.inventory),
            const SizedBox(height: 12),
            _buildField(_giaCtrl, 'Đơn giá (VNĐ)', Icons.attach_money,
                isNumber: true),
            const SizedBox(height: 12),
            _buildField(_giamGiaCtrl, 'Giảm giá (VNĐ)', Icons.discount,
                isNumber: true),
            const SizedBox(height: 24),
            // Preview thuế realtime
            ValueListenableBuilder(
              valueListenable: _giaCtrl,
              builder: (context, _, __) {
                final gia = double.tryParse(_giaCtrl.text) ?? 0;
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Text(
                    'Thuế nhập khẩu (10%): ${(gia * 0.1).toStringAsFixed(0)} VNĐ',
                    style: const TextStyle(
                        color: Colors.orange, fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String label, IconData icon,
      {bool isNumber = false}) {
    return TextField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
    );
  }
}

// ===================== MÀN HÌNH CHI TIẾT / CẬP NHẬT =====================
class DetailSanPhamScreen extends StatefulWidget {
  final SanPham sanPham;

  const DetailSanPhamScreen({super.key, required this.sanPham});

  @override
  State<DetailSanPhamScreen> createState() => _DetailSanPhamScreenState();
}

class _DetailSanPhamScreenState extends State<DetailSanPhamScreen> {
  late TextEditingController _maCtrl;
  late TextEditingController _tenCtrl;
  late TextEditingController _giaCtrl;
  late TextEditingController _giamGiaCtrl;

  @override
  void initState() {
    super.initState();
    _maCtrl = TextEditingController(text: widget.sanPham.ma);
    _tenCtrl = TextEditingController(text: widget.sanPham.ten);
    _giaCtrl =
        TextEditingController(text: widget.sanPham.gia.toStringAsFixed(0));
    _giamGiaCtrl = TextEditingController(
        text: widget.sanPham.giamGia.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _maCtrl.dispose();
    _tenCtrl.dispose();
    _giaCtrl.dispose();
    _giamGiaCtrl.dispose();
    super.dispose();
  }

  void _capNhat() {
    final ma = _maCtrl.text.trim();
    final ten = _tenCtrl.text.trim();
    final gia = double.tryParse(_giaCtrl.text.trim()) ?? 0;
    final giamGia = double.tryParse(_giamGiaCtrl.text.trim()) ?? 0;

    if (ma.isEmpty || ten.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin')),
      );
      return;
    }

    context.read<SanPhamProvider>().updateSanPham(
      SanPham(
          id: widget.sanPham.id, ma: ma, ten: ten, gia: gia, giamGia: giamGia),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cập nhật thành công!')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final sp = widget.sanPham;

    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết Sản Phẩm')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bảng thông tin (xuatThongTin)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Thông tin sản phẩm',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const Divider(),
                  _infoRow('Mã sản phẩm', sp.ma),
                  _infoRow('Tên sản phẩm', sp.ten),
                  _infoRow('Đơn giá', '${sp.gia.toStringAsFixed(0)} VNĐ'),
                  _infoRow('Giảm giá',
                      '${sp.giamGia.toStringAsFixed(0)} VNĐ'),
                  _infoRow(
                    'Thuế nhập khẩu',
                    '${sp.tinhThueNhapKhau().toStringAsFixed(0)} VNĐ',
                    valueColor: Colors.orange,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('Cập nhật thông tin',
                style:
                TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 12),
            _buildField(_maCtrl, 'Mã sản phẩm', Icons.qr_code),
            const SizedBox(height: 12),
            _buildField(_tenCtrl, 'Tên sản phẩm', Icons.inventory),
            const SizedBox(height: 12),
            _buildField(_giaCtrl, 'Đơn giá (VNĐ)', Icons.attach_money,
                isNumber: true),
            const SizedBox(height: 12),
            _buildField(_giamGiaCtrl, 'Giảm giá (VNĐ)', Icons.discount,
                isNumber: true),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _capNhat,
                  child: const Text('Cập nhật'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(label,
                style:
                const TextStyle(color: Colors.grey, fontSize: 13)),
          ),
          Expanded(
            child: Text(value,
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: valueColor ?? Colors.black87)),
          ),
        ],
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String label, IconData icon,
      {bool isNumber = false}) {
    return TextField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
    );
  }
}