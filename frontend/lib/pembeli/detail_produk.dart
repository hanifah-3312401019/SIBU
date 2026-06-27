// lib/pembeli/detail_produk.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import '../api/api_base_url.dart';
import 'produk_pembeli.dart';

const _kBg = Color(0xFFF5ECEA);
const _kPrimary = Color(0xFF803033);

class DetailProduk extends StatefulWidget {
  /// Bisa dikirim dari list (data partial) atau hasil fetch detail (data lengkap)
  final Map<String, dynamic> produk;

  const DetailProduk({super.key, required this.produk});

  @override
  State<DetailProduk> createState() => _DetailProdukState();
}

class _DetailProdukState extends State<DetailProduk> {
  // State
  late Map<String, dynamic> _produk;
  bool _isFetchingDetail = false;

  int _currentImage = 0;
  String? _selectedUkuran;
  bool _sizeChartExpanded = false;  // accordion size chart

  // Lifecycle 

  @override
  void initState() {
    super.initState();
    _produk = widget.produk;
    // Fetch detail lengkap (termasuk no_wa penjual) jika belum ada
    if (_produk['no_wa'] == null) {
      _fetchDetail();
    }
  }

  Future<void> _fetchDetail() async {
    final id = _produk['produk_id'];
    if (id == null) return;

    setState(() => _isFetchingDetail = true);

    try {
      final res = await http.get(
        Uri.parse(ApiBaseUrl.produkPublikById(id is int ? id : int.parse(id.toString()))),
        headers: {'Accept': 'application/json'},
      );
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data['success'] == true && mounted) {
          setState(() {
            _produk = Map<String, dynamic>.from(data['data']);
            _isFetchingDetail = false;
          });
        }
      } else {
        if (mounted) setState(() => _isFetchingDetail = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isFetchingDetail = false);
    }
  }

  // Helpers

  String _rupiah(int v) {
    final s = v.toString();
    return 'Rp ${s.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    )}';
  }

  List<String> get _gambarList {
    final raw = ApiBaseUrl.safeList(_produk['gambar_list']);
    final urls = raw
        .map((g) => ApiBaseUrl.getImageUrl(g.toString()))
        .where((u) => u.isNotEmpty)
        .toList();
    if (urls.isEmpty) {
      final single = ApiBaseUrl.getImageUrl(_produk['gambar']);
      if (single.isNotEmpty) return [single];
    }
    return urls.cast<String>();
  }

  List<Map<String, dynamic>> get _ukuranStok {
    final rawValue = _produk['ukuran_stok'];
    debugPrint('=== ukuran_stok raw: $rawValue (type: ${rawValue.runtimeType})');
    List<dynamic> raw = [];
    if (rawValue == null) {
      raw = [];
    } else if (rawValue is List) {
      raw = rawValue;
    } else if (rawValue is String) {
      try {
        final decoded = jsonDecode(rawValue);
        if (decoded is List) raw = decoded;
      } catch (_) {
        raw = [];
      }
    }
    debugPrint('=== ukuran_stok parsed: $raw');
    return raw.map((e) {
      if (e is Map) return Map<String, dynamic>.from(e);
      return <String, dynamic>{};
    }).where((e) => e.isNotEmpty).toList();
  }

  /// No WA penjual – diambil dari detail API; fallback ke nomor default
  String get _noWa {
    final wa = ApiBaseUrl.safeString(_produk['no_wa']);
    if (wa.isNotEmpty) return wa;
    return '6282268155995'; 
  }

  String? get _sizeChartUrl {
    final path = ApiBaseUrl.safeString(_produk['size_chart']);
    if (path.isEmpty) return null;
    return ApiBaseUrl.getSizeChartUrl(path);
  }

  /// FR-16: WhatsApp
  Future<void> _hubungiWa() async {
    final nama = ApiBaseUrl.safeString(_produk['nama_produk']);
    final harga = ApiBaseUrl.safeInt(_produk['harga']);
    final ukuranText =
        _selectedUkuran != null ? '\nUkuran: *$_selectedUkuran*' : '';

    final pesan = Uri.encodeComponent(
      'Halo Kak, saya tertarik dengan produk *$nama* '
      'seharga ${_rupiah(harga)}.$ukuranText '
      'Apakah masih tersedia? 😊',
    );

    final url = Uri.parse('https://wa.me/$_noWa?text=$pesan');

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

  // Build 
  @override
  Widget build(BuildContext context) {
    final gambar = _gambarList;
    final ukuranStok = _ukuranStok;
    final stok = ApiBaseUrl.safeInt(_produk['stok']);

    return Scaffold(
      backgroundColor: _kBg,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // App Bar + Galeri
              SliverAppBar(
                expandedHeight: 320,
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
                        BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8),
                      ],
                    ),
                    child: const Icon(Icons.arrow_back_ios_new,
                        color: _kPrimary, size: 18),
                  ),
                ),
                title: Text(
                  'Detail Produk',
                  style: GoogleFonts.plusJakartaSans(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w700),
                ),
                centerTitle: false,
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildGallery(gambar),
                ),
              ),

              // Konten
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge kategori
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _kPrimary.withOpacity(0.09),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          ApiBaseUrl.safeString(_produk['kategori'],
                              defaultValue: 'Produk'),
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: _kPrimary),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Nama
                      Text(
                        ApiBaseUrl.safeString(_produk['nama_produk']),
                        style: GoogleFonts.playfairDisplay(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                            height: 1.2),
                      ),
                      const SizedBox(height: 8),

                      // Harga + stok
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _rupiah(ApiBaseUrl.safeInt(_produk['harga'])),
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: _kPrimary),
                          ),
                          if (stok == 0)
                            _badge('Habis', Colors.red)
                          else if (stok <=
                              ApiBaseUrl.safeInt(_produk['min_stok'],
                                  defaultValue: 10))
                            _badge('Stok terbatas', Colors.orange)
                          else
                            _badge('Tersedia', Colors.green),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Pilihan Ukuran
                      if (ukuranStok.isNotEmpty) ...[
                        Text(
                          'UKURAN TERSEDIA',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.black54,
                              letterSpacing: 0.5),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: ukuranStok.map((item) {
                            final ukuran =
                                ApiBaseUrl.safeString(item['size'] ?? item['ukuran']);
                            final stokUkuran =
                                ApiBaseUrl.safeInt(item['stock'] ?? item['stok']);
                            final isSelected = _selectedUkuran == ukuran;
                            final habis = stokUkuran == 0;

                            return GestureDetector(
                              onTap: habis
                                  ? null
                                  : () => setState(
                                      () => _selectedUkuran = ukuran),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                width: 44,
                                height: 44,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: habis
                                      ? Colors.grey.shade200
                                      : isSelected
                                          ? _kPrimary
                                          : _kPrimary.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  ukuran,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: habis
                                        ? Colors.grey.shade400
                                        : isSelected
                                            ? Colors.white
                                            : _kPrimary,
                                    decoration: habis
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 22),
                      ],

                      // Deskripsi 
                      Text(
                        'Deskripsi',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        ApiBaseUrl.safeString(_produk['deskripsi'],
                            defaultValue: 'Tidak ada deskripsi.'),
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                            height: 1.65),
                      ),
                      const SizedBox(height: 20),

                      // Size Chart Accordion 
                      if (_sizeChartUrl != null) ...[
                        _buildSizeChartAccordion(),
                        const SizedBox(height: 24),
                      ],

                      // Cocok Dipadukan
                      _buildCocokDipadukan(),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Tombol WA (sticky bottom)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.07),
                      blurRadius: 16,
                      offset: const Offset(0, -4)),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: stok > 0 ? _hubungiWa : null,
                icon: const Icon(Icons.chat, color: Colors.white, size: 20),
                label: Text(
                  'Hubungi via WhatsApp',
                  style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  disabledBackgroundColor: Colors.grey.shade300,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGallery(List<String> gambar) {
    if (gambar.isEmpty) {
      return Container(
        color: const Color(0xFFF5ECEA),
        child: const Center(
            child: Icon(Icons.checkroom, color: _kPrimary, size: 80)),
      );
    }

    return Stack(
      children: [
        PageView.builder(
          itemCount: gambar.length,
          onPageChanged: (i) => setState(() => _currentImage = i),
          itemBuilder: (_, i) => Image.network(
            gambar[i],
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: const Color(0xFFF5ECEA),
              child: const Center(
                  child: Icon(Icons.checkroom, color: _kPrimary, size: 80)),
            ),
          ),
        ),
        if (gambar.length > 1)
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                gambar.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _currentImage == i ? 16 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _currentImage == i
                        ? _kPrimary
                        : Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // Size Chart Accordion 
  Widget _buildSizeChartAccordion() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: _kPrimary.withOpacity(0.25)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Header – tap untuk buka/tutup
          GestureDetector(
            onTap: () =>
                setState(() => _sizeChartExpanded = !_sizeChartExpanded),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: _sizeChartExpanded
                    ? _kPrimary.withOpacity(0.06)
                    : Colors.transparent,
                borderRadius: _sizeChartExpanded
                    ? const BorderRadius.vertical(top: Radius.circular(12))
                    : BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.straighten, color: _kPrimary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Size Chart',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _kPrimary),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _sizeChartExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: const Icon(Icons.keyboard_arrow_down,
                        color: _kPrimary, size: 22),
                  ),
                ],
              ),
            ),
          ),

          // Body – gambar size chart
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: _sizeChartExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Container(
              decoration: BoxDecoration(
                border: Border(
                    top: BorderSide(color: _kPrimary.withOpacity(0.15))),
                borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(12)),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(12)),
                child: Image.network(
                  _sizeChartUrl!,
                  width: double.infinity,
                  fit: BoxFit.contain,
                  loadingBuilder: (_, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      height: 200,
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator(
                          color: _kPrimary, strokeWidth: 2),
                    );
                  },
                  errorBuilder: (_, __, ___) => Container(
                    height: 120,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.broken_image,
                            color: Colors.grey, size: 36),
                        const SizedBox(height: 8),
                        Text(
                          'Gambar size chart tidak tersedia',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Produk Terkait 
  Widget _buildCocokDipadukan() {
    return _ProdukTerkaitSection(
      currentProdukId: _produk['produk_id'],
      kategori: ApiBaseUrl.safeString(_produk['kategori']),
      kategoriId: _produk['kategori_id'],
    );
  }

  // Badge helper
  Widget _badge(String text, Color color) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color),
        ),
      );
}

