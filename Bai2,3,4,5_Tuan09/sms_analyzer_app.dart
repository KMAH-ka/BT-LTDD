// lib/sms_analyzer_app.dart
// Bài 5: SMS Analyzer - dùng flutter_sms_inbox (tương thích AGP mới)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';

class SmsAnalyzerApp extends StatefulWidget {
  const SmsAnalyzerApp({super.key});

  @override
  State<SmsAnalyzerApp> createState() => _SmsAnalyzerAppState();
}

class _SmsAnalyzerAppState extends State<SmsAnalyzerApp>
    with SingleTickerProviderStateMixin {
  final SmsQuery _query = SmsQuery();

  List<SmsMessage> _allMessages = [];
  bool _isLoading = true;
  late TabController _tabController;

  final _filterPhoneController = TextEditingController();
  String _filterPhone = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initPermissions();
  }

  Future<void> _initPermissions() async {
    final status = await Permission.sms.request();
    if (status.isGranted) {
      await _loadMessages();
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng cấp quyền SMS!'),
            backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _loadMessages() async {
    setState(() => _isLoading = true);
    final messages = await _query.querySms(kinds: [SmsQueryKind.inbox]);
    setState(() {
      _allMessages = messages;
      _isLoading = false;
    });
  }

  List<SmsMessage> get _adMessages => _allMessages
      .where((m) => (m.body ?? '').trimLeft().startsWith('[QC]'))
      .toList();

  List<SmsMessage> get _otpMessages => _allMessages.where((m) {
    final body = m.body ?? '';
    return body.contains('[OTP]') && _extractOtp(body) != null;
  }).toList();

  List<SmsMessage> get _filteredByPhone => _filterPhone.isEmpty
      ? []
      : _allMessages
      .where((m) => (m.sender ?? '').contains(_filterPhone))
      .toList();

  String? _extractOtp(String body) {
    final match = RegExp(r'\b\d{6}\b').firstMatch(body);
    return match?.group(0);
  }

  Map<String, int> get _messagesByDay {
    final map = <String, int>{};
    for (final m in _allMessages) {
      if (m.date == null) continue;
      final dt = m.date!;
      final key =
          '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
      map[key] = (map[key] ?? 0) + 1;
    }
    return Map.fromEntries(
        map.entries.toList()..sort((a, b) => b.key.compareTo(a.key)));
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('SMS Analyzer',
            style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadMessages),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.indigo,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.indigo,
          isScrollable: true,
          tabs: [
            const Tab(icon: Icon(Icons.bar_chart, size: 18), text: 'Thống kê'),
            const Tab(icon: Icon(Icons.filter_list, size: 18), text: 'Theo SĐT'),
            Tab(icon: const Icon(Icons.campaign_outlined, size: 18),
                text: 'QC (${_adMessages.length})'),
            Tab(icon: const Icon(Icons.lock_outline, size: 18),
                text: 'OTP (${_otpMessages.length})'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
        controller: _tabController,
        children: [
          _buildStatsTab(),
          _buildFilterTab(),
          _buildAdTab(),
          _buildOtpTab(),
        ],
      ),
    );
  }

  Widget _buildStatsTab() {
    final byDay = _messagesByDay;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(children: [
          _StatCard(label: 'Tổng', value: '${_allMessages.length}',
              icon: Icons.message_outlined, color: Colors.indigo),
          const SizedBox(width: 12),
          _StatCard(label: 'Quảng cáo', value: '${_adMessages.length}',
              icon: Icons.campaign_outlined, color: Colors.orange),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          _StatCard(label: 'OTP', value: '${_otpMessages.length}',
              icon: Icons.lock_outline, color: Colors.green),
          const SizedBox(width: 12),
          _StatCard(
            label: 'Khác',
            value: '${_allMessages.length - _adMessages.length - _otpMessages.length}',
            icon: Icons.inbox_outlined,
            color: Colors.blueGrey,
          ),
        ]),
        const SizedBox(height: 24),
        const Text('Tin nhắn theo ngày',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        const SizedBox(height: 12),
        if (byDay.isEmpty)
          const Center(child: Text('Không có dữ liệu'))
        else
          ...byDay.entries.map((e) => _DayStatRow(date: e.key, count: e.value)),
      ],
    );
  }

  Widget _buildFilterTab() {
    final results = _filteredByPhone;
    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          Expanded(
            child: TextField(
              controller: _filterPhoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: 'Nhập số điện thoại...',
                prefixIcon: const Icon(Icons.phone_outlined),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (v) => setState(() => _filterPhone = v.trim()),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () =>
                setState(() => _filterPhone = _filterPhoneController.text.trim()),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            child: const Text('Lọc'),
          ),
        ]),
      ),
      if (_filterPhone.isNotEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
                'Tìm thấy ${results.length} tin nhắn từ "$_filterPhone"',
                style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          ),
        ),
      const SizedBox(height: 8),
      Expanded(
        child: _filterPhone.isEmpty
            ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.search, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 8),
          Text('Nhập số để lọc',
              style: TextStyle(color: Colors.grey[400])),
        ]))
            : results.isEmpty
            ? Center(child: Text('Không có tin nhắn từ "$_filterPhone"'))
            : ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: results.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) =>
              _SmsCard(message: results[i], formatDate: _formatDate),
        ),
      ),
    ]);
  }

  Widget _buildAdTab() => _adMessages.isEmpty
      ? const Center(child: Text('Không có tin nhắn quảng cáo'))
      : ListView.separated(
    padding: const EdgeInsets.all(16),
    itemCount: _adMessages.length,
    separatorBuilder: (_, __) => const SizedBox(height: 8),
    itemBuilder: (_, i) => _SmsCard(
      message: _adMessages[i],
      formatDate: _formatDate,
      badge: 'QC',
      badgeColor: Colors.orange,
    ),
  );

  Widget _buildOtpTab() => _otpMessages.isEmpty
      ? const Center(child: Text('Không có tin nhắn OTP'))
      : ListView.separated(
    padding: const EdgeInsets.all(16),
    itemCount: _otpMessages.length,
    separatorBuilder: (_, __) => const SizedBox(height: 8),
    itemBuilder: (_, i) => _OtpCard(
      message: _otpMessages[i],
      otp: _extractOtp(_otpMessages[i].body ?? '') ?? '',
      formatDate: _formatDate,
    ),
  );

  @override
  void dispose() {
    _tabController.dispose();
    _filterPhoneController.dispose();
    super.dispose();
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.label, required this.value,
    required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: color.withOpacity(0.1),
              blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(value, style: TextStyle(fontSize: 22,
                fontWeight: FontWeight.w800, color: color)),
            Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
          ]),
        ]),
      ),
    );
  }
}

