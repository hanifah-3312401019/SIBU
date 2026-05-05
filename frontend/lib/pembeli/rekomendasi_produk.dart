// lib/pembeli/rekomendasi_produk.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'produk_pembeli.dart';
import 'detail_produk.dart';

const _kBg = Color(0xFFF5ECEA);
const _kPrimary = Color(0xFF803033);

class RekomendasiProduk extends StatelessWidget {
  const RekomendasiProduk({super.key});

  String _rupiah(int v) {
    final s = v.toString();
    return 'Rp ${s.replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  List<Map<String, dynamic>> get _populerGamis {
    return produkList
        .where((p) => p['category'] == 'Gamis')
        .take(4)
        .toList();
  }

  List<Map<String, dynamic>> get _hargaTerlaris {
    final sorted = List<Map<String, dynamic>>.from(produkList);
    sorted.sort((a, b) => a['price'].compareTo(b['price']));
    return sorted.take(4).toList();
  }

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
                  child: const Icon(Icons.checkroom, color: _kPrimary, size: 50),
                );
              },
            )
          : Container(
              height: 140,
              width: double.infinity,
              color: const Color(0xFFF5ECEA),
              child: const Icon(Icons.checkroom, color: _kPrimary, size: 50),
            ),
    );
  }

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
                  const Icon(Icons.star_border, color: _kPrimary, size: 26),
                ],
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  // Section Populer di Kategori Gamis
                  Text(
                    'Populer di Kategori Gamis',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.72,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: _populerGamis.length,
                    itemBuilder: (ctx, i) => _RekomendasiCard(
                      produk: _populerGamis[i],
                      rupiah: _rupiah,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Section Harga Terlaris
                  Text(
                    'Harga Terlaris',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.72,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: _hargaTerlaris.length,
                    itemBuilder: (ctx, i) => _RekomendasiCard(
                      produk: _hargaTerlaris[i],
                      rupiah: _rupiah,
                    ),
                  ),

                  const SizedBox(height: 80),
                ],
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
                  isSelected: false,
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const ProdukPembeli()),
                    );
                  },
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

class _RekomendasiCard extends StatelessWidget {
  final Map<String, dynamic> produk;
  final String Function(int) rupiah;

  const _RekomendasiCard({
    required this.produk,
    required this.rupiah,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailProduk(produk: produk),
          ),
        );
      },
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
                      color: _kPrimary,
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
                  child: const Icon(Icons.checkroom, color: _kPrimary, size: 50),
                );
              },
            )
          : Container(
              height: 140,
              width: double.infinity,
              color: const Color(0xFFF5ECEA),
              child: const Icon(Icons.checkroom, color: _kPrimary, size: 50),
            ),
    );
  }
}