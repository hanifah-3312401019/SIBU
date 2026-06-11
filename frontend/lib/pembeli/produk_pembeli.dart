// lib/pembeli/produk_pembeli.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../api/api_base_url.dart';
import '../auth/login_screen.dart';
import 'detail_produk.dart';
import 'rekomendasi_produk.dart';

const kBgColor = Color(0xFFF5ECEA);
const kPrimaryColor = Color(0xFF803033);

class ProdukPembeli extends StatefulWidget {
  const ProdukPembeli({super.key});

  @override
  State<ProdukPembeli> createState() => _ProdukPembeliState();
}

class _ProdukPembeliState extends State<ProdukPembeli> {
  final _searchController = TextEditingController();

  // Data API
  List<Map<String, dynamic>> _allProduk = [];
  List<Map<String, dynamic>> _filteredProduk = [];
  List<Map<String, dynamic>> _kategoriList = [];
  String _selectedKategori = 'Semua';
  String _searchQuery = '';
  bool _isLoading = true;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _fetchKategori();
    _fetchProduk();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  //  Fetch data 
  Future<void> _fetchKategori() async {
    try {
      final res = await http.get(
        Uri.parse(ApiBaseUrl.kategori),
        headers: {'Accept': 'application/json'},
      );
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data['success'] == true) {
          setState(() {
            _kategoriList = List<Map<String, dynamic>>.from(data['data']);
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _fetchProduk() async {
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    try {
      final uri = Uri.parse(ApiBaseUrl.produkPublik).replace(
        queryParameters: {
          if (_searchQuery.isNotEmpty) 'search': _searchQuery,
          if (_selectedKategori != 'Semua') ..._getKategoriIdParam(),
        },
      );

      final res = await http.get(uri, headers: {'Accept': 'application/json'});

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data['success'] == true) {
          setState(() {
            _allProduk = List<Map<String, dynamic>>.from(data['data']);
            _filteredProduk = _allProduk;
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
            _errorMsg = 'Gagal memuat produk';
          });
        }
      } else {
        setState(() {
          _isLoading = false;
          _errorMsg = 'Server error (${res.statusCode})';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMsg = 'Tidak dapat terhubung ke server';
      });
    }
  }

  Map<String, String> _getKategoriIdParam() {
    final found = _kategoriList.firstWhere(
      (k) => k['nama_kategori'] == _selectedKategori,
      orElse: () => {},
    );
    if (found.isNotEmpty && found['kategori_id'] != null) {
      return {'kategori_id': found['kategori_id'].toString()};
    }
    return {};
  }

  void _applyFilter() {
    setState(() {
      _filteredProduk = _allProduk.where((p) {
        final nama = ApiBaseUrl.safeString(p['nama_produk']).toLowerCase();
        final kat = ApiBaseUrl.safeString(p['kategori']).toLowerCase();

        final matchSearch = _searchQuery.isEmpty ||
            nama.contains(_searchQuery.toLowerCase());
        final matchKat = _selectedKategori == 'Semua' ||
            kat == _selectedKategori.toLowerCase();

        return matchSearch && matchKat;
      }).toList();
    });
  }

  // Helpers
  String _rupiah(int v) {
    final s = v.toString();
    return 'Rp ${s.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    )}';
  }

  List<String> get _kategoriTabs {
    final names = _kategoriList.map((k) => k['nama_kategori'].toString()).toList();
    return ['Semua', ...names];
  }

  // Build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgColor,
      body: Column(
        children: [
          // Header
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ani Butik Syar\'i',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: kPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Busana Muslim Pilihan',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: Colors.brown.shade400,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    ),
                    child: Container(
                      width: 33,  // Lebar tetap
                      height: 33, 
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.person_outline,
                          color: kPrimaryColor, size: 24),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Search + Filter
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: kPrimaryColor.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) {
                        _searchQuery = v;
                        _applyFilter();
                      },
                      style: GoogleFonts.plusJakartaSans(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Cari produk...',
                        hintStyle: GoogleFonts.plusJakartaSans(
                          color: Colors.grey.shade400,
                          fontSize: 13,
                        ),
                        prefixIcon: Icon(Icons.search,
                            color: Colors.grey.shade400, size: 20),
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 13),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Refresh button
                GestureDetector(
                  onTap: _fetchProduk,
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: kPrimaryColor.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.refresh,
                        color: kPrimaryColor, size: 20),
                  ),
                ),
              ],
            ),
          ),

          // Kategori chips
          if (_kategoriTabs.length > 1)
            SizedBox(
              height: 42,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                itemCount: _kategoriTabs.length,
                itemBuilder: (ctx, i) {
                  final kat = _kategoriTabs[i];
                  final selected = kat == _selectedKategori;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedKategori = kat);
                      _applyFilter();
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                      height: 40,
                      decoration: BoxDecoration(
                        color: selected ? kPrimaryColor : Colors.white,
                        borderRadius: BorderRadius.circular(20), // Pill shape yang rapi
                        border: Border.all(
                          color: selected ? kPrimaryColor : Colors.grey.shade300,
                          width: 1,
                        ),
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                  color: kPrimaryColor.withOpacity(0.15),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                )
                            ]
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          kat,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                            color: selected ? Colors.white : Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          const SizedBox(height: 12),

          // Grid produk
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: kPrimaryColor),
                  )
                : _errorMsg != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.wifi_off,
                                size: 48, color: Colors.grey.shade300),
                            const SizedBox(height: 12),
                            Text(
                              _errorMsg!,
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.grey.shade500,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _fetchProduk,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kPrimaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                'Coba Lagi',
                                style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      )
                    : _filteredProduk.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search_off,
                                    size: 48, color: Colors.grey.shade300),
                                const SizedBox(height: 12),
                                Text(
                                  'Produk tidak ditemukan',
                                  style: GoogleFonts.plusJakartaSans(
                                      color: Colors.grey.shade400),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            color: kPrimaryColor,
                            onRefresh: _fetchProduk,
                            child: GridView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                              physics: const AlwaysScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.72,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                              itemCount: _filteredProduk.length,
                              itemBuilder: (ctx, i) => _ProdukCard(
                                produk: _filteredProduk[i],
                                rupiah: _rupiah,
                              ),
                            ),
                          ),
          ),

          // Bottom Navigation
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
                  isSelected: true,
                ),
                _buildNavItem(
                  icon: Icons.favorite_outline,
                  label: 'Rekomendasi',
                  isSelected: false,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const RekomendasiProduk()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap ?? () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? kPrimaryColor : Colors.transparent,
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

// Kartu Produk
class _ProdukCard extends StatelessWidget {
  final Map<String, dynamic> produk;
  final String Function(int) rupiah;

  const _ProdukCard({required this.produk, required this.rupiah});

  @override
  Widget build(BuildContext context) {
    final gambarUrl =
        ApiBaseUrl.getImageUrl(ApiBaseUrl.safeString(produk['gambar']));
    final stok = ApiBaseUrl.safeInt(produk['stok']);
    final minStok = ApiBaseUrl.safeInt(produk['min_stok'], defaultValue: 10);
    final isLowStock = stok > 0 && stok <= minStok;

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
              color: Colors.brown.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar
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
                      loadingBuilder: (_, child, progress) => progress == null
                          ? child
                          : Container(
                              height: 130,
                              color: const Color(0xFFF5ECEA),
                              child: const Center(
                                child: CircularProgressIndicator(
                                    color: kPrimaryColor, strokeWidth: 2),
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rupiah(ApiBaseUrl.safeInt(produk['harga'])),
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: kPrimaryColor),
                        ),
                        if (stok == 0)
                          _badge('Habis', Colors.red)
                        else if (isLowStock)
                          _badge('Stok terbatas', Colors.orange),
                      ],
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
        child: const Icon(Icons.checkroom, color: kPrimaryColor, size: 50),
      );

  Widget _badge(String text, Color color) => Container(
        margin: const EdgeInsets.only(top: 4),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          text,
          style: GoogleFonts.plusJakartaSans(
              fontSize: 8, color: color, fontWeight: FontWeight.w600),
        ),
      );
}