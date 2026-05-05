// lib/penjual/tambah_transaksi_baru.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'riwayat_transaksi_screen.dart';

const _kPrimary2 = Color(0xFF803033);
const _kBg2 = Color(0xFFF5ECEA);

final List<Map<String, dynamic>> _produkList = [
  {
    'id': '1',
    'nama': 'Gamis Ceruty Payet',
    'harga': 355000,
    'stok': 12,
    'gambar': null,
  },
  {
    'id': '2',
    'nama': 'Khimar Dagu Navy',
    'harga': 150000,
    'stok': 8,
    'gambar': null,
  },
  {
    'id': '3',
    'nama': 'Ring Hijab Flower',
    'harga': 25000,
    'stok': 30,
    'gambar': null,
  },
  {
    'id': '4',
    'nama': 'Mukena Katun Sage',
    'harga': 250000,
    'stok': 5,
    'gambar': null,
  },
  {
    'id': '5',
    'nama': 'Gamis Brukat Premium',
    'harga': 450000,
    'stok': 3,
    'gambar': null,
  },
  {
    'id': '6',
    'nama': 'Abaya Cokelat Elegan',
    'harga': 385000,
    'stok': 7,
    'gambar': 'assets/images/abaya_cokelat.jpg',
  },
  {
    'id': '7',
    'nama': 'Hijab Pashmina Ceruty',
    'harga': 75000,
    'stok': 20,
    'gambar': null,
  },
  {
    'id': '8',
    'nama': 'Tunik Batik Mega Mendung',
    'harga': 185000,
    'stok': 10,
    'gambar': null,
  },
];

class TambahTransaksiBaru extends StatefulWidget {
  final String? userName;
  final String? userEmail;
  const TambahTransaksiBaru({super.key, this.userName, this.userEmail});

  @override
  State<TambahTransaksiBaru> createState() => _TambahTransaksiBaruState();
}

class _TambahTransaksiBaruState extends State<TambahTransaksiBaru> {
  final _searchCtrl = TextEditingController();
  Map<String, dynamic>? _selectedProduk;
  int _jumlah = 0;

  // Contoh data keranjang dengan gambar Abaya Cokelat Elegan
  final List<Map<String, dynamic>> _keranjang = [
    {
      'id': '6',
      'nama': 'Abaya Cokelat Elegan',
      'harga': 385000,
      'stok': 7,
      'jumlah': 1,
      'gambar': 'assets/images/abaya_cokelat.jpg',
    },
  ];

  String _searchQuery = '';

