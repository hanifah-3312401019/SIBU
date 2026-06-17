// lib/penjual/profil_penjual.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../api/api_base_url.dart';
import '../auth/login_screen.dart';
import '../widgets/sidebar_penjual.dart';

const _kPrimary3 = Color(0xFF803033);
const _kBg3 = Color(0xFFF5ECEA);

class ProfilPenjual extends StatefulWidget {
  final String userName;
  final String userEmail;
  const ProfilPenjual({
    super.key,
    required this.userName,
    required this.userEmail,
  });

  @override
  State<ProfilPenjual> createState() => _ProfilPenjualState();
}

class _ProfilPenjualState extends State<ProfilPenjual> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late String _nama;
  late String _email;
  String _telepon = '';
  String _namaButik = '';
  bool _isSaving = false;
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    _nama     = widget.userName;
    _email    = widget.userEmail;
    _fetchMe();
  }

  Future<void> _fetchMe() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final res = await http.get(
        Uri.parse(ApiBaseUrl.me),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final user = data['data'] ?? data['user'] ?? data;
        if (mounted) {
          setState(() {
            _nama     = ApiBaseUrl.safeString(user['nama'],      defaultValue: _nama);
            _email    = ApiBaseUrl.safeString(user['email'],     defaultValue: _email);
            _telepon  = ApiBaseUrl.safeString(user['no_telepon']);
            _namaButik= ApiBaseUrl.safeString(user['nama_toko']);
          });
        }
      }
    } catch (_) {}
  }

  void _editProfil() {
    final namaCtrl = TextEditingController(text: _nama);
    final telCtrl  = TextEditingController(text: _telepon);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Edit Profil',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: _kPrimary3,
                ),
              ),
              const SizedBox(height: 20),
              _editField('Nama', namaCtrl, Icons.person_outline),
              const SizedBox(height: 12),
              _editField(
                'No. Telepon',
                telCtrl,
                Icons.phone_outlined,
                type: TextInputType.phone,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kPrimary3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _isSaving
                      ? null
                      : () async {
                          setModalState(() {});
                          await _simpanProfil(
                            namaCtrl.text.trim(),
                            telCtrl.text.trim(),
                            ctx,
                          );
                        },
                  child: _isSaving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          'Simpan',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _simpanProfil(
      String nama, String telepon, BuildContext modalCtx) async {
    if (nama.isEmpty || telepon.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama dan telepon tidak boleh kosong'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final res = await http.put(
        Uri.parse('${ApiBaseUrl.me.replaceAll('/me', '')}/me'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'nama': nama, 'no_telepon': telepon}),
      );

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final user = data['data'] ?? {};
        setState(() {
          _nama    = ApiBaseUrl.safeString(user['nama'],       defaultValue: nama);
          _telepon = ApiBaseUrl.safeString(user['no_telepon'], defaultValue: telepon);
        });
        if (mounted) Navigator.pop(modalCtx);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profil berhasil diperbarui',
                style: GoogleFonts.plusJakartaSans()),
            backgroundColor: _kPrimary3,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menyimpan profil'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak dapat terhubung ke server'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Keluar',
          style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w700, color: _kPrimary3),
        ),
        content: Text(
          'Yakin ingin keluar dari akun?',
          style: GoogleFonts.plusJakartaSans(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: GoogleFonts.plusJakartaSans()),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _kPrimary3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: _isLoggingOut ? null : _prosesLogout,
            child: _isLoggingOut
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                : Text(
                    'Keluar',
                    style: GoogleFonts.plusJakartaSans(color: Colors.white),
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _prosesLogout() async {
    setState(() => _isLoggingOut = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      await http.post(
        Uri.parse(ApiBaseUrl.logout),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
    } catch (_) {
    } finally {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('user');

      if (mounted) {
        Navigator.pop(context);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  Widget _editField(
    String label,
    TextEditingController ctrl,
    IconData icon, {
    TextInputType? type,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.plusJakartaSans(),
        prefixIcon: Icon(icon, color: _kPrimary3, size: 20),
        border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _kPrimary3, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: _kBg3,
      drawer: SidebarWidget(
        userName: _nama,
        userEmail: _email,
        selectedIndex: 7,
        onItemSelected: (index) {
          Navigator.pop(context);
        },
      ),
      body: Stack(
        children: [
          Container(color: _kBg3),

          // Header Gradient
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.28,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                  colors: [
                    Color(0xFF803033),
                    Color(0xFFD8A5A8),
                    Color(0xFFF5ECEA),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.menu,
                            color: Colors.white, size: 26),
                        onPressed: () =>
                            _scaffoldKey.currentState?.openDrawer(),
                      ),
                      const Spacer(),
                      Text(
                        'Profil',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 46,
                          backgroundColor: _kPrimary3,
                          child: Text(
                            _nama.isNotEmpty ? _nama[0].toUpperCase() : 'A',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _nama,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: const Color.fromARGB(221, 255, 255, 255),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.store,
                              size: 14, color: Color.fromARGB(255, 255, 255, 255)),
                          const SizedBox(width: 6),
                          Text(
                            _namaButik.isNotEmpty
                                ? 'Admin $_namaButik'
                                : 'Admin',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              color: const Color.fromARGB(255, 255, 255, 255),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        // Info tiles
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 12,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _InfoTile(
                                icon: Icons.email_outlined,
                                label: 'Email',
                                value: _email,
                              ),
                              const Divider(height: 1, indent: 60),
                              _InfoTile(
                                icon: Icons.phone_outlined,
                                label: 'Telepon',
                                value: _telepon.isNotEmpty
                                    ? _telepon
                                    : '-',
                              ),
                              const Divider(height: 1, indent: 60),
                              _InfoTile(
                                icon: Icons.store_outlined,
                                label: 'Nama Butik',
                                value: _namaButik.isNotEmpty
                                    ? _namaButik
                                    : '-',
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: _editProfil,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                  color: _kPrimary3, width: 1.5),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text(
                              'Edit Profil',
                              style: GoogleFonts.plusJakartaSans(
                                color: _kPrimary3,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _logout,
                            icon: const Icon(Icons.logout,
                                color: _kPrimary3, size: 18),
                            label: Text(
                              'Keluar',
                              style: GoogleFonts.plusJakartaSans(
                                color: _kPrimary3,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                  color: _kPrimary3.withOpacity(0.3),
                                  width: 1.5),
                              backgroundColor:
                                  _kPrimary3.withOpacity(0.05),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),
                        Text(
                          'SIBU v1.0.0',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: Colors.grey.shade400,
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _kPrimary3.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: _kPrimary3, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}