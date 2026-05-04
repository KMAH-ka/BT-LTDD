import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'add_contact_screen.dart';

class ContactsListScreen extends StatefulWidget {
  const ContactsListScreen({super.key});

  @override
  State<ContactsListScreen> createState() => _ContactsListScreenState();
}

class _ContactsListScreenState extends State<ContactsListScreen> {
  List<Map<String, dynamic>> _contacts = [];
  List<Map<String, dynamic>> _filtered = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    setState(() => _isLoading = true);
    final contacts = await DBHelper().getContacts();
    setState(() {
      _contacts = contacts;
      _filtered = contacts;
      _isLoading = false;
    });
  }

  void _onSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _filtered = _contacts);
      return;
    }
    final results = await DBHelper().searchContacts(query.trim());
    setState(() => _filtered = results);
  }

  Future<void> _deleteContact(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xoá danh bạ'),
        content: const Text('Bạn có chắc muốn xoá liên hệ này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Huỷ'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xoá', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await DBHelper().deleteContact(id);
      await _loadContacts();
      if (_searchController.text.isNotEmpty) {
        _onSearch(_searchController.text);
      }
    }
  }

  Future<void> _openAdd() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddContactScreen()),
    );
    if (result == true) await _loadContacts();
  }

  Future<void> _openEdit(Map<String, dynamic> contact) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddContactScreen(existingContact: contact),
      ),
    );
    if (result == true) await _loadContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        title: _isSearching
            ? TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Tìm kiếm theo tên hoặc số...',
            border: InputBorder.none,
          ),
          onChanged: _onSearch,
        )
            : const Text(
          'My Contacts',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _filtered = _contacts;
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_add_outlined),
            onPressed: _openAdd,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filtered.isEmpty
          ? Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_outline,
                size: 64, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(
              _isSearching
                  ? 'Không tìm thấy kết quả'
                  : 'Chưa có danh bạ nào',
              style: TextStyle(color: Colors.grey[500], fontSize: 16),
            ),
          ],
        ),
      )
          : ListView.separated(
        padding: const EdgeInsets.symmetric(
            vertical: 12, horizontal: 16),
        itemCount: _filtered.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final contact = _filtered[index];
          return _ContactCard(
            contact: contact,
            onEdit: () => _openEdit(contact),
            onDelete: () =>
                _deleteContact(contact['id'] as int),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAdd,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class _ContactCard extends StatelessWidget {
  final Map<String, dynamic> contact;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ContactCard({
    required this.contact,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final avatar = contact['avatar'];
    final name = contact['name'] ?? 'Không có tên';
    final phone = contact['phone'] ?? 'Không có số';
    final email = contact['email'];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(
          radius: 26,
          backgroundColor: Colors.indigo[50],
          backgroundImage:
          avatar != null ? MemoryImage(avatar as dynamic) : null,
          child: avatar == null
              ? Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.indigo[400],
            ),
          )
              : null,
        ),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(phone,
                style:
                TextStyle(fontSize: 13, color: Colors.grey[600])),
            if (email != null && email.toString().isNotEmpty)
              Text(email.toString(),
                  style: TextStyle(fontSize: 12, color: Colors.grey[400])),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.grey),
          onSelected: (val) {
            if (val == 'edit') onEdit();
            if (val == 'delete') onDelete();
          },
          itemBuilder: (_) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(children: [
                Icon(Icons.edit_outlined, size: 18),
                SizedBox(width: 8),
                Text('Sửa'),
              ]),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(children: [
                Icon(Icons.delete_outline, size: 18, color: Colors.red),
                SizedBox(width: 8),
                Text('Xoá', style: TextStyle(color: Colors.red)),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}