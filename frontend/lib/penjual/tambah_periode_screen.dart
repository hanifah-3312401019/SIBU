// lib/penjual/tambah_periode_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_base_url.dart';

class TambahPeriodeScreen extends StatefulWidget {
  final String userName;
  final String userEmail;
  final Map<String, dynamic>? periode;

  const TambahPeriodeScreen({
    super.key,
    required this.userName,
    required this.userEmail,
    this.periode,
  });

  @override
  State<TambahPeriodeScreen> createState() => _TambahPeriodeScreenState();
}

class _TambahPeriodeScreenState extends State<TambahPeriodeScreen> {
  final TextEditingController _namaPeriodeController = TextEditingController();
  final TextEditingController _catatanController = TextEditingController();
  final TextEditingController _multiplierController = TextEditingController(); // ✅ TAMBAH

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));

  bool _isEditMode = false;
  bool _isLoading = false;
  String? _token;
  double? _selectedMultiplier;

  @override
  void initState() {
    super.initState();
    _loadToken();
    _multiplierController.text = '1.0'; 
    _selectedMultiplier = 1.0;
    
    if (widget.periode != null) {
      _isEditMode = true;
      _namaPeriodeController.text = widget.periode!['nama_periode'] ?? '';
      _startDate = DateTime.parse(widget.periode!['tanggal_mulai']);
      _endDate = DateTime.parse(widget.periode!['tanggal_selesai']);
      _catatanController.text = widget.periode!['catatan'] ?? '';
      
      final raw = widget.periode!['multiplier'];
      final multiplierValue = (raw is double ? raw : double.tryParse(raw.toString())) ?? 1.0;
        
      _multiplierController.text = multiplierValue.toString();
      _selectedMultiplier = multiplierValue;
    }
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2050),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            primaryColor: const Color(0xFF803033),
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF803033),
              onPrimary: Colors.white,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
        if (_endDate.isBefore(_startDate)) {
          _endDate = _startDate.add(const Duration(days: 30));
        }
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: DateTime(2050),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            primaryColor: const Color(0xFF803033),
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF803033),
              onPrimary: Colors.white,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  String formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _simpanPeriode() async {
    if (_namaPeriodeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama periode tidak boleh kosong'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final data = {
      'nama_periode': _namaPeriodeController.text,
      'tanggal_mulai': _startDate.toIso8601String().split('T')[0],
      'tanggal_selesai': _endDate.toIso8601String().split('T')[0],
      'catatan': _catatanController.text,
      'multiplier': _multiplierController.text, 
    };

    try {
      http.Response response;

      if (_isEditMode) {
        response = await http.put(
          Uri.parse(ApiBaseUrl.periodeById(widget.periode!['periode_id'])),
          headers: {
            'Authorization': 'Bearer $_token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: json.encode(data),
        );
      } else {
        response = await http.post(
          Uri.parse(ApiBaseUrl.periode),
          headers: {
            'Authorization': 'Bearer $_token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: json.encode(data),
        );
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditMode
                  ? 'Periode berhasil diupdate!'
                  : 'Periode berhasil ditambahkan!',
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      } else {
        final error = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error['message'] ?? 'Gagal menyimpan periode'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
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
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5ECEA),
      appBar: AppBar(
        title: Text(
          _isEditMode ? 'Edit Periode' : 'Tambah Periode',
          style: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF803033),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF803033)),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF803033)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lengkap detail periode',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Periode Khusus Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5ECEA),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFD8A5A8),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF803033).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.calendar_month,
                            color: Color(0xFF803033),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Periode Khusus',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF803033),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Rekomendasi stok akan disesuaikan otomatis',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Nama Periode
                  Text(
                    'NAMA PERIODE',
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
                      controller: _namaPeriodeController,
                      style: GoogleFonts.plusJakartaSans(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Ramadhan 2026',
                        hintStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: Colors.grey.shade400,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Contoh: Ramadhan, Lebaran, Harbolnas, dll.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Tanggal Mulai
                  Text(
                    'TANGGAL MULAI',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _selectStartDate(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            formatDate(_startDate),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5ECEA),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.calendar_today,
                              color: Color(0xFF803033),
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Tanggal Berakhir
                  Text(
                    'TANGGAL BERAKHIR',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _selectEndDate(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            formatDate(_endDate),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5ECEA),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.calendar_today,
                              color: Color(0xFF803033),
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // MULTIPLIER DROPDOWN
                  Text(
                    'MULTIPLIER',
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
                      child: DropdownButton<double>(
                        isExpanded: true,
                        hint: Text(
                          'Pilih Multiplier',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        icon: const Icon(
                          Icons.keyboard_arrow_down,
                          color: Color(0xFF803033),
                        ),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                        value: _selectedMultiplier,
                        items: const [
                          DropdownMenuItem<double>(
                            value: 1.0,
                            child: Text('1.0 (Normal)'),
                          ),
                          DropdownMenuItem<double>(
                            value: 1.5,
                            child: Text('1.5'),
                          ),
                          DropdownMenuItem<double>(
                            value: 2.0,
                            child: Text('2.0'),
                          ),
                          DropdownMenuItem<double>(
                            value: 2.5,
                            child: Text('2.5'),
                          ),
                          DropdownMenuItem<double>(
                            value: 3.0,
                            child: Text('3.0'),
                          ),
                        ],
                        onChanged: (double? value) {
                          setState(() {
                            _selectedMultiplier = value;
                            _multiplierController.text = value?.toString() ?? '1.0';
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Multiplier akan mengalikan rekomendasi stok untuk semua produk',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      color: Colors.grey.shade500,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Catatan (opsional)
                  Text(
                    'CATATAN (opsional)',
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
                      controller: _catatanController,
                      maxLines: 3,
                      style: GoogleFonts.plusJakartaSans(fontSize: 14),
                      decoration: InputDecoration(
                        hintText:
                            'Bulan puasa - permintaan gamis dan hijab meningkat 2-3× lipat',
                        hintStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: Colors.grey.shade400,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5ECEA),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFD8A5A8),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF803033).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.insights,
                            color: Color(0xFF803033),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pratinjau Pengaruh',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF803033),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Selama periode aktif, sistem akan memberikan rekomendasi penambahan stok dengan volume lebih besar dari periode normal atau dibandingkan dengan hari biasa',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 140,
                        height: 45,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF803033),
                            side: const BorderSide(
                              color: Color(0xFF803033),
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
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
                      const SizedBox(width: 20),
                      SizedBox(
                        width: 160,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: _simpanPeriode,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF803033),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Simpan Periode',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
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
    );
  }

  @override
  void dispose() {
    _namaPeriodeController.dispose();
    _catatanController.dispose();
    _multiplierController.dispose(); 
    super.dispose();
  }
}