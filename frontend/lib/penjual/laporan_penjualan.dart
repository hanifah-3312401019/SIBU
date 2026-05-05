// lib/penjual/laporan_penjualan.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'notifikasi_penjual.dart';
import '../widgets/sidebar_penjual.dart';

const _kPrimary4 = Color(0xFF803033);
const _kBg4 = Color(0xFFF5ECEA);

class LaporanPenjualan extends StatefulWidget {
  final String? userName;
  final String? userEmail;
  const LaporanPenjualan({super.key, this.userName, this.userEmail});

  @override
  State<LaporanPenjualan> createState() => _LaporanPenjualanState();
}

class _LaporanPenjualanState extends State<LaporanPenjualan> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _periodIdx = 1;
  final List<String> _periods = ['Harian', 'Mingguan', 'Bulanan'];

  final Map<int, Map<String, dynamic>> _data = {
    0: {
      'total': 1250000,
      'transaksi': 3,
      'labels': ['08', '09', '10', '11', '12', '13', '14'],
      'values': [0.3, 0.5, 0.7, 0.4, 0.9, 0.6, 0.8],
    },
    1: {
      'total': 21500000,
      'transaksi': 15,
      'labels': ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'],
      'values': [0.4, 0.5, 0.85, 0.45, 1.0, 0.55, 0.7],
    },
    2: {
      'total': 87000000,
      'transaksi': 62,
      'labels': ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul'],
      'values': [0.5, 0.6, 0.75, 0.8, 0.9, 1.0, 0.85],
    },
  };

  // Data produk dari produk_screen.dart
  final List<Map<String, dynamic>> _products = [
    {
      'id': 1,
      'name': 'Abaya Cokelat Elegan',
      'price': 385000,
      'stock': 15,
      'category': 'Abaya',
      'terjual': 25,
      'omzet': 9625000,
      'imageAsset': 'assets/images/abaya_cokelat.jpg',
      'imageIcon': Icons.shopping_bag_outlined,
    },
    {
      'id': 2,
      'name': 'Gamis Ceruty Payet',
      'price': 295000,
      'stock': 5,
      'category': 'Gamis',
      'terjual': 39,
      'omzet': 11505000,
      'imageAsset': 'assets/images/gamisceruty.jpg',
      'imageIcon': Icons.shopping_bag_outlined,
    },
    {
      'id': 3,
      'name': 'Baju Kurung Melayu',
      'price': 355000,
      'stock': 7,
      'category': 'Baju Kurung',
      'terjual': 18,
      'omzet': 6390000,
      'imageAsset': 'assets/images/bajukurung.jpg',
      'imageIcon': Icons.shopping_bag_outlined,
    },
    {
      'id': 4,
      'name': 'Khimar Saudi',
      'price': 175000,
      'stock': 20,
      'category': 'Khimar',
      'terjual': 12,
      'omzet': 2100000,
      'imageAsset': 'assets/images/khimarsaudi.jpg',
      'imageIcon': Icons.shopping_bag_outlined,
    },
    {
      'id': 5,
      'name': 'Bergo Hamidah',
      'price': 45000,
      'stock': 8,
      'category': 'Bergo',
      'terjual': 30,
      'omzet': 1350000,
      'imageAsset': 'assets/images/bergohamidah.jpg',
      'imageIcon': Icons.shopping_bag_outlined,
    },
    {
      'id': 6,
      'name': 'Abaya Putih Premium',
      'price': 425000,
      'stock': 12,
      'category': 'Abaya',
      'terjual': 8,
      'omzet': 3400000,
      'imageAsset': 'assets/images/abayaputih.jpg',
      'imageIcon': Icons.shopping_bag_outlined,
    },
    {
      'id': 7,
      'name': 'Gamis Brukat',
      'price': 450000,
      'stock': 3,
      'category': 'Gamis',
      'terjual': 15,
      'omzet': 6750000,
      'imageAsset': 'assets/images/gamisbrukat.jpg',
      'imageIcon': Icons.shopping_bag_outlined,
    },
    {
      'id': 8,
      'name': 'Baju Kurung Haera',
      'price': 389000,
      'stock': 10,
      'category': 'Baju Kurung',
      'terjual': 10,
      'omzet': 3890000,
      'imageAsset': 'assets/images/bajukurunghaera.jpg',
      'imageIcon': Icons.shopping_bag_outlined,
    },
  ];

  List<Map<String, dynamic>> get _produkTerlaris {
    final sorted = List<Map<String, dynamic>>.from(_products);
    sorted.sort((a, b) => (b['terjual'] as int).compareTo(a['terjual'] as int));
    return sorted.take(5).toList().asMap().entries.map((entry) {
      return {...entry.value, 'rank': entry.key + 1};
    }).toList();
  }

  List<Map<String, dynamic>> get _rekomendasiRestock {
    return _products.where((p) => (p['stock'] as int) <= 5).map((p) {
      return {
        'nama': p['name'],
        'stok': p['stock'],
        'habis': p['stock'] <= 2 ? '~2 hari' : '~5 hari',
        'imageAsset': p['imageAsset'],
        'imageIcon': p['imageIcon'],
      };
    }).toList();
  }

  String _rupiah(int v) {
    if (v >= 1000000) {
      final jt = (v / 1000000);
      return 'Rp ${jt % 1 == 0 ? jt.toInt() : jt.toStringAsFixed(1)}jt';
    }
    final s = v.toString();
    return 'Rp ${s.replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  void _export(String tipe) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Export $tipe berhasil diproses'),
        backgroundColor: _kPrimary4,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showExportSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Export Laporan',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: _kPrimary4,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Pilih format export yang diinginkan',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _ExportBtn(
                    icon: Icons.picture_as_pdf,
                    label: 'PDF',
                    color: Colors.red.shade600,
                    onTap: () {
                      Navigator.pop(context);
                      _export('PDF');
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ExportBtn(
                    icon: Icons.table_chart,
                    label: 'Excel',
                    color: Colors.green.shade600,
                    onTap: () {
                      Navigator.pop(context);
                      _export('Excel');
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _navigateToNotifikasi() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NotifikasiPenjual()),
    );
  }

  Widget _buildProductImage(String? imageAsset, IconData fallbackIcon) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: imageAsset != null && imageAsset.isNotEmpty
          ? Image.asset(
              imageAsset,
              width: 44,
              height: 44,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _kPrimary4.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(fallbackIcon, color: _kPrimary4, size: 22),
                );
              },
            )
          : Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _kPrimary4.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(fallbackIcon, color: _kPrimary4, size: 22),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final d = _data[_periodIdx]!;
    final labels = d['labels'] as List<String>;
    final values = d['values'] as List<double>;
    final produkTerlaris = _produkTerlaris;
    final rekomendasiRestock = _rekomendasiRestock;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: _kBg4,
      drawer: SidebarWidget(
        userName: widget.userName ?? 'Ani Rani',
        userEmail: widget.userEmail ?? 'ani@gmail.com',
        selectedIndex: 3,
        onItemSelected: (index) {
          Navigator.pop(context);
        },
      ),
      body: Stack(
        children: [
          Container(color: _kBg4),

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
                      GestureDetector(
                        onTap: _navigateToNotifikasi,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.notifications_none,
                            color: Color(0xFF803033),
                            size: 20,
                          ),
                        ),
                      ),
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
                        'Laporan Penjualan',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Data laporan penjualan',
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Period tab
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: List.generate(_periods.length, (i) {
                              final sel = _periodIdx == i;
                              return Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _periodIdx = i),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: sel
                                          ? _kPrimary4
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Text(
                                      _periods[i],
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: sel
                                            ? Colors.white
                                            : Colors.grey.shade500,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Total penjualan card
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Total Penjualan',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _rupiah(d['total'] as int),
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        'Transaksi',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${d['transaksi']}',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // Bar chart
                              SizedBox(
                                height: 120,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: List.generate(labels.length, (i) {
                                    final v = values[i];
                                    return Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 400,
                                          ),
                                          width: 28,
                                          height: 80 * v,
                                          decoration: BoxDecoration(
                                            color: v >= 0.9
                                                ? _kPrimary4
                                                : _kPrimary4.withOpacity(0.25),
                                            borderRadius:
                                                const BorderRadius.vertical(
                                                  top: Radius.circular(6),
                                                ),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          labels[i],
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 10,
                                            color: Colors.grey.shade500,
                                          ),
                                        ),
                                      ],
                                    );
                                  }),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Produk Terlaris
                        Text(
                          'Produk Terlaris',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...produkTerlaris.map(
                          (p) => Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                _buildProductImage(
                                  p['imageAsset'],
                                  p['imageIcon'],
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        p['name'] as String,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${p['terjual']} terjual  |  ${_rupiah(p['omzet'] as int)}',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _kPrimary4.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '#${p['rank']}',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: _kPrimary4,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Rekomendasi Restock
                        if (rekomendasiRestock.isNotEmpty) ...[
                          Text(
                            'Rekomendasi Restock',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...rekomendasiRestock.map(
                            (r) => Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF8E7),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(
                                    0xFFFF8C00,
                                  ).withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  _buildProductImage(
                                    r['imageAsset'],
                                    r['imageIcon'],
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          r['nama'] as String,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Stok: ${r['stok']}  |  Habis ${r['habis']}',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFF8C00),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'URGENT',
                                      style: GoogleFonts.plusJakartaSans(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Tombol Export
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _showExportSheet,
                            icon: const Icon(
                              Icons.download,
                              color: Colors.white,
                              size: 18,
                            ),
                            label: Text(
                              'Export Laporan (PDF / Excel)',
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _kPrimary4,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
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

class _ExportBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ExportBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
