// lib/penjual/tambah_produk_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class TambahProdukScreen extends StatefulWidget {
  final String userName;
  final String userEmail;

  const TambahProdukScreen({
    super.key,
    required this.userName,
    required this.userEmail,
  });

  @override
  State<TambahProdukScreen> createState() => _TambahProdukScreenState();
}

class _TambahProdukScreenState extends State<TambahProdukScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaProdukController = TextEditingController();
  final TextEditingController _hargaController = TextEditingController();
  final TextEditingController _stokController = TextEditingController();
  final TextEditingController _minStokController = TextEditingController();
  
  String _selectedKategori = 'Gamis';
  final List<String> _kategoriList = ['Abaya', 'Gamis', 'Baju Kurung', 'Khimar', 'Bergo'];
  
  List<String> _selectedUkuran = [];
  final List<String> _ukuranList = ['S', 'M', 'L', 'XL', 'XXL'];
  
  // Untuk gambar yang dipilih
  File? _selectedImage;
  String? _imageName;
  bool _isImageSelected = false;
  
  void _toggleUkuran(String ukuran) {
    setState(() {
      if (_selectedUkuran.contains(ukuran)) {
        _selectedUkuran.remove(ukuran);
      } else {
        _selectedUkuran.add(ukuran);
      }
    });
  }
  
  // Fungsi memilih file
  Future<void> _pickImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );
      
      if (result != null) {
        setState(() {
          _selectedImage = File(result.files.single.path!);
          _imageName = result.files.single.name;
          _isImageSelected = true;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gambar "${result.files.single.name}" berhasil dipilih'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak ada gambar yang dipilih'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
  
  void _simpanProduk() {
    if (_formKey.currentState!.validate()) {
      print('Nama Produk: ${_namaProdukController.text}');
      print('Harga: ${_hargaController.text}');
      print('Stok: ${_stokController.text}');
      print('Min Stok: ${_minStokController.text}');
      print('Kategori: $_selectedKategori');
      print('Ukuran: $_selectedUkuran');
      print('Gambar: $_imageName');
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Produk berhasil disimpan!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
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
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5ECEA),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tambah Foto Produk
              Text(
                'Tambah Foto Produk',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              
              // Card upload foto - BISA DIKLIK
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 140,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFD8A5A8),
                      width: 2,
                    ),
                  ),
                  child: _isImageSelected && _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.file(
                                _selectedImage!,
                                fit: BoxFit.cover,
                              ),
                              Container(
                                color: Colors.black.withOpacity(0.4),
                              ),
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.check_circle,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _imageName ?? 'Gambar terpilih',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5ECEA),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.cloud_upload_outlined,
                                size: 32,
                                color: Color(0xFF803033),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Klik untuk pilih gambar',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'JPG/PNG, max 2MB',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Nama Produk
              Text(
                'NAMA PRODUK',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade700,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: _namaProdukController,
                  style: GoogleFonts.plusJakartaSans(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Abaya Maroon Elegan',
                    hintStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: Colors.grey.shade400,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: const Color(0xFF803033).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama produk tidak boleh kosong';
                    }
                    return null;
                  },
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Harga
              Text(
                'HARGA',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade700,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
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
                    prefixStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                    hintText: '387.000',
                    hintStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: Colors.grey.shade400,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: const Color(0xFF803033).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Harga tidak boleh kosong';
                    }
                    return null;
                  },
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Stok dan Min Stok
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'STOK',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            controller: _stokController,
                            keyboardType: TextInputType.number,
                            style: GoogleFonts.plusJakartaSans(fontSize: 14),
                            decoration: InputDecoration(
                              hintText: '42',
                              hintStyle: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                color: Colors.grey.shade400,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: const Color(0xFF803033).withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Stok tidak boleh kosong';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MIN. STOK',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            controller: _minStokController,
                            keyboardType: TextInputType.number,
                            style: GoogleFonts.plusJakartaSans(fontSize: 14),
                            decoration: InputDecoration(
                              hintText: '12',
                              hintStyle: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                color: Colors.grey.shade400,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: const Color(0xFF803033).withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Min. stok tidak boleh kosong';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Kategori
              Text(
                'KATEGORI',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade700,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedKategori,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF803033)),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                    items: _kategoriList.map((kategori) {
                      return DropdownMenuItem(
                        value: kategori,
                        child: Text(kategori),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedKategori = value!;
                      });
                    },
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Ukuran Tersedia
              Text(
                'UKURAN TERSEDIA',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade700,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              
              Wrap(
                spacing: 12,
                runSpacing: 10,
                children: _ukuranList.map((ukuran) {
                  final isSelected = _selectedUkuran.contains(ukuran);
                  return GestureDetector(
                    onTap: () => _toggleUkuran(ukuran),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF803033) : Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF803033)
                              : const Color(0xFFD8A5A8),
                          width: 1,
                        ),
                        boxShadow: [
                          if (isSelected)
                            BoxShadow(
                              color: const Color(0xFF803033).withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                        ],
                      ),
                      child: Text(
                        ukuran,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : Colors.grey.shade700,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 32),
              
              // Tombol Batal dan Simpan
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF803033),
                          side: const BorderSide(color: Color(0xFF803033), width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: Text(
                          'Batal',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                          padding: EdgeInsets.zero,
                        ),
                        child: Text(
                          'Simpan Produk',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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
    _stokController.dispose();
    _minStokController.dispose();
    super.dispose();
  }
}