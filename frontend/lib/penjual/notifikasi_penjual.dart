// lib/penjual/notifikasi_penjual.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/sidebar_penjual.dart';

const _kPrimary5 = Color(0xFF7A002B);
const _kBg5 = Color(0xFFF5ECEA);

class NotifModel {
  final String id;
  final String judulProduk;
  final int sisaStok;
  final String waktu;
  bool dibaca;

  NotifModel({
    required this.id,
    required this.judulProduk,
    required this.sisaStok,
    required this.waktu,
    this.dibaca = false,
  });
}

class NotifikasiPenjual extends StatefulWidget {
  final String? userName;
  final String? userEmail;
  const NotifikasiPenjual({super.key, this.userName, this.userEmail});

  @override
  State<NotifikasiPenjual> createState() => _NotifikasiPenjualState();
}

class _NotifikasiPenjualState extends State<NotifikasiPenjual> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<NotifModel> _notifs = [
    NotifModel(
      id: '1',
      judulProduk: 'Gamis Aisyah',
      sisaStok: 2,
      waktu: '5 menit lalu',
      dibaca: false,
    ),
    NotifModel(
      id: '2',
      judulProduk: 'Hijab Pashmina Plain',
      sisaStok: 3,
      waktu: '1 jam lalu',
      dibaca: false,
    ),
    NotifModel(
      id: '3',
      judulProduk: 'Bros Mutiara',
      sisaStok: 1,
      waktu: '3 jam lalu',
      dibaca: false,
    ),
    NotifModel(
      id: '4',
      judulProduk: 'Gamis Maryam Hitam',
      sisaStok: 4,
      waktu: 'Kemarin',
      dibaca: true,
    ),
    NotifModel(
      id: '5',
      judulProduk: 'Hijab Voal Pink',
      sisaStok: 2,
      waktu: '2 hari lalu',
      dibaca: true,
    ),
  ];

  void _tandaiSemuaDibaca() {
    setState(() {
      for (final n in _notifs) {
        n.dibaca = true;
      }
    });
  }

  void _onTapNotif(NotifModel n) {
    setState(() => n.dibaca = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${n.judulProduk} (Stok: ${n.sisaStok})'),
        backgroundColor: _kPrimary5,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  int get _belumDibaca => _notifs.where((n) => !n.dibaca).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: _kBg5,
      drawer: SidebarWidget(
        userName: widget.userName ?? 'Ani Rani',
        userEmail: widget.userEmail ?? 'ani@gmail.com',
        selectedIndex: 6,
        onItemSelected: (index) {
          Navigator.pop(context);
        },
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
                    // Tombol menu untuk buka drawer
                    GestureDetector(
                      onTap: () {
                        _scaffoldKey.currentState?.openDrawer();
                      },
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
            child: _notifs.isEmpty
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
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: _notifs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final n = _notifs[i];
                      return GestureDetector(
                        onTap: () => _onTapNotif(n),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: n.dibaca
                                ? Colors.white
                                : const Color(0xFFFDEDED),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: n.dibaca
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Stok Menipis',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${n.judulProduk} tersisa ${n.sisaStok} item',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      n.waktu,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (!n.dibaca)
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
        ],
      ),
    );
  }
}