// Widget Produk Terkait
class _ProdukTerkaitSection extends StatefulWidget {
  final dynamic currentProdukId;
  final String kategori;
  final dynamic kategoriId;

  const _ProdukTerkaitSection({
    required this.currentProdukId,
    required this.kategori,
    this.kategoriId,
  });

  @override
  State<_ProdukTerkaitSection> createState() => _ProdukTerkaitSectionState();
}

class _ProdukTerkaitSectionState extends State<_ProdukTerkaitSection> {
  List<Map<String, dynamic>> _terkait = [];
  bool _loading = true;

  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _fetch() async {
    try {
      // Filter berdasarkan kategori yang sama 
      final uri = Uri.parse(ApiBaseUrl.produkPublik).replace(
        queryParameters: widget.kategoriId != null
            ? {'kategori_id': widget.kategoriId.toString()}
            : {},
      );

      final res = await http.get(uri, headers: {'Accept': 'application/json'});

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data['success'] == true) {
          final all = List<Map<String, dynamic>>.from(data['data']);
          final filtered = all
              .where((p) =>
                  p['produk_id'].toString() !=
                  widget.currentProdukId.toString())
              .take(4)
              .toList();
          if (mounted) {
            setState(() {
              _terkait = filtered;
              _loading = false;
            });
            // Auto-scroll setiap 3 detik 
            if (filtered.length > 2) _startAutoScroll();
          }
        }
      } else {
        if (mounted) setState(() => _loading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _startAutoScroll() {
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      final totalPages = (_terkait.length / 2).ceil();
      final nextPage = (_currentPage + 1) % totalPages;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      _startAutoScroll();
    });
  }

