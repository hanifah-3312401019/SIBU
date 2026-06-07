import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'detail_produk.dart';
import 'rekomendasi_produk.dart';
import '../auth/login_screen.dart';

const kBgColor = Color(0xFFF5ECEA);
const kPrimaryColor = Color(0xFF803033);

final List<Map<String, dynamic>> produkList = [
  {
    'id': 1,
    'name': 'Abaya Cokelat Elegan',
    'price': 385000,
    'stock': 15,
    'category': 'Abaya',
    'isLowStock': false,
    'imageAsset': 'assets/images/abaya_cokelat.jpg',
    'description': 'Abaya elegan berwarna cokelat dengan bahan premium. Nyaman dipakai sehari-hari maupun acara formal.',
  },
  {
    'id': 2,
    'name': 'Gamis Ceruty Payet',
    'price': 295000,
    'stock': 5,
    'category': 'Gamis',
    'isLowStock': true,
    'imageAsset': 'assets/images/gamisceruty.jpg',
    'description': 'Gamis Ceruty Payet elegan dengan bahan jatuh dan mewah. Detail payetnya cantik, cocok untuk pesta.',
  },
  {
    'id': 3,
    'name': 'Baju Kurung Melayu',
    'price': 355000,
    'stock': 7,
    'category': 'Baju Kurung',
    'isLowStock': true,
    'imageAsset': 'assets/images/bajukurung.jpg',
    'description': 'Baju Kurung Melayu modern, cocok untuk acara formal dan sehari-hari.',
  },
  {
    'id': 4,
    'name': 'Khimar Saudi',
    'price': 175000,
    'stock': 20,
    'category': 'Khimar',
    'isLowStock': false,
    'imageAsset': 'assets/images/khimarsaudi.jpg',
    'description': 'Khimar Saudi bahan ceruty premium, jatuh dan tidak mudah kusut.',
  },
  {
    'id': 5,
    'name': 'Bergo Hamidah',
    'price': 45000,
    'stock': 8,
    'category': 'Bergo',
    'isLowStock': true,
    'imageAsset': 'assets/images/bergohamidah.jpg',
    'description': 'Bergo Hamidah bahan katun lembut, nyaman dipakai seharian.',
  },
  {
    'id': 6,
    'name': 'Abaya Putih Premium',
    'price': 425000,
    'stock': 12,
    'category': 'Abaya',
    'isLowStock': false,
    'imageAsset': 'assets/images/abayaputih.jpg',
    'description': 'Abaya putih premium dengan bahan crepe, elegan dan mewah.',
  },
  {
    'id': 7,
    'name': 'Gamis Brukat',
    'price': 450000,
    'stock': 3,
    'category': 'Gamis',
    'isLowStock': true,
    'imageAsset': 'assets/images/gamisbrukat.jpg',
    'description': 'Gamis brukat dengan detail payet cantik. Cocok untuk acara pernikahan.',
  },
  {
    'id': 8,
    'name': 'Baju Kurung Haera',
    'price': 389000,
    'stock': 10,
    'category': 'Baju Kurung',
    'isLowStock': false,
    'imageAsset': 'assets/images/bajukurunghaera.jpg',
    'description': 'Baju Kurung Haera modern dengan warna pastel.',
  },
];

class ProdukPembeli extends StatefulWidget {
  const ProdukPembeli({super.key});

  @override
  State<ProdukPembeli> createState() => _ProdukPembeliState();
}

class _ProdukPembeliState extends State<ProdukPembeli> {
  final _searchController = TextEditingController();
  String _selectedKategori = 'Semua';
  String _searchQuery = '';

  final List<String> _kategoriList = [
    'Semua', 'Abaya', 'Gamis', 'Baju Kurung', 'Khimar', 'Bergo',
  ];

  List<Map<String, dynamic>> get _filteredProduk {
    return produkList.where((p) {
      final matchKategori = _selectedKategori == 'Semua' || p['category'] == _selectedKategori;
      final matchSearch = _searchQuery.isEmpty ||
          p['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      return matchKategori && matchSearch;
    }).toList();
  }

  String _rupiah(int v) {
    final s = v.toString();
    return 'Rp ${s.replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  void _navigateToLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _navigateToRekomendasi() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RekomendasiProduk()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final produk = _filteredProduk;

    return Scaffold(
      backgroundColor: kBgColor,
      body: Column(
        children: [
          // Header (tetap di atas, tidak ikut scroll)
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
                  // Ikon Login di pojok kanan atas
                  GestureDetector(
                    onTap: _navigateToLogin,
                    child: Container(
                      padding: const EdgeInsets.all(8),
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
                      child: Icon(
                        Icons.person_outline,
                        color: kPrimaryColor,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content (search, filter, grid, footer)
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // Search & Filter
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Search bar
                        Container(
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
                            onChanged: (v) => setState(() => _searchQuery = v),
                            style: GoogleFonts.plusJakartaSans(fontSize: 13),
                            decoration: InputDecoration(
                              hintText: 'Cari Gamis Syar\'i, Jilbab, Tunik.....',
                              hintStyle: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                color: Colors.grey.shade400,
                              ),
                              prefixIcon: Icon(Icons.search, color: Colors.grey.shade400, size: 20),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Filter kategori
                        SizedBox(
                          height: 34,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _kategoriList.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 8),
                            itemBuilder: (_, i) {
                              final kat = _kategoriList[i];
                              final selected = kat == _selectedKategori;
                              return GestureDetector(
                                onTap: () => setState(() => _selectedKategori = kat),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: selected ? kPrimaryColor : Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: selected ? kPrimaryColor : Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Text(
                                    kat,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: selected ? Colors.white : Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Grid Produk
                  produk.isEmpty
                      ? SizedBox(
                          height: 300,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search_off, size: 48, color: Colors.grey.shade300),
                                const SizedBox(height: 12),
                                Text(
                                  'Produk tidak ditemukan',
                                  style: GoogleFonts.plusJakartaSans(color: Colors.grey.shade400),
                                ),
                              ],
                            ),
                          ),
                        )
                      : GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.72,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: produk.length,
                          itemBuilder: (ctx, i) => _ProdukCard(
                            produk: produk[i],
                            rupiah: _rupiah,
                          ),
                        ),

                  // Footer "SIBU v1.0.0" (paling bawah)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      'SIBU v1.0.0',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),

          // Bottom Navigation (Produk & Rekomendasi)
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
                _buildNavItem(icon: Icons.shopping_bag_outlined, label: 'Produk', isSelected: true),
                _buildNavItem(
                  icon: Icons.favorite_outline,
                  label: 'Rekomendasi',
                  isSelected: false,
                  onTap: _navigateToRekomendasi,
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
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey.shade400,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
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

  Widget _buildProductImage(String? imageAsset) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: imageAsset != null && imageAsset.isNotEmpty
          ? Image.asset(
              imageAsset,
              width: double.infinity,
              height: 140,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 140,
                  width: double.infinity,
                  color: const Color(0xFFF5ECEA),
                  child: const Icon(Icons.checkroom, color: Color(0xFF803033), size: 50),
                );
              },
            )
          : Container(
              height: 140,
              width: double.infinity,
              color: const Color(0xFFF5ECEA),
              child: const Icon(Icons.checkroom, color: Color(0xFF803033), size: 50),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DetailProduk(produk: produk)),
        );
      },
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
            _buildProductImage(produk['imageAsset']),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    produk['name'],
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    rupiah(produk['price']),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: kPrimaryColor,
                    ),
                  ),
                  if (produk['isLowStock'] == true)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Stok terbatas',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 8,
                          color: Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}