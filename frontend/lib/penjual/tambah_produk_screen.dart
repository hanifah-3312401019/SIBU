import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_base_url.dart';

class TambahProdukScreen extends StatefulWidget {
  final String userName;
  final String userEmail;

  const TambahProdukScreen({super.key, required this.userName, required this.userEmail});

  @override
  State<TambahProdukScreen> createState() => _TambahProdukScreenState();
}

class _TambahProdukScreenState extends State<TambahProdukScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaProdukController = TextEditingController();
  final TextEditingController _hargaController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();

  String _selectedKategori = 'Gamis';
  final List<String> _kategoriList = ['Abaya', 'Gamis', 'Baju Kurung', 'Khimar', 'Bergo'];

  List<Map<String, dynamic>> _sizeStockList = [];
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _stockPerSizeController = TextEditingController();
  final TextEditingController _minStokController = TextEditingController();

  // Gambar
  File? _selectedImage;
  Uint8List? _selectedImageBytes;
  String? _imageName;
  bool _isImageSelected = false;
  bool _isLoading = false;
  String? _token;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
  }

  void _addSizeStock() {
    String size = _sizeController.text.trim();
    String stockStr = _stockPerSizeController.text.trim();

    if (size.isEmpty) {
      _showSnackbar('Masukkan nama ukuran!', Colors.orange);
      return;
    }
    if (stockStr.isEmpty) {
      _showSnackbar('Masukkan jumlah stok!', Colors.orange);
      return;
    }

    int stock = int.tryParse(stockStr) ?? 0;
    if (stock <= 0) {
      _showSnackbar('Stok harus lebih dari 0!', Colors.orange);
      return;
    }
    if (_sizeStockList.any((item) => item['size'] == size)) {
      _showSnackbar('Ukuran "$size" sudah ada!', Colors.red);
      return;
    }

    setState(() {
      _sizeStockList.add({'size': size, 'stock': stock});
      _sizeController.clear();
      _stockPerSizeController.clear();
    });
  }

  void _removeSizeStock(int index) => setState(() => _sizeStockList.removeAt(index));

  void _updateStock(int index, int newStock) {
    if (newStock > 0) setState(() => _sizeStockList[index]['stock'] = newStock);
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null) {
        final file = result.files.single;

        setState(() {
          _imageName = file.name;
          _isImageSelected = true;

          if (kIsWeb) {
            _selectedImageBytes = file.bytes;
            _selectedImage = null;
          } else {
            _selectedImage = File(file.path!);
            _selectedImageBytes = null;
          }
        });

        _showSnackbar('Gambar "${file.name}" berhasil dipilih', Colors.green);
      }
    } catch (e) {
      _showSnackbar('Error: ${e.toString()}', Colors.red);
    }
  }

  Future<void> _simpanProduk() async {
    if (!_formKey.currentState!.validate()) return;
    if (_sizeStockList.isEmpty) {
      _showSnackbar('Tambahkan minimal 1 ukuran dan stok!', Colors.orange);
      return;
    }
    if (_token == null) {
      _showSnackbar('Token tidak ditemukan, silakan login ulang', Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    var request = http.MultipartRequest('POST', Uri.parse(ApiBaseUrl.produk));
    request.headers['Authorization'] = 'Bearer $_token';
    request.headers['Accept'] = 'application/json';

    request.fields['nama_produk'] = _namaProdukController.text;
    request.fields['harga'] = _hargaController.text.replaceAll('.', '');
    request.fields['kategori'] = _selectedKategori;
    request.fields['min_stok'] = _minStokController.text;
    request.fields['ukuran_stok'] = jsonEncode(_sizeStockList);
    request.fields['deskripsi'] = _deskripsiController.text;
    request.fields['stok'] = _sizeStockList.fold(0, (sum, item) => sum + (item['stock'] as int)).toString();
    request.fields['min_stok'] = '10';

    // Upload gambar
    if (_isImageSelected) {
      if (kIsWeb && _selectedImageBytes != null) {
        final multipartFile = http.MultipartFile.fromBytes(
          'gambar',
          _selectedImageBytes!,
          filename: _imageName,
        );
        request.files.add(await multipartFile);
      } else if (_selectedImage != null) {
        request.files.add(await http.MultipartFile.fromPath('gambar', _selectedImage!.path));
      }
    }

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final data = jsonDecode(responseBody);

      if (response.statusCode == 201) {
        _showSnackbar('Produk berhasil disimpan!', Colors.green);
        Navigator.pop(context, true);
      } else {
        _showSnackbar(data['message'] ?? 'Gagal menyimpan produk', Colors.red);
        setState(() => _isLoading = false);
      }
    } catch (e) {
      _showSnackbar('Error: ${e.toString()}', Colors.red);
      setState(() => _isLoading = false);
    }
  }

  String formatPrice(String value) {
    if (value.isEmpty) return '';
    final number = int.tryParse(value.replaceAll('.', '')) ?? 0;
    return number.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
  }

  Widget _buildPreviewImage() {
    if (!_isImageSelected) return _buildUploadPlaceholder();

    if (kIsWeb && _selectedImageBytes != null) {
      return Image.memory(
        _selectedImageBytes!,
        width: double.infinity,
        height: 140,
        fit: BoxFit.cover,
      );
    } else if (_selectedImage != null) {
      return Image.file(
        _selectedImage!,
        width: double.infinity,
        height: 140,
        fit: BoxFit.cover,
      );
    }
    return _buildUploadPlaceholder();
  }

  Widget _buildUploadPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: const Color(0xFFF5ECEA), shape: BoxShape.circle),
          child: const Icon(Icons.cloud_upload_outlined, size: 32, color: Color(0xFF803033)),
        ),
        const SizedBox(height: 12),
        Text('Klik untuk pilih gambar', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey.shade600)),
        const SizedBox(height: 4),
        Text('JPG/PNG, max 2MB', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.grey.shade500)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5ECEA),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(95),
        child: Container(
          color: Colors.white,
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Color(0xFF803033)),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Tambah Produk',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF803033),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
                  child: Text(
                    'Lengkap detail produk',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF803033)))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tambah Foto Produk', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: double.infinity,
                        height: 140,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFD8A5A8), width: 2),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              _buildPreviewImage(),
                              if (_isImageSelected) Container(color: Colors.black.withOpacity(0.4)),
                              if (_isImageSelected)
                                Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.check_circle, color: Colors.white, size: 32),
                                      const SizedBox(height: 8),
                                      Text(
                                        _imageName ?? 'Gambar terpilih',
                                        style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text('NAMA PRODUK', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.grey.shade700)),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                      child: TextFormField(
                        controller: _namaProdukController,
                        style: GoogleFonts.plusJakartaSans(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Abaya Maroon Elegan',
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                        validator: (v) => (v == null || v.isEmpty) ? 'Nama produk tidak boleh kosong' : null,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('HARGA', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.grey.shade700)),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                      child: TextFormField(
                        controller: _hargaController,
                        keyboardType: TextInputType.number,
                        style: GoogleFonts.plusJakartaSans(fontSize: 14),
                        onChanged: (value) {
                          final formatted = formatPrice(value);
                          if (formatted != value) {
                            _hargaController.value = TextEditingValue(
                              text: formatted,
                              selection: TextSelection.collapsed(offset: formatted.length),
                            );
                          }
                        },
                        decoration: InputDecoration(
                          prefixText: 'Rp ',
                          hintText: '387.000',
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                        validator: (v) => (v == null || v.isEmpty) ? 'Harga tidak boleh kosong' : null,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('KATEGORI', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.grey.shade700)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedKategori,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF803033)),
                          style: GoogleFonts.plusJakartaSans(fontSize: 14, color: Colors.black87),
                          items: _kategoriList.map((k) => DropdownMenuItem(value: k, child: Text(k))).toList(),
                          onChanged: (v) => setState(() => _selectedKategori = v!),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('MIN. STOK', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.grey.shade700)),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                      child: TextFormField(
                        controller: _minStokController,
                        keyboardType: TextInputType.number,
                        style: GoogleFonts.plusJakartaSans(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: '10',
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                        validator: (v) => (v == null || v.isEmpty) ? 'Min. stok tidak boleh kosong' : null,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('DESKRIPSI', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.grey.shade700)),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                      child: TextFormField(
                        controller: _deskripsiController,
                        maxLines: 4,
                        style: GoogleFonts.plusJakartaSans(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Deskripsi produk...',
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                        validator: (v) => null, // Deskripsi boleh kosong
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5ECEA),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFD8A5A8), width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.label_outline, color: Color(0xFF803033), size: 20),
                              const SizedBox(width: 8),
                              Text('UKURAN & STOK', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF803033))),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: TextField(
                                  controller: _sizeController,
                                  decoration: InputDecoration(
                                    hintText: 'Ukuran (S, M, L, XL)',
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 1,
                                child: TextField(
                                  controller: _stockPerSizeController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: 'Stok',
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                decoration: BoxDecoration(color: const Color(0xFF803033), borderRadius: BorderRadius.circular(10)),
                                child: IconButton(
                                  icon: const Icon(Icons.add, color: Colors.white, size: 20),
                                  onPressed: _addSizeStock,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (_sizeStockList.isNotEmpty) ...[
                            const Divider(),
                            const SizedBox(height: 8),
                            Text('Daftar Ukuran & Stok:', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
                            const SizedBox(height: 8),
                            ..._sizeStockList.asMap().entries.map((entry) {
                              int index = entry.key;
                              var item = entry.value;
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFFD8A5A8), width: 1),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(flex: 2, child: Text('Ukuran: ${item['size']}', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600))),
                                    Expanded(
                                      flex: 1,
                                      child: Row(
                                        children: [
                                          const Icon(Icons.inventory_2_outlined, size: 14, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: TextFormField(
                                              initialValue: item['stock'].toString(),
                                              keyboardType: TextInputType.number,
                                              style: GoogleFonts.plusJakartaSans(fontSize: 13),
                                              decoration: const InputDecoration(
                                                isDense: true,
                                                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                                              ),
                                              onFieldSubmitted: (value) {
                                                int newStock = int.tryParse(value) ?? 0;
                                                if (newStock > 0) _updateStock(index, newStock);
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                                      onPressed: () => _removeSizeStock(index),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (_sizeStockList.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: const Color(0xFF803033).withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total Stok:', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600)),
                            Text(
                              '${_sizeStockList.fold(0, (s, i) => s + (i['stock'] as int))} pcs',
                              style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF803033)),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFF803033), width: 1.5),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text('Batal', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF803033))),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _simpanProduk,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF803033),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                              child: Text('Simpan Produk', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _namaProdukController.dispose();
    _hargaController.dispose();
    _deskripsiController.dispose();
    _sizeController.dispose();
    _stockPerSizeController.dispose();
    super.dispose();
  }
}
