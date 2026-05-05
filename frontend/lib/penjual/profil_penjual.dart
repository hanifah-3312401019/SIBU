// lib/penjual/profil_penjual.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  String _telepon = '+62 812 - 3456 - 7890';
  String _namaButik = 'Butik Syar\'i Ani';

  @override
  void initState() {
    super.initState();
    _nama = widget.userName;
    _email = widget.userEmail;
  }

  void _editProfil() {
    final namaCtrl = TextEditingController(text: _nama);
    final emailCtrl = TextEditingController(text: _email);
    final telCtrl = TextEditingController(text: _telepon);
    final butikCtrl = TextEditingController(text: _namaButik);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
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
              'Email',
              emailCtrl,
              Icons.email_outlined,
              type: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            _editField(
              'Telepon',
              telCtrl,
              Icons.phone_outlined,
              type: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            _editField('Nama Butik', butikCtrl, Icons.store_outlined),
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
                onPressed: () {
                  setState(() {
                    _nama = namaCtrl.text;
                    _email = emailCtrl.text;
                    _telepon = telCtrl.text;
                    _namaButik = butikCtrl.text;
                  });
                  Navigator.pop(context);
                },
                child: Text(
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
    );
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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _kPrimary3, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Keluar',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            color: _kPrimary3,
          ),
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
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Berhasil keluar',
                    style: GoogleFonts.plusJakartaSans(),
                  ),
                  backgroundColor: _kPrimary3,
                ),
              );
              Navigator.pop(context);
            },
            child: Text(
              'Keluar',
              style: GoogleFonts.plusJakartaSans(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: _kBg3,
      drawer: SidebarWidget(
        userName: widget.userName,
        userEmail: widget.userEmail,
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
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                  colors: const [
                    Color(0xFF803033),
                    Color(0xFFD8A5A8),
                    Color(0xFFF5ECEA),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () =>
                            _scaffoldKey.currentState?.openDrawer(),
                        icon: const Icon(
                          Icons.menu,
                          color: Colors.white,
                          size: 24,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),

                // Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Profil',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Data dari akun anda',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Transform.translate(
                  offset: const Offset(0, -20),
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
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.store, size: 14, color: Colors.grey),
                          const SizedBox(width: 6),
                          Text(
                            'Admin $_namaButik',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
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
                                value: _telepon,
                              ),
                              const Divider(height: 1, indent: 60),
                              _InfoTile(
                                icon: Icons.store_outlined,
                                label: 'Nama Butik',
                                value: _namaButik,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Tombol Edit Profil
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: _editProfil,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: _kPrimary3,
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
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

                        // Tombol Keluar
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _logout,
                            icon: const Icon(
                              Icons.logout,
                              color: _kPrimary3,
                              size: 18,
                            ),
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
                                width: 1.5,
                              ),
                              backgroundColor: _kPrimary3.withOpacity(0.05),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
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
