// lib/pembeli/detail_produk.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'produk_pembeli.dart';

const _kBg = Color(0xFFF5ECEA);
const _kPrimary = Color(0xFF803033);

class DetailProduk extends StatefulWidget {
  final Map<String, dynamic> produk;
  const DetailProduk({super.key, required this.produk});

  @override
  State<DetailProduk> createState() => _DetailProdukState();
}

class _DetailProdukState extends State<DetailProduk> {
  int _currentImage = 0;
  String? _selectedUkuran;

  List<Color> get _gradientColors {
    return [const Color(0xFFB08A8A), const Color(0xFF8C6060)];
  }

  List<List<Color>> get _images => [
        _gradientColors,
        [_gradientColors[1], Color.lerp(_gradientColors[0], Colors.black, 0.2)!],
        [Color.lerp(_gradientColors[0], Colors.white, 0.15)!, _gradientColors[1]],
      ];

  List<Map<String, dynamic>> get _cocokDipadukan {
    return produkList.where((p) => p['id'] != widget.produk['id']).take(2).toList();
  }

  List<String> get _ukuranList {
    final ukuran = widget.produk['ukuran'] ?? 'All Size';
    if (ukuran == 'All Size' || ukuran == 'Free Size') {
      return [ukuran];
    }
    return ukuran.split(',').map((s) => s.trim()).toList();
  }

  String _rupiah(int v) {
    final s = v.toString();
    return 'Rp ${s.replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  Future<void> _hubungiWa() async {
    final p = widget.produk;
    final noWa = '6281234567890';
    final pesan = Uri.encodeComponent(
      'Halo Kak, saya tertarik dengan produk *${p['name']}* '
      'seharga ${_rupiah(p['price'])}. Apakah masih tersedia? 😊',
    );
    final url = Uri.parse('https://wa.me/$noWa?text=$pesan');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak bisa membuka WhatsApp'),
            backgroundColor: _kPrimary,
          ),
        );
      }
    }
  }

  Widget _buildProductImage(String? imageAsset) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: imageAsset != null && imageAsset.isNotEmpty
          ? Image.asset(
              imageAsset,
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 250,
                  width: double.infinity,
                  color: const Color(0xFFF5ECEA),
                  child: const Icon(Icons.checkroom, color: _kPrimary, size: 80),
                );
              },
            )
          : Container(
              height: 250,
              width: double.infinity,
              color: const Color(0xFFF5ECEA),
              child: const Icon(Icons.checkroom, color: _kPrimary, size: 80),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.produk;

    return Scaffold(
      backgroundColor: _kBg,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                backgroundColor: Colors.white,
                elevation: 0.5,
                leading: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8),
                      ],
                    ),
                    child: const Icon(Icons.arrow_back_ios_new, color: _kPrimary, size: 18),
                  ),
                ),
                title: Text(
                  'Detail Produk',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                centerTitle: false,
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildProductImage(p['imageAsset']),
                ),
              ),

              // Konten
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: _kPrimary.withOpacity(0.09),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          p['category'] ?? 'Produk',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _kPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Nama
                      Text(
                        p['name'],
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Harga
                      Text(
                        _rupiah(p['price']),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: _kPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          RichText(
                            text: TextSpan(
                              style: GoogleFonts.plusJakartaSans(fontSize: 13),
                              children: [
                                TextSpan(
                                  text: 'Stok : ',
                                  style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                                ),
                                TextSpan(
                                  text: '${p['stock']}',
                                  style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          Text(
                            'Ukuran',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: _ukuranList.map((uk) {
                                  final sel = _selectedUkuran == uk;
                                  return GestureDetector(
                                    onTap: () => setState(() => _selectedUkuran = uk),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 150),
                                      margin: const EdgeInsets.only(right: 8),
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: sel ? _kPrimary : Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: sel ? _kPrimary : Colors.grey.shade300,
                                        ),
                                      ),
                                      child: Text(
                                        uk,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: sel ? Colors.white : Colors.black87,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),

                      // Deskripsi
                      Text(
                        'Deskripsi',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        p['description'] ?? 'Tidak ada deskripsi untuk produk ini.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          height: 1.65,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Cocok Dipadukan header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.star_border, color: _kPrimary, size: 20),
                              const SizedBox(width: 6),
                              Text(
                                'Cocok Dipadukan',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          Icon(Icons.chevron_right, color: Colors.grey.shade400),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: List.generate(_cocokDipadukan.length, (i) {
                          final prod = _cocokDipadukan[i];
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DetailProduk(produk: prod),
                                ),
                              ),
                              child: Container(
                                margin: EdgeInsets.only(right: i == 0 ? 8 : 0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: Colors.grey.shade200),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.brown.withOpacity(0.06),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                                      child: prod['imageAsset'] != null && prod['imageAsset'].isNotEmpty
                                          ? Image.asset(
                                              prod['imageAsset'],
                                              height: 100,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Container(
                                                  height: 100,
                                                  width: double.infinity,
                                                  color: const Color(0xFFF5ECEA),
                                                  child: const Icon(Icons.checkroom, color: _kPrimary, size: 36),
                                                );
                                              },
                                            )
                                          : Container(
                                              height: 100,
                                              width: double.infinity,
                                              color: const Color(0xFFF5ECEA),
                                              child: const Icon(Icons.checkroom, color: _kPrimary, size: 36),
                                            ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            prod['name'],
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _rupiah(prod['price']),
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: _kPrimary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Tombol WA
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.07),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: (p['stock'] as int) > 0 ? _hubungiWa : null,
                icon: const Icon(Icons.chat, color: Colors.white, size: 20),
                label: Text(
                  'Hubungi via WhatsApp',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  disabledBackgroundColor: Colors.grey.shade300,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}