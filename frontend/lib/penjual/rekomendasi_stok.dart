// lib/penjual/rekomendasi_stok.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/sidebar_penjual.dart';
import 'manajemen_periode_screen.dart'; 

const _kPrimary6 = Color(0xFF803033);
const _kBg6 = Color(0xFFF5ECEA);
const _kGold = Color(0xFFFF8C00);

class RekomendasiStok extends StatefulWidget {
  final String? highlightProduk;
  final String? userName;
  final String? userEmail;
  const RekomendasiStok({
    super.key,
    this.highlightProduk,
    this.userName,
    this.userEmail,
  });

  @override
  State<RekomendasiStok> createState() => _RekomendasiStokState();
}

class _RekomendasiStokState extends State<RekomendasiStok> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _periodeIdx = 1;
  final List<String> _periodeLabel = [
    'Harian\n(7 hari)',
    'Mingguan\n(21 hari)',
    'Bulanan\n(30 hari)',
  ];

  final List<Map<String, dynamic>> _items = [
    {
      'id': '1',
      'nama': 'Baju Kurung Melayu',
      'badge': 'Ramadhan',
      'stok': 2,
      'rataHari': 2.4,
      'saranTambah': 58,
      'status': 'perlu_restock',
    },
    {
      'id': '2',
      'nama': 'Abaya Cokelat Elegan',
      'badge': 'Ramadhan',
      'stok': 3,
      'rataHari': 3.1,
      'saranTambah': 78,
      'status': 'sudah_dipesan',
    },
    {
      'id': '3',
      'nama': 'Gamis Ceruty Payet',
      'badge': 'Ramadhan',
      'stok': 15,
      'rataHari': 1.2,
      'saranTambah': 25,
      'status': 'telah_tiba',
    },
  ];

  void _navigateToManajemenPeriode() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ManajemenPeriodeScreen(
          userName: widget.userName ?? 'Ani Rani',
          userEmail: widget.userEmail ?? 'ani@gmail.com',
        ),
      ),
    );
  }

  void _showRestockSheet(Map<String, dynamic> item) {
    int jumlah = item['saranTambah'] as int;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _kPrimary6.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.checkroom,
                      color: _kPrimary6,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['nama'] as String,
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Stok saat ini: ${item['stok']} pcs',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _BadgeChip(label: item['badge'] as String),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Jumlah Tambah Stok',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _RestockQtyBtn(
                    icon: Icons.remove,
                    onTap: () {
                      if (jumlah > 1) setSheet(() => jumlah--);
                    },
                  ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: _kBg6,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$jumlah pcs',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  _RestockQtyBtn(
                    icon: Icons.add,
                    onTap: () => setSheet(() => jumlah++),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '✓ Disarankan +${item['saranTambah']} berdasarkan: rata² penjualan: '
                '${item['rataHari']} pcs/hari, periode aktif: ramadhan (+20%), '
                'hari cover: ${_periodeIdx == 0
                    ? 7
                    : _periodeIdx == 1
                    ? 21
                    : 30} hari',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  color: Colors.grey.shade500,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _kBg6,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Stok setelah restock:',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          '${item['stok']} + $jumlah = ${(item['stok'] as int) + jumlah} pcs',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.inventory_2_outlined,
                          color: _kPrimary6,
                          size: 16,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        'Batal',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kPrimary6,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        setState(() {
                          item['status'] = 'sudah_dipesan';
                        });
                        _snack('Restock ${item['nama']} berhasil dicatat');
                      },
                      child: Text(
                        'Tambah Stok',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.info_outline, size: 13, color: _kGold),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Stok akan bertambah setelah barang tiba dan Anda konfirmasi di tombol "Sudah dipesan" nanti.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                        height: 1.4,
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
  }

  void _showKonfirmasiTibaSheet(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _kPrimary6.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.checkroom,
                    color: _kPrimary6,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['nama'] as String,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'Stok saat ini: ${item['stok']} pcs',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                _BadgeChip(label: item['badge'] as String),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Konfirmasi Restock',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 40),
            const Center(
              child: Icon(
                Icons.inventory_2_outlined,
                size: 52,
                color: _kPrimary6,
              ),
            ),
            const SizedBox(height: 40),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      'Batal',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kPrimary6,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {
                        item['stok'] =
                            (item['stok'] as int) +
                            (item['saranTambah'] as int);
                        item['status'] = 'telah_tiba';
                      });
                      _snack('Stok ${item['nama']} telah diperbarui!');
                    },
                    child: Text(
                      'Konfirmasi Tiba',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.info_outline, size: 13, color: _kGold),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Konfirmasi ini akan langsung menambah stok produk.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: _kPrimary6,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: _kBg6,
      drawer: SidebarWidget(
        userName: widget.userName ?? 'Ani Rani',
        userEmail: widget.userEmail ?? 'ani@gmail.com',
        selectedIndex: 5,
        onItemSelected: (index) {
          Navigator.pop(context);
        },
      ),
      body: Stack(
        children: [
          Container(color: _kBg6),

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

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rekomendasi Stok',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Rekomendasi pengadaan stok',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: _navigateToManajemenPeriode,
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: _kPrimary6.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.calendar_month,
                                    color: _kPrimary6,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Periode Aktif',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 10,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                      Text(
                                        'Periode Khusus',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        '19 Feb 2026 → 20 Mar 2026  |  Rekomendasi disesuaikan',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 10,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_right,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: List.generate(_periodeLabel.length, (i) {
                              final sel = _periodeIdx == i;
                              return Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _periodeIdx = i),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: sel
                                          ? _kPrimary6
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Text(
                                      _periodeLabel[i],
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: sel
                                            ? Colors.white
                                            : Colors.grey.shade500,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                        const SizedBox(height: 14),

                        ..._items.map((item) {
                          final isHighlight =
                              widget.highlightProduk == item['nama'];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: isHighlight
                                  ? Border.all(color: _kPrimary6, width: 2)
                                  : null,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 38,
                                            height: 38,
                                            decoration: BoxDecoration(
                                              color: _kPrimary6.withOpacity(
                                                0.08,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(9),
                                            ),
                                            child: const Icon(
                                              Icons.checkroom,
                                              color: _kPrimary6,
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            item['nama'] as String,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                      _BadgeChip(
                                        label: item['badge'] as String,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      _InfoChip(
                                        label: 'Stok',
                                        value: '${item['stok']}',
                                      ),
                                      const SizedBox(width: 16),
                                      _InfoChip(
                                        label: 'Rata²',
                                        value: '${item['rataHari']}/hari',
                                      ),
                                      const SizedBox(width: 16),
                                      _InfoChip(
                                        label: 'Saran',
                                        value: '+${item['saranTambah']} pcs',
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  _buildStatusBtn(item),
                                ],
                              ),
                            ),
                          );
                        }),
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

  Widget _buildStatusBtn(Map<String, dynamic> item) {
    final status = item['status'] as String;

    switch (status) {
      case 'perlu_restock':
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _showRestockSheet(item),
            style: ElevatedButton.styleFrom(
              backgroundColor: _kPrimary6,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🔴', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
                Text(
                  'Restock Sekarang',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        );

      case 'sudah_dipesan':
        return GestureDetector(
          onTap: () => _showKonfirmasiTibaSheet(item),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3DC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _kGold.withOpacity(0.4)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🟡', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
                Text(
                  'Sudah Dipesan (barang belum tiba)',
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFFCC7000),
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        );

      case 'telah_tiba':
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF6EA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF629D3E).withOpacity(0.4)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('✅', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Text(
                'Telah Tiba',
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF629D3E),
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }
}

class _BadgeChip extends StatelessWidget {
  final String label;
  const _BadgeChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kPrimary6.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_offer_outlined, size: 11, color: _kPrimary6),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: _kPrimary6,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  const _InfoChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            color: Colors.grey.shade500,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _RestockQtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _RestockQtyBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: _kBg6,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: _kPrimary6, size: 20),
      ),
    );
  }
}
