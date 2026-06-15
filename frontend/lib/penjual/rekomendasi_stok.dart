// lib/penjual/rekomendasi_stok.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/sidebar_penjual.dart';
import 'manajemen_periode_screen.dart';
import '../api/api_base_url.dart';

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
  final List<int> _hariCoverOptions = [7, 21, 30];

  List<Map<String, dynamic>> _items = [];
  bool _isLoading = true;
  String? _token;

  String? _selectedPeriodeId;
  Map<String, dynamic>? _selectedPeriodeData;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _loadToken();
    await _loadSelectedPeriode();
    _fetchRekomendasi();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
  }

  Future<void> _loadSelectedPeriode() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedPeriodeId = prefs.getString('selected_periode_id');

    if (_selectedPeriodeId != null && _selectedPeriodeId!.isNotEmpty) {
      await _fetchPeriodeDetail(_selectedPeriodeId!);
    } else {
    setState(() {
      _selectedPeriodeData = null;
    });
  }
  }

  Future<void> _fetchPeriodeDetail(String periodeId) async {
    try {
      final response = await http.get(
        Uri.parse(ApiBaseUrl.periodeById(int.parse(periodeId))),
        headers: {
          'Authorization': 'Bearer $_token',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() => _selectedPeriodeData = data['data']);
        }
      }
    } catch (e) {
      debugPrint('Error fetch periode detail: $e');
    }
  }

  Future<void> _fetchRekomendasi() async {
    setState(() => _isLoading = true);
    try {
      final int hariCover = _hariCoverOptions[_periodeIdx];
      String url = '${ApiBaseUrl.rekomendasiStok}?hari_cover=$hariCover';
      if (_selectedPeriodeId != null && _selectedPeriodeId!.isNotEmpty) {
        url += '&periode_id=$_selectedPeriodeId';
      }
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $_token',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final allItems = List<Map<String, dynamic>>.from(data['data']);
          final filteredItems = allItems.where((item) {
            final status = item['status'] as String;
            final saran = item['saranTambah'] as int;
            return saran > 0 || status == 'sudah_dipesan';
          }).toList();
          setState(() {
            _items = filteredItems;
            _isLoading = false;
          });
        } else {
          setState(() { _items = []; _isLoading = false; });
        }
      } else {
        setState(() { _items = []; _isLoading = false; });
      }
    } catch (e) {
      debugPrint('Error fetch rekomendasi: $e');
      setState(() { _items = []; _isLoading = false; });
    }
  }

  void _navigateToManajemenPeriode() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ManajemenPeriodeScreen(
          userName: widget.userName ?? 'Penjual',
          userEmail: widget.userEmail ?? '',
        ),
      ),
    );
    await _loadSelectedPeriode();
    _fetchRekomendasi();

    setState(() {});
  }

  void _clearPeriode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('selected_periode_id');
    setState(() {
      _selectedPeriodeId = null;
      _selectedPeriodeData = null;
    });
    _fetchRekomendasi();
    _snack('Periode dinonaktifkan');
  }

  String _formatTanggal(String? isoDate) {
  if (isoDate == null || isoDate.isEmpty) return '';
  
  try {
    final date = DateTime.parse(isoDate).toLocal();
    
    const days = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 
                  'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    
    return '${date.day} ${days[date.month - 1]} ${date.year}';
  } catch (e) {
    return isoDate.split('T')[0];
  }
}

  void _showRestockSheet(Map<String, dynamic> item) {
    final int produkId = item['id'] as int;
    final int saranTambah = item['saranTambah'] as int;
    final int hariCover = _hariCoverOptions[_periodeIdx];
    final int stokSekarang = item['stok'] as int;
    final double rataHari = (item['rataHari'] as num).toDouble();

    List<Map<String, dynamic>> ukuranList = [];
    final rawUkuran = item['ukuran_stok'];
    if (rawUkuran != null) {
      if (rawUkuran is List) {
        ukuranList = rawUkuran
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      } else if (rawUkuran is String && rawUkuran.isNotEmpty) {
        try {
          final decoded = json.decode(rawUkuran);
          if (decoded is List) {
            ukuranList = decoded
                .map((e) => Map<String, dynamic>.from(e as Map))
                .toList();
          }
        } catch (_) {}
      }
    }

    final bool hasUkuran = ukuranList.isNotEmpty;

    Map<String, TextEditingController> ukuranControllers = {};
    Map<String, int> ukuranJumlah = {};

    if (hasUkuran) {
      final int perUkuran = ukuranList.isNotEmpty
          ? (saranTambah / ukuranList.length).floor()
          : 0;
      int sisa = saranTambah - (perUkuran * ukuranList.length);
      for (int i = 0; i < ukuranList.length; i++) {
        final size = ukuranList[i]['size'].toString();
        final val = i == 0 ? perUkuran + sisa : perUkuran;
        ukuranJumlah[size] = val > 0 ? val : 0;
        ukuranControllers[size] =
            TextEditingController(text: '${ukuranJumlah[size]}');
      }
    }

    int jumlahTotal = saranTambah > 0 ? saranTambah : 1;
    final TextEditingController _qtyController =
        TextEditingController(text: '$jumlahTotal');

    int _hitungTotal(Map<String, int> map) =>
        map.values.fold(0, (a, b) => a + b);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheet) {
          final int totalJumlah = hasUkuran
              ? _hitungTotal(ukuranJumlah)
              : jumlahTotal;

          return Padding(
            padding: EdgeInsets.only(
              left: 20, right: 20, top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildProdukThumb(item, size: 48),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['nama'] as String,
                              style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w700, fontSize: 14),
                            ),
                            Text(
                              'Stok saat ini: $stokSekarang pcs',
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12, color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                      ),
                      _BadgeChip(label: item['badge'] as String),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: _kBg6, borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dasar Perhitungan Sistem',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: _kPrimary6),
                        ),
                        const SizedBox(height: 6),
                        _buildCalcRow(
                            'Rata² penjualan',
                            '${rataHari.toStringAsFixed(1)} pcs/hari'),
                        _buildCalcRow('Hari cover', '$hariCover hari'),
                        _buildCalcRow(
                          'Kebutuhan stok',
                          '${rataHari.toStringAsFixed(1)} × $hariCover = '
                              '${(rataHari * hariCover).toStringAsFixed(0)} pcs',
                        ),
                        _buildCalcRow('Stok saat ini', '$stokSekarang pcs'),
                        const Divider(height: 12),
                        _buildCalcRow('Saran tambah', '+$saranTambah pcs',
                            highlight: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Input jumlah
                  Text(
                    hasUkuran
                        ? 'Jumlah Tambah per Ukuran'
                        : 'Jumlah Tambah Stok',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hasUkuran
                        ? 'Distribusikan jumlah sesuai kebutuhan tiap ukuran.'
                        : 'Anda bisa mengubah jumlah sesuai kebutuhan.',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                        fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 10),

                  if (hasUkuran) ...[
                    ...ukuranList.map((uk) {
                      final size = uk['size'].toString();
                      final stokUkuran = uk['stock'] as int? ?? 0;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Container(
                              width: 56,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 6, horizontal: 10),
                              decoration: BoxDecoration(
                                color: _kPrimary6.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    size,
                                    style: GoogleFonts.plusJakartaSans(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                        color: _kPrimary6),
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    '$stokUkuran',
                                    style: GoogleFonts.plusJakartaSans(
                                        fontSize: 9,
                                        color: Colors.grey.shade500),
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    'stok',
                                    style: GoogleFonts.plusJakartaSans(
                                        fontSize: 9,
                                        color: Colors.grey.shade400),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Tombol 
                            _RestockQtyBtn(
                              icon: Icons.remove,
                              onTap: () {
                                if ((ukuranJumlah[size] ?? 0) > 0) {
                                  setSheet(() {
                                    ukuranJumlah[size] =
                                        (ukuranJumlah[size]! - 1);
                                    ukuranControllers[size]!.text =
                                        '${ukuranJumlah[size]}';
                                  });
                                }
                              },
                            ),
                            // Input angka
                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 8),
                                child: TextField(
                                  controller: ukuranControllers[size],
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.plusJakartaSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700),
                                  decoration: InputDecoration(
                                    contentPadding:
                                        const EdgeInsets.symmetric(
                                            vertical: 10),
                                    filled: true,
                                    fillColor: _kBg6,
                                    border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(10),
                                      borderSide: BorderSide.none,
                                    ),
                                    suffixText: 'pcs',
                                    suffixStyle:
                                        GoogleFonts.plusJakartaSans(
                                            fontSize: 12,
                                            color: Colors.grey),
                                  ),
                                  onChanged: (val) {
                                    final parsed = int.tryParse(val);
                                    if (parsed != null && parsed >= 0) {
                                      setSheet(
                                          () => ukuranJumlah[size] = parsed);
                                    }
                                  },
                                ),
                              ),
                            ),
                            _RestockQtyBtn(
                              icon: Icons.add,
                              onTap: () => setSheet(() {
                                ukuranJumlah[size] =
                                    (ukuranJumlah[size] ?? 0) + 1;
                                ukuranControllers[size]!.text =
                                    '${ukuranJumlah[size]}';
                              }),
                            ),
                          ],
                        ),
                      );
                    }),
                    // Total semua ukuran
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: _kPrimary6.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: _kPrimary6.withOpacity(0.2)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total semua ukuran:',
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: _kPrimary6,
                                fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '${_hitungTotal(ukuranJumlah)} pcs',
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: _kPrimary6),
                          ),
                        ],
                      ),
                    ),
                  ]
                  else ...[
                    Row(
                      children: [
                        _RestockQtyBtn(
                          icon: Icons.remove,
                          onTap: () {
                            if (jumlahTotal > 1) {
                              setSheet(() {
                                jumlahTotal--;
                                _qtyController.text = '$jumlahTotal';
                              });
                            }
                          },
                        ),
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 12),
                            child: TextField(
                              controller: _qtyController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700),
                              decoration: InputDecoration(
                                contentPadding:
                                    const EdgeInsets.symmetric(
                                        vertical: 12),
                                filled: true,
                                fillColor: _kBg6,
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                suffixText: 'pcs',
                                suffixStyle:
                                    GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        color: Colors.grey),
                              ),
                              onChanged: (val) {
                                final parsed = int.tryParse(val);
                                if (parsed != null && parsed > 0) {
                                  setSheet(() => jumlahTotal = parsed);
                                }
                              },
                            ),
                          ),
                        ),
                        _RestockQtyBtn(
                          icon: Icons.add,
                          onTap: () => setSheet(() {
                            jumlahTotal++;
                            _qtyController.text = '$jumlahTotal';
                          }),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 12),

                  // Preview stok setelah restock
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: _kBg6,
                        borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Stok setelah restock:',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: Colors.grey.shade600),
                        ),
                        Text(
                          '$stokSekarang + $totalJumlah = ${stokSekarang + totalJumlah} pcs',
                          style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tombol aksi
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text('Batal',
                              style: GoogleFonts.plusJakartaSans(
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _kPrimary6,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () async {
                            int finalTotal;
                            Map<String, int>? finalPerUkuran;

                            if (hasUkuran) {
                              for (final uk in ukuranList) {
                                final size = uk['size'].toString();
                                final parsed = int.tryParse(
                                    ukuranControllers[size]!.text);
                                if (parsed != null && parsed >= 0) {
                                  ukuranJumlah[size] = parsed;
                                }
                              }
                              finalTotal = _hitungTotal(ukuranJumlah);
                              finalPerUkuran =
                                  Map<String, int>.from(ukuranJumlah);
                            } else {
                              finalTotal =
                                  int.tryParse(_qtyController.text) ??
                                      jumlahTotal;
                              if (finalTotal <= 0) finalTotal = 1;
                            }

                            if (finalTotal == 0) {
                              _snack('Jumlah tidak boleh 0');
                              return;
                            }

                            Navigator.pop(ctx);
                            setState(() {
                              item['status'] = 'sudah_dipesan';
                              item['jumlah_dipesan'] = finalTotal;
                              if (finalPerUkuran != null) {
                                item['jumlah_per_ukuran'] = finalPerUkuran;
                              }
                            });

                            try {
                              final body = {
                                'produk_id': produkId,
                                'jumlah': finalTotal,
                                if (finalPerUkuran != null)
                                  'jumlah_per_ukuran': finalPerUkuran
                                      .entries
                                      .map((e) => {
                                            'size': e.key,
                                            'jumlah': e.value
                                          })
                                      .toList(),
                              };
                              final response = await http.post(
                                Uri.parse(ApiBaseUrl.restock),
                                headers: {
                                  'Authorization': 'Bearer $_token',
                                  'Content-Type': 'application/json',
                                },
                                body: json.encode(body),
                              );
                              if (response.statusCode == 200) {
                                _snack(
                                    'Restock ${item['nama']} ($finalTotal pcs) berhasil dicatat');
                                _fetchRekomendasi();
                              } else {
                                _snack('Gagal mencatat restock');
                              }
                            } catch (e) {
                              _snack('Error: ${e.toString()}');
                            }
                          },
                          child: Text('Pesan Restock',
                              style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.info_outline,
                          size: 13, color: _kGold),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Stok akan bertambah setelah barang tiba dan Anda konfirmasi.',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              color: Colors.grey.shade500,
                              height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // KONFIRMASI TIBA 
  void _showKonfirmasiTibaSheet(Map<String, dynamic> item) {
    final int produkId = item['id'] as int;
    final int jumlahDipesan =
        (item['jumlah_dipesan'] as num?)?.toInt() ?? 0;
    final int stokSekarang = item['stok'] as int;

    Map<String, int>? perUkuran;
    if (item['jumlah_per_ukuran'] != null) {
      perUkuran = Map<String, int>.from(
          (item['jumlah_per_ukuran'] as Map)
              .map((k, v) => MapEntry(k.toString(), (v as num).toInt())));
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                _buildProdukThumb(item, size: 48),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['nama'] as String,
                        style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                      Text(
                        'Stok saat ini: $stokSekarang pcs',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 12, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
                _BadgeChip(label: item['badge'] as String),
              ],
            ),
            const SizedBox(height: 16),

            Text(
              'Konfirmasi Barang Tiba',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'Pastikan barang sudah benar-benar tiba sebelum konfirmasi. Stok akan langsung bertambah.',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                  height: 1.4),
            ),
            const SizedBox(height: 12),

            // Ringkasan stok
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: _kBg6, borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  _buildCalcRow('Stok sebelumnya',
                      '$stokSekarang pcs'),
                  if (perUkuran != null) ...[
                    const Divider(height: 14),
                    Text(
                      'Rincian per ukuran:',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    ...perUkuran.entries.map(
                      (e) => _buildCalcRow(
                          '  Ukuran ${e.key}', '+${e.value} pcs'),
                    ),
                    const Divider(height: 14),
                  ],
                  _buildCalcRow(
                      'Total barang tiba', '+$jumlahDipesan pcs'),
                  const Divider(height: 12),
                  _buildCalcRow(
                    'Stok setelah konfirmasi',
                    '${stokSekarang + jumlahDipesan} pcs',
                    highlight: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Tombol aksi
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      padding:
                          const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text('Batal',
                        style: GoogleFonts.plusJakartaSans(
                            color: Colors.black54,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kPrimary6,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      padding:
                          const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () async {
                      Navigator.pop(context);

                      setState(() => _isLoading = true);
                      try {
                        final response = await http.post(
                          Uri.parse(ApiBaseUrl.konfirmasiTiba),
                          headers: {
                            'Authorization': 'Bearer $_token',
                            'Content-Type': 'application/json',
                          },
                          body: json.encode({
                            'produk_id': produkId,
                            'jumlah': jumlahDipesan,
                          }),
                        );
                        if (response.statusCode == 200) {
                          _snack(
                              'Stok ${item['nama']} bertambah $jumlahDipesan pcs!');
                          await _fetchRekomendasi();
                        } else {
                          _snack('Gagal mengupdate stok');
                          setState(() => _isLoading = false);
                        }
                      } catch (e) {
                        _snack('Error: ${e.toString()}');
                        setState(() => _isLoading = false);
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle_outline,
                            color: Colors.white, size: 18),
                        const SizedBox(width: 6),
                        Text('Konfirmasi Tiba',
                            style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.warning_amber_outlined,
                    size: 13, color: _kGold),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Tindakan ini akan langsung menambah stok di database dan tidak bisa dibatalkan.',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                        height: 1.4),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // thumbnail produk
  Widget _buildProdukThumb(Map<String, dynamic> item, {double size = 48}) {
    final g = item['gambar'];
    final url = (g != null && g.toString().isNotEmpty)
        ? ApiBaseUrl.getImageUrl(g.toString())
        : '';
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: url.isNotEmpty
          ? Image.network(url,
              width: size, height: size, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _thumbFallback(size))
          : _thumbFallback(size),
    );
  }

  Widget _thumbFallback(double size) => Container(
        width: size,
        height: size,
        color: _kPrimary6.withOpacity(0.1),
        child: const Icon(Icons.checkroom, color: _kPrimary6, size: 22),
      );

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

  Widget _buildCalcRow(String label, String value,
      {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: highlight ? _kPrimary6 : Colors.grey.shade600,
                fontWeight:
                    highlight ? FontWeight.w700 : FontWeight.normal,
              )),
          Text(value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: highlight ? _kPrimary6 : Colors.black87,
                fontWeight: FontWeight.w700,
              )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int hariCover = _hariCoverOptions[_periodeIdx];

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: _kBg6,
      drawer: SidebarWidget(
        userName: widget.userName ?? 'Penjual',
        userEmail: widget.userEmail ?? '',
        selectedIndex: 5,
        onItemSelected: (index) => Navigator.pop(context),
      ),
      body: Stack(
        children: [
          Container(color: _kBg6),
          Positioned(
            top: 0, left: 0, right: 0,
            height: MediaQuery.of(context).size.height * 0.28,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                  colors: [Color(0xFF803033), Color(0xFFD8A5A8), Color(0xFFF5ECEA)],
                ),
                borderRadius: BorderRadius.only(
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
                      horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () =>
                            _scaffoldKey.currentState?.openDrawer(),
                        icon: const Icon(Icons.menu,
                            color: Colors.white, size: 24),
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
                            color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Rekomendasi pengadaan stok',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 13, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: _kPrimary6))
                      : SingleChildScrollView(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            children: [
                              // Card periode aktif
                              GestureDetector(
                                onTap: _navigateToManajemenPeriode,
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: _selectedPeriodeData != null
                                        ? _kPrimary6
                                        : Colors.white,
                                    borderRadius:
                                        BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black
                                              .withOpacity(0.08),
                                          blurRadius: 8)
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: _selectedPeriodeData !=
                                                  null
                                              ? Colors.white
                                                  .withOpacity(0.2)
                                              : _kPrimary6
                                                  .withOpacity(0.08),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Icon(Icons.calendar_month,
                                            color: _selectedPeriodeData !=
                                                    null
                                                ? Colors.white
                                                : _kPrimary6,
                                            size: 20),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Periode Aktif',
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                fontSize: 10,
                                                color: _selectedPeriodeData !=
                                                        null
                                                    ? Colors.white70
                                                    : Colors.grey.shade500,
                                              ),
                                            ),
                                            Text(
                                              _selectedPeriodeData != null
                                                  ? (_selectedPeriodeData![
                                                          'nama_periode'] ??
                                                      'Periode Khusus')
                                                  : 'Tidak Aktif',
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 14,
                                                color: _selectedPeriodeData !=
                                                        null
                                                    ? Colors.white
                                                    : Colors.black87,
                                              ),
                                            ),
                                            if (_selectedPeriodeData != null)
                                            Text(
                                              '${_formatTanggal(_selectedPeriodeData!['tanggal_mulai'])} → ${_formatTanggal(_selectedPeriodeData!['tanggal_selesai'])} | Rekomendasi disesuaikan',
                                              style: GoogleFonts.plusJakartaSans(
                                                  fontSize: 10,
                                                  color: Colors.white70),
                                            )
                                            else
                                              Text(
                                                'Klik untuk mengatur periode',
                                                style:
                                                    GoogleFonts.plusJakartaSans(
                                                        fontSize: 10,
                                                        color: Colors
                                                            .grey.shade400),
                                              ),
                                          ],
                                        ),
                                      ),
                                      Icon(Icons.chevron_right,
                                          color: _selectedPeriodeData != null
                                              ? Colors.white
                                              : Colors.grey),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),

                              Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.circular(14)),
                                child: Row(
                                  children:
                                      List.generate(_periodeLabel.length,
                                          (i) {
                                    final sel = _periodeIdx == i;
                                    return Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(
                                              () => _periodeIdx = i);
                                          _fetchRekomendasi();
                                        },
                                        child: AnimatedContainer(
                                          duration: const Duration(
                                              milliseconds: 200),
                                          padding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 10),
                                          decoration: BoxDecoration(
                                            color: sel
                                                ? _kPrimary6
                                                : Colors.transparent,
                                            borderRadius:
                                                BorderRadius.circular(
                                                    14),
                                          ),
                                          child: Text(
                                            _periodeLabel[i],
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts
                                                .plusJakartaSans(
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

                              // ── Keterangan rumus
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: _kPrimary6.withOpacity(0.15)),
                                ),
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.lightbulb_outline,
                                        color: _kGold, size: 16),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _selectedPeriodeData != null
                                            ? 'Saran dihitung dari transaksi selama periode "${_selectedPeriodeData!['nama_periode']}" ÷ jumlah hari periode × $hariCover hari cover.'
                                            : 'Saran dihitung dari transaksi $hariCover hari terakhir ÷ $hariCover × $hariCover hari cover (data normal, tanpa periode khusus).',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11,
                                          color: Colors.grey.shade600,
                                          height: 1.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 14),

                              // Daftar produk
                              if (_items.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 40),
                                  child: Center(
                                    child: Column(
                                      children: [
                                        Icon(Icons.inventory_2_outlined,
                                            size: 48,
                                            color: Colors.grey.shade400),
                                        const SizedBox(height: 12),
                                        Text(
                                          'Tidak ada produk yang perlu direstock',
                                          style: GoogleFonts.plusJakartaSans(
                                              color: Colors.grey.shade500),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              else
                                ..._items.map((item) {
                                  final status = item['status'] as String;

                                  return Container(
                                    margin:
                                        const EdgeInsets.only(bottom: 14),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius:
                                          BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black
                                              .withOpacity(0.05),
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
                                            // Header produk
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Row(
                                                    children: [
                                                      _buildProdukThumb(item, size: 48),
                                                      const SizedBox(width: 10),
                                                      Expanded(
                                                        child: Text(
                                                          item['nama'] as String,
                                                          style: GoogleFonts.plusJakartaSans(
                                                              fontWeight: FontWeight.w700, fontSize: 14),
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                _BadgeChip(label: item['badge'] as String),
                                              ],
                                            ),
                                            const SizedBox(height: 10),

                                            // Info chip stok, rata², saran
                                            Row(
                                              children: [
                                                Expanded(child: _InfoChip(label: 'Stok', value: '${item['stok']}')),
                                                const SizedBox(width: 8),
                                                Expanded(child: _InfoChip(label: 'Rata²', value: '${item['rataHari']}/hari')),
                                                const SizedBox(width: 8),
                                                Expanded(child: _InfoChip(label: 'Saran', value: '+${item['saranTambah']} pcs')),
                                              ],
                                            ),
                                            const SizedBox(height: 12),

                                            // Tombol status
                                            _buildStatusBtn(item, status),
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

  Widget _buildStatusBtn(Map<String, dynamic> item, String status) {
    switch (status) {
      case 'sudah_dipesan':
        return GestureDetector(
          onTap: () => _showKonfirmasiTibaSheet(item),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3DC),
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: _kGold.withOpacity(0.4)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🟡', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
                Column(
                  children: [
                    Text(
                      'Sudah Dipesan (barang belum tiba)',
                      style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFFCC7000),
                          fontWeight: FontWeight.w700,
                          fontSize: 12),
                    ),
                    Text(
                      'Tap untuk konfirmasi tiba →',
                      style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFFCC7000),
                          fontSize: 10),
                    ),
                  ],
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
            border: Border.all(
                color: const Color(0xFF629D3E).withOpacity(0.4)),
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
                    fontSize: 13),
              ),
            ],
          ),
        );

      default:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _showRestockSheet(item),
            style: ElevatedButton.styleFrom(
              backgroundColor: _kPrimary6,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('🔴', style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
                Text(
                  'Restock Sekarang',
                  style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        );
    }
  }
}

// Widget helpers 
class _BadgeChip extends StatelessWidget {
  final String label;
  const _BadgeChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: const Color(0xFF803033).withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_offer_outlined,
              size: 11, color: Color(0xFF803033)),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: const Color(0xFF803033),
                fontWeight: FontWeight.w600),
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
        Text(label,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 10, color: Colors.grey.shade500)),
        Text(value,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 13, fontWeight: FontWeight.w700)),
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
          color: const Color(0xFFF5ECEA),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: const Color(0xFF803033), size: 20),
      ),
    );
  }
}