// lib/penjual/notifikasi_penjual.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_base_url.dart';
import '../widgets/sidebar_penjual.dart';
import 'produk_screen.dart';

const _kPrimary5 = Color(0xFF7A002B);
const _kBg5 = Color(0xFFF5ECEA);

class NotifikasiPenjual extends StatefulWidget {
  final String? userName;
  final String? userEmail;
  const NotifikasiPenjual({super.key, this.userName, this.userEmail});

  @override
  State<NotifikasiPenjual> createState() => _NotifikasiPenjualState();
}

class _NotifikasiPenjualState extends State<NotifikasiPenjual> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Map<String, dynamic>> _notifs = [];
  bool _isLoading = true;
  String? _token;

  @override
  void initState() {
    super.initState();
    _loadAndFetch();
  }

  Future<void> _loadAndFetch() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    await _fetchNotifikasi();
  }

  Future<void> _fetchNotifikasi() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final res = await http.get(
        Uri.parse(ApiBaseUrl.notifikasi),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['success'] == true) {
          setState(() {
            _notifs = List<Map<String, dynamic>>.from(data['data']);
            _isLoading = false;
          });
          return;
        }
      }
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  Future<void> _tandaiSemuaDibaca() async {
    try {
      final res = await http.put(
        Uri.parse(ApiBaseUrl.notifikasiBacaSemua),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
      );
      if (res.statusCode == 200) {
        await _fetchNotifikasi();
      }
    } catch (_) {}
  }

  /// Hapus semua notifikasi
  Future<void> _hapusSemuaNotifikasi() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Color(0xFFF5ECEA),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_sweep_outlined,
                  color: _kPrimary5,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Hapus Semua Notifikasi?',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _kPrimary5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Semua riwayat notifikasi akan dihapus permanen.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _kPrimary5,
                        side: const BorderSide(color: Color(0xFFD8A5A8)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'Batal',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kPrimary5,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'Ya, Hapus',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirm != true) return;

    try {
      final res = await http.delete(
        Uri.parse(ApiBaseUrl.notifikasiHapusSemua),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
      );
      if (res.statusCode == 200) {
        setState(() => _notifs = []);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Semua notifikasi telah dihapus',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
              ),
              backgroundColor: _kPrimary5,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      }
    } catch (_) {}
  }

  /// Tap notif → tandai dibaca lalu navigasi ke ProdukScreen
  Future<void> _onTapNotif(Map<String, dynamic> notif, int index) async {
    // Tandai dibaca dulu
    if (notif['sudah_dibaca'] == false ||
        notif['sudah_dibaca'] == 0 ||
        notif['sudah_dibaca'] == '0') {
      try {
        final notifId = notif['notifikasi_id'].toString();
        final res = await http.put(
          Uri.parse(ApiBaseUrl.notifikasiById(notifId)),
          headers: {
            'Authorization': 'Bearer $_token',
            'Content-Type': 'application/json',
          },
        );
        if (res.statusCode == 200) {
          setState(() {
            _notifs[index]['sudah_dibaca'] = true;
          });
        }
      } catch (_) {}
    }

    // Navigasi ke ProdukScreen
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProdukScreen(
          userName: widget.userName ?? 'Admin Butikk',
          userEmail: widget.userEmail ?? 'admin@butik.com',
        ),
      ),
    );
  }

  int get _belumDibaca => _notifs
      .where(
        (n) =>
            n['sudah_dibaca'] == false ||
            n['sudah_dibaca'] == 0 ||
            n['sudah_dibaca'] == '0',
      )
      .length;

  String _formatWaktu(String? rawWaktu) {
    if (rawWaktu == null) return '';
    try {
      final dt = DateTime.parse(rawWaktu).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
      if (diff.inHours < 24) return '${diff.inHours} jam lalu';
      if (diff.inDays == 1) return 'Kemarin';
      return '${diff.inDays} hari lalu';
    } catch (_) {
      return rawWaktu;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: _kBg5,
      drawer: SidebarWidget(
        userName: widget.userName ?? 'Admin Butikk',
        userEmail: widget.userEmail ?? 'admin@butik.com',
        selectedIndex: 6,
        onItemSelected: (_) => Navigator.pop(context),
      ),
      body: Column(
        children: [
          // HEADER
          Container(
            color: Colors.white,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => _scaffoldKey.currentState?.openDrawer(),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: _kPrimary5.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.menu,
                          color: Color(0xFF7A002B),
                          size: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            'Notifikasi',
                            style: GoogleFonts.plusJakartaSans(
                              color: _kPrimary5,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (_belumDibaca > 0) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: _kPrimary5.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '$_belumDibaca baru',
                                style: GoogleFonts.plusJakartaSans(
                                  color: _kPrimary5,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Tombol hapus semua
                    if (_notifs.isNotEmpty)
                      GestureDetector(
                        onTap: _hapusSemuaNotifikasi,
                        child: const Padding(
                          padding: EdgeInsets.only(right: 12),
                          child: Icon(
                            Icons.delete_sweep_outlined,
                            color: Color(0xFF7A002B),
                            size: 22,
                          ),
                        ),
                      ),
                    // Tombol refresh
                    GestureDetector(
                      onTap: _fetchNotifikasi,
                      child: const Icon(
                        Icons.refresh,
                        color: Color(0xFF7A002B),
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          if (_belumDibaca > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
              child: GestureDetector(
                onTap: _tandaiSemuaDibaca,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Tandai Semua Dibaca',
                    style: GoogleFonts.plusJakartaSans(
                      color: _kPrimary5,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF7A002B)),
                  )
                : _notifs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_off_outlined,
                          size: 52,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Tidak ada notifikasi',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _fetchNotifikasi,
                    color: _kPrimary5,
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      itemCount: _notifs.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) {
                        final n = _notifs[i];
                        final dibaca =
                            n['sudah_dibaca'] == true ||
                            n['sudah_dibaca'] == 1 ||
                            n['sudah_dibaca'] == '1';
                        return GestureDetector(
                          onTap: () => _onTapNotif(n, i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: dibaca
                                  ? Colors.white
                                  : const Color(0xFFFDEDED),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: dibaca
                                    ? Colors.transparent
                                    : _kPrimary5.withOpacity(0.1),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.warning_amber_rounded,
                                    color: Colors.red,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        n['judul'] ?? 'Stok Menipis',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        n['pesan'] ?? '',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _formatWaktu(
                                          n['waktu_notifikasi'] ??
                                              n['created_at'],
                                        ),
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11,
                                          color: Colors.grey.shade400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (!dibaca)
                                  Container(
                                    width: 9,
                                    height: 9,
                                    decoration: const BoxDecoration(
                                      color: _kPrimary5,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
