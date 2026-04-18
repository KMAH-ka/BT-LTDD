import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'database_helper.dart';
import 'user_model.dart';

class UserDetailScreen extends StatefulWidget {
  final User? user; // null = thêm mới, có giá trị = chỉnh sửa

  const UserDetailScreen({super.key, required this.user});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  final DatabaseHelper _dbHelper = DatabaseHelper();
  final ImagePicker _picker = ImagePicker();

  File? _avatarFile;
  bool get _isEditing => widget.user != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      // Điền thông tin hiện có vào form
      _nameController.text = widget.user!.name;
      _emailController.text = widget.user!.email;
      _phoneController.text = widget.user!.phone;
      if (widget.user!.avatarPath != null &&
          File(widget.user!.avatarPath!).existsSync()) {
        _avatarFile = File(widget.user!.avatarPath!);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // Yêu cầu quyền
  Future<void> _requestPermission(Permission permission) async {
    if (await permission.isDenied) {
      await permission.request();
    }
  }

  // Chọn ảnh từ gallery hoặc camera
  Future<void> _pickAvatar(ImageSource source) async {
    if (source == ImageSource.camera) {
      await _requestPermission(Permission.camera);
    } else {
      await _requestPermission(Permission.photos);
    }

    final XFile? picked = await _picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 512,
      maxHeight: 512,
    );

    if (picked != null) {
      setState(() {
        _avatarFile = File(picked.path);
      });
    }
  }

  // Hiển thị bottom sheet chọn nguồn ảnh
  void _showAvatarPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Chọn ảnh đại diện',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.indigo),
              title: const Text('Chọn từ Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickAvatar(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.indigo),
              title: const Text('Chụp ảnh từ Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickAvatar(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Lưu thông tin user
  Future<void> _saveUser() async {
    if (!_formKey.currentState!.validate()) return;

    final user = User(
      id: widget.user?.id,
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      avatarPath: _avatarFile?.path ?? widget.user?.avatarPath,
    );

    if (_isEditing) {
      await _dbHelper.updateUser(user);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật thành công!')));
    } else {
      await _dbHelper.insertUser(user);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Thêm người dùng thành công!')));
    }

    Navigator.pop(context, true); // trả về true để list reload
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Chi tiết người dùng' : 'Thêm người dùng'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveUser,
            tooltip: 'Lưu',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Avatar lớn
              GestureDetector(
                onTap: _showAvatarPicker,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 64,
                      backgroundColor: Colors.indigo.shade100,
                      backgroundImage: _avatarFile != null
                          ? FileImage(_avatarFile!)
                          : null,
                      child: _avatarFile == null
                          ? const Icon(Icons.person,
                          size: 64, color: Colors.indigo)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.indigo,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(6),
                        child: const Icon(Icons.camera_alt,
                            size: 18, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text('Nhấn để đổi ảnh',
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 24),

              // ID (chỉ hiển thị khi edit)
              if (_isEditing)
                _buildInfoRow('Mã người dùng', 'ID: ${widget.user!.id}'),

              // Tên
              _buildTextField(
                controller: _nameController,
                label: 'Họ và tên',
                icon: Icons.person_outline,
                validator: (v) =>
                (v == null || v.isEmpty) ? 'Vui lòng nhập tên' : null,
              ),
              const SizedBox(height: 16),

              // Email
              _buildTextField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Vui lòng nhập email';
                  if (!v.contains('@')) return 'Email không hợp lệ';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Số điện thoại
              _buildTextField(
                controller: _phoneController,
                label: 'Số điện thoại',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (v) =>
                (v == null || v.isEmpty) ? 'Vui lòng nhập số điện thoại' : null,
              ),
              const SizedBox(height: 32),

              // Nút lưu
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saveUser,
                  icon: const Icon(Icons.save),
                  label: Text(_isEditing ? 'Lưu thay đổi' : 'Thêm người dùng'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.indigo),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.indigo, width: 2),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.indigo.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.indigo.shade100),
        ),
        child: Text(value,
            style: const TextStyle(
                fontSize: 15,
                color: Colors.indigo,
                fontWeight: FontWeight.w600)),
      ),
    );
  }
}