// lib/pembeli/rekomendasi_produk.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../api/api_base_url.dart';
import 'produk_pembeli.dart';
import 'detail_produk.dart';

const _kBg = Color(0xFFF5ECEA);
const _kPrimary = Color(0xFF803033);

class RekomendasiProduk extends StatefulWidget {
  const RekomendasiProduk({super.key});

  @override
  State<RekomendasiProduk> createState() => _RekomendasiProdukState();
}

class _RekomendasiProdukState extends State<RekomendasiProduk> {
  // Data per seksi
  List<Map<String, dynamic>> _terbaru = [];
  List<Map<String, dynamic>> _hargaTerendah = [];
  List<Map<String, dynamic>> _perKategori = [];

  // Kategori
  List<Map<String, dynamic>> _kategoriList = [];
  Map<String, dynamic>? _selectedKategori;

  bool _isLoading = true;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _fetchKategori();
  }

  // Fetch 
  Future<void> _fetchKategori() async {
    try {
      final res = await http.get(
        Uri.parse(ApiBaseUrl.kategori),
        headers: {'Accept': 'application/json'},
      );
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data['success'] == true) {
          final list = List<Map<String, dynamic>>.from(data['data']);
          setState(() {
            _kategoriList = list;
            _selectedKategori = list.isNotEmpty ? list.first : null;
          });
        }
      }
    } catch (_) {}
    _fetchAll();
  }

  Future<void> _fetchAll() async {
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    try {
      final futures = await Future.wait([
        _fetchSeksi('terbaru'),
        _fetchSeksi('harga_terendah'),
        _fetchSeksiKategori(),
      ]);

      if (mounted) {
        setState(() {
          _terbaru = futures[0];
          _hargaTerendah = futures[1];
          _perKategori = futures[2];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMsg = 'Tidak dapat terhubung ke server';
        });
      }
    }
  }

  Future<List<Map<String, dynamic>>> _fetchSeksi(String tipe) async {
    final uri = Uri.parse(ApiBaseUrl.rekomendasi)
        .replace(queryParameters: {'tipe': tipe, 'limit': '8'});
    final res = await http.get(uri, headers: {'Accept': 'application/json'});
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      if (data['success'] == true) {
        return List<Map<String, dynamic>>.from(data['data']);
      }
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> _fetchSeksiKategori() async {
    if (_selectedKategori == null) return [];
    final uri = Uri.parse(ApiBaseUrl.rekomendasi).replace(queryParameters: {
      'tipe': 'kategori',
      'kategori_id': _selectedKategori!['kategori_id'].toString(),
      'limit': '8',
    });
    final res = await http.get(uri, headers: {'Accept': 'application/json'});
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      if (data['success'] == true) {
        return List<Map<String, dynamic>>.from(data['data']);
      }
    }
    return [];
  }

  Future<void> _gantiKategori(Map<String, dynamic> kat) async {
    setState(() {
      _selectedKategori = kat;
      _perKategori = [];
    });
    final result = await _fetchSeksiKategori();
    if (mounted) setState(() => _perKategori = result);
  }

  // Helper 
  String _rupiah(int v) {
    final s = v.toString();
    return 'Rp ${s.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    )}';
  }

  // Build 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          // Header
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Rekomendasi',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: _kPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: _kPrimary))
                : _errorMsg != null
                    ? _buildError()
                    : RefreshIndicator(
                        color: _kPrimary,
                        onRefresh: _fetchAll,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Produk Terbaru
                              if (_terbaru.isNotEmpty) ...[
                                _sectionHeader(
                                  icon: Icons.fiber_new_rounded,
                                  title: 'Produk Terbaru',
                                ),
                                const SizedBox(height: 12),
                                _buildGrid(_terbaru),
                                const SizedBox(height: 24),
                              ],
                              //  Harga Terendah 
                              if (_hargaTerendah.isNotEmpty) ...[
                                _sectionHeader(
                                  icon: Icons.arrow_downward_rounded,
                                  title: 'Harga Terendah',
                                  badgeText: 'Termurah',
                                  badgeColor: Colors.green,
                                ),
                                const SizedBox(height: 12),
                                _buildHorizontalList(_hargaTerendah),
                                const SizedBox(height: 24),
                              ],

                              //  Per Kategori 
                              if (_kategoriList.isNotEmpty) ...[
                                _sectionHeader(
                                  icon: Icons.category_outlined,
                                  title: 'Terlaris per Kategori',
                                ),
                                const SizedBox(height: 10),
                                // Chip pilih kategori
                                SizedBox(
                                  height: 42,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _kategoriList.length,
                                    itemBuilder: (_, i) {
                                      final kat = _kategoriList[i];
                                      final isSelected = _selectedKategori?['kategori_id'] ==
                                          kat['kategori_id'];
                                      return GestureDetector(
                                        onTap: () => _gantiKategori(kat),
                                        child: Container(
                                          margin: const EdgeInsets.only(right: 10),
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                                          height: 38,
                                          decoration: BoxDecoration(
                                            color: isSelected ? _kPrimary : Colors.white,
                                            borderRadius: BorderRadius.circular(19),
                                            border: Border.all(
                                              color: isSelected ? _kPrimary : Colors.grey.shade300,
                                              width: 1,
                                            ),
                                            boxShadow: isSelected
                                                ? [
                                                    BoxShadow(
                                                      color: _kPrimary.withOpacity(0.15),
                                                      blurRadius: 6,
                                                      offset: const Offset(0, 2),
                                                    )
                                                  ]
                                                : null,
                                          ),
                                          child: Center(
                                            child: Text(
                                              kat['nama_kategori'].toString(),
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 12,
                                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                                color: isSelected ? Colors.white : Colors.grey.shade700,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _perKategori.isEmpty
                                    ? Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(24),
                                          child: Text(
                                            'Belum ada produk di kategori ini',
                                            style: GoogleFonts.plusJakartaSans(
                                                color: Colors.grey.shade400,
                                                fontSize: 13),
                                          ),
                                        ),
                                      )
                                    : _buildGrid(_perKategori),
                                const SizedBox(height: 24),
                              ],
                            ],
                          ),
                        ),
                      ),
          ),

          // Bottom Nav
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(
                  icon: Icons.shopping_bag_outlined,
                  label: 'Produk',
                  isSelected: false,
                  onTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const ProdukPembeli()),
                  ),
                ),
                _buildNavItem(
                  icon: Icons.favorite_outline,
                  label: 'Rekomendasi',
                  isSelected: true,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Section Header
  Widget _sectionHeader({
    required IconData icon,
    required String title,
    String? badgeText,
    Color? badgeColor,
  }) {
    return Row(
      children: [
        Icon(icon, color: _kPrimary, size: 18),
        const SizedBox(width: 6),
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade800,
          ),
        ),
        if (badgeText != null) ...[
          const SizedBox(width: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: (badgeColor ?? Colors.grey).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              badgeText,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: badgeColor ?? Colors.grey,
              ),
            ),
          ),
        ],
      ],
    );
  }

  // Grid 2 kolom 
  Widget _buildGrid(List<Map<String, dynamic>> list) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: list.length,
      itemBuilder: (ctx, i) =>
          _RekomendasiCard(produk: list[i], rupiah: _rupiah),
    );
  }

  // Horizontal scroll list 
  Widget _buildHorizontalList(List<Map<String, dynamic>> list) {
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: list.length,
        itemBuilder: (ctx, i) {
          final prod = list[i];
          final gambarUrl =
              ApiBaseUrl.getImageUrl(ApiBaseUrl.safeString(prod['gambar']));
          return GestureDetector(
            onTap: () => Navigator.push(
              ctx,
              MaterialPageRoute(
                  builder: (_) => DetailProduk(produk: prod)),
            ),
            child: Container(
              width: 150,
              margin: EdgeInsets.only(right: i < list.length - 1 ? 12 : 0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.brown.withOpacity(0.07),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16)),
                    child: gambarUrl.isNotEmpty
                        ? Image.network(
                            gambarUrl,
                            height: 140,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _imgPlaceholder(),
                          )
                        : _imgPlaceholder(),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            ApiBaseUrl.safeString(prod['nama_produk']),
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            _rupiah(ApiBaseUrl.safeInt(prod['harga'])),
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: _kPrimary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _imgPlaceholder() => Container(
        height: 140,
        width: double.infinity,
        color: const Color(0xFFF5ECEA),
        child: const Icon(Icons.checkroom, color: _kPrimary, size: 50),
      );

  Widget _buildError() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(_errorMsg!,
                style: GoogleFonts.plusJakartaSans(
                    color: Colors.grey.shade500)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchAll,
              style: ElevatedButton.styleFrom(
                backgroundColor: _kPrimary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: Text('Coba Lagi',
                  style:
                      GoogleFonts.plusJakartaSans(color: Colors.white)),
            ),
          ],
        ),
      );

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? _kPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                color: isSelected ? Colors.white : Colors.grey.shade400,
                size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Kartu Grid 
class _RekomendasiCard extends StatelessWidget {
  final Map<String, dynamic> produk;
  final String Function(int) rupiah;

  const _RekomendasiCard({required this.produk, required this.rupiah});

  @override
  Widget build(BuildContext context) {
    final gambarUrl =
        ApiBaseUrl.getImageUrl(ApiBaseUrl.safeString(produk['gambar']));

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DetailProduk(produk: produk)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.brown.withOpacity(0.07),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: gambarUrl.isNotEmpty
                  ? Image.network(
                      gambarUrl,
                      width: double.infinity,
                      height: 130,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder(),
                      loadingBuilder: (_, child, progress) =>
                          progress == null
                              ? child
                              : Container(
                                  height: 130,
                                  color: const Color(0xFFF5ECEA),
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                        color: _kPrimary, strokeWidth: 2),
                                  ),
                                ),
                    )
                  : _placeholder(),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      ApiBaseUrl.safeString(produk['nama_produk']),
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      rupiah(ApiBaseUrl.safeInt(produk['harga'])),
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: _kPrimary),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
        height: 130,
        width: double.infinity,
        color: const Color(0xFFF5ECEA),
        child: const Icon(Icons.checkroom, color: _kPrimary, size: 50),
      );
}