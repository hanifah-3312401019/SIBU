// lib/penjual/tambah_periode_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

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
  
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    if (widget.periode != null) {
      _isEditMode = true;
      _namaPeriodeController.text = widget.periode!['name'];
      _startDate = widget.periode!['startDate'];
      _endDate = widget.periode!['endDate'];
      _catatanController.text = widget.periode!['notes'] ?? '';
    }
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('id', 'ID'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF803033),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF803033),
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
      lastDate: DateTime(2030),
      locale: const Locale('id', 'ID'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF803033),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF803033),
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
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _simpanPeriode() {
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isEditMode ? 'Periode berhasil diupdate!' : 'Periode berhasil ditambahkan!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.pop(context);
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
      body: Builder(
        builder: (scaffoldContext) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Subtitle
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
                  'Contoh: Ramadhan, Lebaran, dsb.',
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
                  onTap: () => _selectStartDate(scaffoldContext),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                  onTap: () => _selectEndDate(scaffoldContext),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                      hintText: 'Bulan puasa - permintaan gamis dan hijab meningkat 2-3× lipat',
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
                
                // Pratinjau Pengaruh Card
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
                
                // Tombol Batal dan Simpan Periode
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
                          side: const BorderSide(color: Color(0xFF803033), width: 1.5),
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
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _namaPeriodeController.dispose();
    _catatanController.dispose();
    super.dispose();
  }
}