  String _rupiah(int v) {
    final s = v.toString();
    return 'Rp ${s.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    )}';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(),
          const SizedBox(height: 12),
          const Center(
              child:
                  CircularProgressIndicator(color: _kPrimary, strokeWidth: 2)),
          const SizedBox(height: 20),
        ],
      );
    }

    if (_terkait.isEmpty) return const SizedBox.shrink();

    final totalPages = (_terkait.length / 2).ceil();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(),
        const SizedBox(height: 12),

        SizedBox(
          height: 220,
          child: PageView.builder(
            controller: _pageController,
            itemCount: totalPages,
            onPageChanged: (p) => setState(() => _currentPage = p),
            itemBuilder: (ctx, pageIndex) {
              final startIdx = pageIndex * 2;
              final pageItems = _terkait.skip(startIdx).take(2).toList();

              return Row(
                children: List.generate(pageItems.length, (i) {
                  final prod = pageItems[i];
                  final gambarUrl = ApiBaseUrl.getImageUrl(
                      ApiBaseUrl.safeString(prod['gambar']));
                  final namaKategori =
                      ApiBaseUrl.safeString(prod['kategori']);

                  return Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pushReplacement(
                        ctx,
                        MaterialPageRoute(
                            builder: (_) => DetailProduk(produk: prod)),
                      ),
                      child: Container(
                        margin: EdgeInsets.only(right: i == 0 ? 10 : 0),
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
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(16)),
                                  child: gambarUrl.isNotEmpty
                                      ? Image.network(
                                          gambarUrl,
                                          height: 148,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              _imgPlaceholder(),
                                          loadingBuilder:
                                              (_, child, progress) =>
                                                  progress == null
                                                      ? child
                                                      : _imgPlaceholder(),
                                        )
                                      : _imgPlaceholder(),
                                ),

                                if (namaKategori.isNotEmpty)
                                  Positioned(
                                    top: 8,
                                    left: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 7, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.88),
                                        borderRadius:
                                            BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        namaKategori.toUpperCase(),
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 8,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black54,
                                          letterSpacing: 0.4,
                                        ),
                                      ),
                                    ),
                                  ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    width: 26,
                                    height: 26,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color:
                                              Colors.black.withOpacity(0.1),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.arrow_forward,
                                      size: 13,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            // Nama + Harga
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(10, 8, 10, 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ApiBaseUrl.safeString(
                                        prod['nama_produk']),
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    _rupiah(ApiBaseUrl.safeInt(prod['harga'])),
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
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
              );
            },
          ),
        ),

        // Dot indicator 
        if (totalPages > 1) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              totalPages,
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: _currentPage == i ? 16 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: _currentPage == i
                      ? _kPrimary
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _header() => Padding(
        padding: const EdgeInsets.only(bottom: 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.grid_view_rounded,
                    color: _kPrimary, size: 18),
                const SizedBox(width: 6),
                Text(
                  'Produk Terkait',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87),
                ),
                const SizedBox(width: 6),
                if (widget.kategori.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: _kPrimary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      widget.kategori,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: _kPrimary),
                    ),
                  ),
              ],
            ),
          ],
        ),
      );

  Widget _imgPlaceholder() => Container(
        height: 148,
        width: double.infinity,
        color: const Color(0xFFF5ECEA),
        child: const Icon(Icons.checkroom, color: _kPrimary, size: 40),
      );
}