class _DayStatRow extends StatelessWidget {
  final String date;
  final int count;
  const _DayStatRow({required this.date, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: Colors.white,
          borderRadius: BorderRadius.circular(10)),
      child: Row(children: [
        const Icon(Icons.calendar_today_outlined, size: 16, color: Colors.indigo),
        const SizedBox(width: 10),
        Text(date, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: Colors.indigo.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20)),
          child: Text('$count tin', style: const TextStyle(fontSize: 13,
              fontWeight: FontWeight.w600, color: Colors.indigo)),
        ),
      ]),
    );
  }
}

class _SmsCard extends StatelessWidget {
  final SmsMessage message;
  final String Function(DateTime?) formatDate;
  final String? badge;
  final Color? badgeColor;
  const _SmsCard({required this.message, required this.formatDate,
    this.badge, this.badgeColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04),
            blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.phone_outlined, size: 14, color: Colors.grey[500]),
          const SizedBox(width: 4),
          Expanded(child: Text(message.sender ?? 'Không rõ',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
          if (badge != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: (badgeColor ?? Colors.grey).withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(badge!, style: TextStyle(fontSize: 11,
                  fontWeight: FontWeight.w700, color: badgeColor ?? Colors.grey)),
            ),
          const SizedBox(width: 4),
          Text(formatDate(message.date),
              style: TextStyle(fontSize: 11, color: Colors.grey[400])),
        ]),
        const SizedBox(height: 8),
        Text(message.body ?? 'Không có nội dung',
            style: TextStyle(fontSize: 13, color: Colors.grey[700])),
      ]),
    );
  }
}

class _OtpCard extends StatefulWidget {
  final SmsMessage message;
  final String otp;
  final String Function(DateTime?) formatDate;
  const _OtpCard({required this.message, required this.otp, required this.formatDate});

  @override
  State<_OtpCard> createState() => _OtpCardState();
}

class _OtpCardState extends State<_OtpCard> {
  bool _revealed = false;

  void _copyOtp() {
    Clipboard.setData(ClipboardData(text: widget.otp));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Đã sao chép: ${widget.otp}'),
      backgroundColor: Colors.green,
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _revealed = !_revealed),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.withOpacity(0.3), width: 1.5),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(Icons.lock_outline, size: 14, color: Colors.green[600]),
            const SizedBox(width: 4),
            Expanded(child: Text(widget.message.sender ?? 'Không rõ',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20)),
              child: const Text('OTP', style: TextStyle(fontSize: 11,
                  fontWeight: FontWeight.w700, color: Colors.green)),
            ),
          ]),
          const SizedBox(height: 8),
          Text(widget.message.body ?? '',
              style: TextStyle(fontSize: 13, color: Colors.grey[700])),
          const SizedBox(height: 10),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _revealed ? Colors.green.withOpacity(0.08) : Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: _revealed
                ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(widget.otp, style: const TextStyle(fontSize: 28,
                  fontWeight: FontWeight.w800, letterSpacing: 8,
                  color: Colors.green)),
              const SizedBox(width: 12),
              IconButton(icon: const Icon(Icons.copy, color: Colors.green, size: 20),
                  onPressed: _copyOtp),
            ])
                : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.touch_app_outlined, size: 16, color: Colors.grey[500]),
              const SizedBox(width: 6),
              Text('Nhấn để xem mã OTP',
                  style: TextStyle(fontSize: 13, color: Colors.grey[500])),
            ]),
          ),
          const SizedBox(height: 6),
          Text(widget.formatDate(widget.message.date),
              style: TextStyle(fontSize: 11, color: Colors.grey[400])),
        ]),
      ),
    );
  }
}