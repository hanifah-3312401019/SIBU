import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_base_url.dart';
import 'riwayat_transaksi_screen.dart';

const _kPrimary2 = Color(0xFF803033);
const _kBg2 = Color(0xFFF5ECEA);

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
  String? _selectedUkuran;
  int _jumlah = 0;
  int _stokTersedia = 0;
  List<Map<String, dynamic>> _keranjang = [];
  String _searchQuery = '';
  bool _isLoading = false;
  List<Map<String, dynamic>> _produkList = [];
  String? _token;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    await _loadToken();
    await _fetchProduk();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
  }

  Future<void> _fetchProduk() async {
    try {
      final response = await http.get(
        Uri.parse(ApiBaseUrl.produk),
        headers: {
          'Authorization': 'Bearer $_token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            _produkList = List<Map<String, dynamic>>.from(data['data']);
          });
        }
      }
    } catch (e) {
      print('Error fetching produk: $e');
    }
  }

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

  void _selectProduk(Map<String, dynamic> produk) {
    setState(() {
      _selectedProduk = produk;
      _selectedUkuran = null;
      _jumlah = 0;
      _stokTersedia = 0;
      _searchQuery = '';
      _searchCtrl.clear();
    });
  }

  void _updateStokTersedia() {
    if (_selectedProduk != null && _selectedUkuran != null) {
      final ukuranStok = _selectedProduk!['ukuran_stok'] as List? ?? [];
      final ukuranItem = ukuranStok.firstWhere(
        (item) => item['size'] == _selectedUkuran,
        orElse: () => null,
      );
      setState(() {
        _stokTersedia = ukuranItem != null ? (ukuranItem['stock'] as int) : 0;
        if (_jumlah > _stokTersedia) {
          _jumlah = _stokTersedia;
        }
      });
    }
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
        (p) => p['nama_produk'].toString().toLowerCase().contains(
          _searchQuery.toLowerCase(),
        ),
      )
      .toList();

  List<String> get _ukuranTersedia {
    if (_selectedProduk == null) return [];
    final ukuranStok = _selectedProduk!['ukuran_stok'] as List? ?? [];
    return ukuranStok.map((item) => item['size'] as String).toList();
  }

  void _tambahKeKeranjang() {
    if (_selectedProduk == null) {
      _snack('Pilih produk dulu');
      return;
    }
    if (_selectedUkuran == null) {
      _snack('Pilih ukuran terlebih dahulu!', Colors.orange);
      return;
    }
    if (_jumlah == 0) {
      _snack('Masukkan jumlah!', Colors.orange);
      return;
    }
    if (_jumlah > _stokTersedia) {
      _snack('Stok tidak cukup (tersisa $_stokTersedia)', Colors.red);
      return;
    }

    setState(() {
      final key = '${_selectedProduk!['produk_id']}_$_selectedUkuran';
      final idx = _keranjang.indexWhere(
        (k) => '${k['produk_id']}_${k['ukuran']}' == key,
      );

      if (idx >= 0) {
        _keranjang[idx]['jumlah'] = (_keranjang[idx]['jumlah'] as int) + _jumlah;
        _keranjang[idx]['subtotal'] = (_keranjang[idx]['jumlah'] as int) * (_keranjang[idx]['harga'] as int);
      } else {
        _keranjang.add({
          'produk_id': _selectedProduk!['produk_id'],
          'nama_produk': _selectedProduk!['nama_produk'],
          'ukuran': _selectedUkuran,
          'harga': _selectedProduk!['harga'],
          'jumlah': _jumlah,
          'stok_tersedia': _stokTersedia,
          'gambar': _selectedProduk!['gambar'],
        });
      }

      _selectedProduk = null;
      _selectedUkuran = null;
      _jumlah = 0;
      _stokTersedia = 0;
      _searchCtrl.clear();
      _searchQuery = '';
    });
  }

  Future<void> _simpan() async {
    if (_keranjang.isEmpty) {
      _snack('Keranjang masih kosong');
      return;
    }

    setState(() => _isLoading = true);

    final items = _keranjang.map((item) => {
      'produk_id': item['produk_id'],
      'ukuran': item['ukuran'],
      'jumlah': item['jumlah'],
    }).toList();

    final int totalTransaksi = _keranjang.fold(0, (sum, item) => sum + (item['harga'] as int) * (item['jumlah'] as int));

    try {
      final response = await http.post(
        Uri.parse(ApiBaseUrl.transaksi),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'items': items}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        setState(() => _keranjang.clear());
        _showSuccessDialog(totalTransaksi);
        setState(() => _isLoading = false);
      } else {
        _snack(data['message'] ?? 'Gagal menyimpan transaksi');
        setState(() => _isLoading = false);
      }
    } catch (e) {
      _snack('Error: ${e.toString()}');
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog(int total) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(color: Color(0xFFE8F5E9), shape: BoxShape.circle),
              child: const Icon(Icons.check_circle, color: Colors.green, size: 44),
            ),
            const SizedBox(height: 14),
            const Text('Transaksi Berhasil!', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Total: ${_rupiah(total)}', style: TextStyle(color: _kPrimary2, fontWeight: FontWeight.w700)),
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

  void _snack(String msg, [Color color = _kPrimary2]) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildProductImage(String? gambar) {
    if (gambar != null && gambar.isNotEmpty) {
      final imageUrl = ApiBaseUrl.getImageUrl(gambar);
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          imageUrl,
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
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.28,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                  colors: [Color(0xFF803033), Color(0xFFD8A5A8), Color(0xFFF5ECEA)],
                ),
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: _navigateBack,
                        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tambah Transaksi', style: GoogleFonts.playfairDisplay(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                          Text('Catat penjualan butik', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.white70)),
                        ],
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
                const SizedBox(height: 3),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: _kPrimary2))
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
                                  ],
                                ),
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('PILIH PRODUK', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: _kPrimary2, letterSpacing: 1)),
                                    const SizedBox(height: 10),
                                    Container(
                                      decoration: BoxDecoration(color: _kBg2, borderRadius: BorderRadius.circular(12)),
                                      child: TextField(
                                        controller: _searchCtrl,
                                        onChanged: (v) => setState(() => _searchQuery = v),
                                        style: GoogleFonts.plusJakartaSans(fontSize: 13),
                                        decoration: InputDecoration(
                                          hintText: 'Cari produk...',
                                          hintStyle: GoogleFonts.plusJakartaSans(color: Colors.grey.shade400, fontSize: 13),
                                          prefixIcon: Icon(Icons.search, color: Colors.grey.shade400, size: 18),
                                          border: InputBorder.none,
                                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                                        ),
                                      ),
                                    ),
                                    if (_searchQuery.isNotEmpty)
                                      Container(
                                        margin: const EdgeInsets.only(top: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: Colors.grey.shade200),
                                        ),
                                        child: Column(
                                          children: _filteredProduk.map((p) {
                                            return ListTile(
                                              dense: true,
                                              leading: _buildProductImage(p['gambar']),
                                              title: Text(p['nama_produk'] as String, style: GoogleFonts.plusJakartaSans(fontSize: 13)),
                                              subtitle: Text(_rupiah(p['harga'] as int), style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.grey.shade500)),
                                              onTap: () => _selectProduk(p),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    if (_selectedProduk != null) ...[
                                      const SizedBox(height: 12),
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: _kPrimary2.withOpacity(0.06),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                _buildProductImage(_selectedProduk!['gambar']),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(_selectedProduk!['nama_produk'] as String, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 13)),
                                                      Text(_rupiah(_selectedProduk!['harga'] as int), style: GoogleFonts.plusJakartaSans(color: _kPrimary2, fontWeight: FontWeight.w700, fontSize: 12)),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 12),
                                            DropdownButtonFormField<String>(
                                              value: _selectedUkuran,
                                              hint: Text('Pilih Ukuran', style: GoogleFonts.plusJakartaSans(fontSize: 12)),
                                              isExpanded: true,
                                              icon: const Icon(Icons.arrow_drop_down, color: _kPrimary2),
                                              decoration: InputDecoration(
                                                filled: true,
                                                fillColor: Colors.white,
                                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                              ),
                                              items: _ukuranTersedia.map((ukuran) {
                                                final ukuranStok = (_selectedProduk!['ukuran_stok'] as List).firstWhere(
                                                  (item) => item['size'] == ukuran,
                                                  orElse: () => null,
                                                );
                                                final stok = ukuranStok != null ? ukuranStok['stock'] : 0;
                                                return DropdownMenuItem(
                                                  value: ukuran,
                                                  child: Text('$ukuran (Stok: $stok)', style: GoogleFonts.plusJakartaSans(fontSize: 13)),
                                                );
                                              }).toList(),
                                              onChanged: (value) {
                                                setState(() {
                                                  _selectedUkuran = value;
                                                  _updateStokTersedia();
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                    if (_selectedUkuran != null) ...[
                                      const SizedBox(height: 12),
                                      Text('JUMLAH', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: _kPrimary2, letterSpacing: 1)),
                                      const SizedBox(height: 8),
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
                                            margin: const EdgeInsets.symmetric(horizontal: 12),
                                            padding: const EdgeInsets.symmetric(vertical: 10),
                                            decoration: BoxDecoration(color: _kBg2, borderRadius: BorderRadius.circular(10)),
                                            child: Text(
                                              '$_jumlah',
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700),
                                            ),
                                          ),
                                          _QtyBtn(
                                            icon: Icons.add,
                                            onTap: () => setState(() {
                                              if (_jumlah < _stokTersedia) _jumlah++;
                                            }),
                                          ),
                                        ],
                                      ),
                                      if (_stokTersedia > 0)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 4),
                                          child: Text('Stok tersedia: $_stokTersedia', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: Colors.grey.shade500)),
                                        ),
                                    ],
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: SizedBox(
                                            height: 40,
                                            child: OutlinedButton(
                                              onPressed: () {
                                                setState(() {
                                                  _selectedProduk = null;
                                                  _selectedUkuran = null;
                                                  _jumlah = 0;
                                                  _stokTersedia = 0;
                                                  _searchCtrl.clear();
                                                  _searchQuery = '';
                                                });
                                              },
                                              style: OutlinedButton.styleFrom(
                                                side: BorderSide(color: Colors.grey.shade300),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                                              ),
                                              child: Text('Batal', style: GoogleFonts.plusJakartaSans(color: Colors.black54, fontWeight: FontWeight.w600, fontSize: 13)),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          flex: 2,
                                          child: SizedBox(
                                            height: 40,
                                            child: ElevatedButton(
                                              onPressed: _tambahKeKeranjang,
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: _kPrimary2,
                                                elevation: 0,
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                                              ),
                                              child: Text('Tambah ke Transaksi', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text('PRODUK YANG DIPILIH:', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.black54, letterSpacing: 1)),
                              const SizedBox(height: 10),
                              ..._keranjang.map(
                                (item) => Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
                                  ),
                                  child: Row(
                                    children: [
                                      _buildProductImage(item['gambar']),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(item['nama_produk'] as String, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 11)),
                                            Text('Ukuran: ${item['ukuran']}', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: Colors.grey.shade700)),
                                            Text('Jumlah: ${item['jumlah']}', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: Colors.grey.shade600)),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(_rupiah(item['harga'] as int), style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w700, color: _kPrimary2)),
                                          Text('Subtotal: ${_rupiah((item['harga'] as int) * (item['jumlah'] as int))}', style: GoogleFonts.plusJakartaSans(fontSize: 10)),
                                        ],
                                      ),
                                      IconButton(
                                        onPressed: () => setState(() => _keranjang.remove(item)),
                                        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                                child: Column(
                                  children: [
                                    _SummaryRow(label: 'Subtotal', value: _rupiah(_subtotal)),
                                    const Divider(height: 20),
                                    _SummaryRow(label: 'Total', value: _rupiah(_subtotal), bold: true, valueColor: _kPrimary2),
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
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton(
                    onPressed: () => setState(() => _keranjang.clear()),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                    ),
                    child: Text('Batal', style: GoogleFonts.plusJakartaSans(color: Colors.black54, fontWeight: FontWeight.w600, fontSize: 13)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: _simpan,
                    icon: const Icon(Icons.check, color: Colors.white, size: 18),
                    label: Text('Simpan Transaksi', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kPrimary2,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                    ),
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
        decoration: BoxDecoration(color: _kBg2, borderRadius: BorderRadius.circular(10)),
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
  const _SummaryRow({required this.label, required this.value, this.bold = false, this.valueColor});

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