  void _navigateBack() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => RiwayatTransaksiScreen(
          userName: widget.userName ?? 'Ani Rani',
          userEmail: widget.userEmail ?? 'ani@gmail.com',
        ),
      ),
    );
  }

  String _rupiah(int v) {
    final s = v.toString();
    return 'Rp ${s.replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  int get _subtotal => _keranjang.fold(
    0,
    (s, e) => s + (e['harga'] as int) * (e['jumlah'] as int),
  );

  List<Map<String, dynamic>> get _filteredProduk => _produkList
      .where(
        (p) => p['nama'].toString().toLowerCase().contains(
          _searchQuery.toLowerCase(),
        ),
      )
      .toList();

  void _tambahKeKeranjang() {
    if (_selectedProduk == null || _jumlah == 0) {
      _snack('Pilih produk dan jumlah dulu');
      return;
    }
    final stok = _selectedProduk!['stok'] as int;
    if (_jumlah > stok) {
      _snack('Stok tidak cukup (tersisa $stok)');
      return;
    }
    setState(() {
      final idx = _keranjang.indexWhere(
        (k) => k['id'] == _selectedProduk!['id'],
      );
      if (idx >= 0) {
        _keranjang[idx]['jumlah'] =
            (_keranjang[idx]['jumlah'] as int) + _jumlah;
      } else {
        _keranjang.add({..._selectedProduk!, 'jumlah': _jumlah});
      }
      _selectedProduk = null;
      _jumlah = 0;
      _searchCtrl.clear();
      _searchQuery = '';
    });
  }

  void _simpan() {
    if (_keranjang.isEmpty) {
      _snack('Keranjang masih kosong');
      return;
    }
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 44,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Transaksi Berhasil!',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Total: ${_rupiah(_subtotal)}',
              style: TextStyle(color: _kPrimary2, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _keranjang.clear());
            },
            child: const Text('Transaksi Baru'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateBack();
            },
            child: const Text('Lihat Riwayat'),
          ),
        ],
      ),
    );
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: _kPrimary2,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildProductImage(String? gambar) {
    if (gambar != null && gambar.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset(
          gambar,
          width: 44,
          height: 44,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _kPrimary2.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.checkroom, color: _kPrimary2, size: 22),
            );
          },
        ),
      );
    } else {
      return Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: _kPrimary2.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.checkroom, color: _kPrimary2, size: 22),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg2,
      body: Stack(
        children: [
          Container(color: _kBg2),

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
                // Header dengan tombol back
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: _navigateBack,
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 20,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tambah Transaksi',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Catat penjualan butik',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Card PILIH PRODUK
                        Container(
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
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'PILIH PRODUK',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: _kPrimary2,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 10),

                              // Search produk
                              Container(
                                decoration: BoxDecoration(
                                  color: _kBg2,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: TextField(
                                  controller: _searchCtrl,
                                  onChanged: (v) =>
                                      setState(() => _searchQuery = v),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Cari produk...',
                                    hintStyle: GoogleFonts.plusJakartaSans(
                                      color: Colors.grey.shade400,
                                      fontSize: 13,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.search,
                                      color: Colors.grey.shade400,
                                      size: 18,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ),

                              if (_searchQuery.isNotEmpty)
                                Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                  child: Column(
                                    children: _filteredProduk.map((p) {
                                      return ListTile(
                                        dense: true,
                                        leading: _buildProductImage(
                                          p['gambar'],
                                        ),
                                        title: Text(
                                          p['nama'] as String,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 13,
                                          ),
                                        ),
                                        subtitle: Text(
                                          '${_rupiah(p['harga'] as int)} · Stok: ${p['stok']}',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11,
                                            color: Colors.grey.shade500,
                                          ),
                                        ),
                                        onTap: () {
                                          setState(() {
                                            _selectedProduk = p;
                                            _searchQuery = '';
                                            _searchCtrl.text =
                                                p['nama'] as String;
                                          });
                                        },
                                      );
                                    }).toList(),
                                  ),
                                ),

                              // Produk terpilih
                              if (_selectedProduk != null) ...[
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _kPrimary2.withOpacity(0.06),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      _buildProductImage(
                                        _selectedProduk!['gambar'],
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          _selectedProduk!['nama'] as String,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        _rupiah(
                                          _selectedProduk!['harga'] as int,
                                        ),
                                        style: GoogleFonts.plusJakartaSans(
                                          color: _kPrimary2,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],

                              const SizedBox(height: 16),

                              Text(
                                'JUMLAH',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: _kPrimary2,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 10),

                              Row(
                                children: [
                                  _QtyBtn(
                                    icon: Icons.remove,
                                    onTap: () => setState(() {
                                      if (_jumlah > 0) _jumlah--;
                                    }),
                                  ),
                                  Container(
                                    width: 60,
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _kBg2,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '$_jumlah',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  _QtyBtn(
                                    icon: Icons.add,
                                    onTap: () => setState(() => _jumlah++),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),

                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () => setState(() {
                                        _selectedProduk = null;
                                        _jumlah = 0;
                                        _searchCtrl.clear();
                                        _searchQuery = '';
                                      }),
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(
                                          color: Colors.grey.shade300,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
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
                                      onPressed: _tambahKeKeranjang,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _kPrimary2,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                      ),
                                      child: Text(
                                        'Tambah',
                                        style: GoogleFonts.plusJakartaSans(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        Text(
                          'PRODUK YANG DIPILIH:',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.black54,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 10),

                        ..._keranjang.map(
                          (item) => Container(
                            margin: const EdgeInsets.only(bottom: 10),
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
                                _buildProductImage(item['gambar']),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['nama'] as String,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Jumlah: ${item['jumlah']}',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _rupiah(
                                          (item['harga'] as int) *
                                              (item['jumlah'] as int),
                                        ),
                                        style: GoogleFonts.plusJakartaSans(
                                          color: _kPrimary2,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () =>
                                      setState(() => _keranjang.remove(item)),
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // SUBTOTAL, DISKON, TOTAL
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            children: [
                              _SummaryRow(
                                label: 'Subtotal',
                                value: _rupiah(_subtotal),
                              ),
                              const SizedBox(height: 8),
                              const _SummaryRow(label: 'Diskon', value: '–'),
                              const Divider(height: 20),
                              _SummaryRow(
                                label: 'Total',
                                value: _rupiah(_subtotal),
                                bold: true,
                                valueColor: _kPrimary2,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _keranjang.clear()),
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
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: _simpan,
                  icon: const Icon(Icons.check, color: Colors.white, size: 18),
                  label: Text(
                    'Simpan Transaksi',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kPrimary2,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: _kBg2,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: _kPrimary2),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  final Color? valueColor;
  const _SummaryRow({
    required this.label,
    required this.value,
    this.bold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: Colors.grey.shade600,
            fontWeight: bold ? FontWeight.w700 : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: bold ? 15 : 13,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}
