// lib/penjual/manajemen_periode_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/sidebar_penjual.dart';
import 'tambah_periode_screen.dart';
import '../api/api_base_url.dart';

class ManajemenPeriodeScreen extends StatefulWidget {
  final String userName;
  final String userEmail;

  const ManajemenPeriodeScreen({
    super.key,
    required this.userName,
    required this.userEmail,
  });

  @override
  State<ManajemenPeriodeScreen> createState() => _ManajemenPeriodeScreenState();
}

class _ManajemenPeriodeScreenState extends State<ManajemenPeriodeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 4;

  List<Map<String, dynamic>> _periods = [];
  bool _isLoading = true;
  String? _token;

  String? _activePeriodeId;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    _activePeriodeId = prefs.getString('selected_periode_id');
    await _fetchPeriods();
  }

  Future<void> _fetchPeriods() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse(ApiBaseUrl.periode),
        headers: {
          'Authorization': 'Bearer $_token',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<Map<String, dynamic>> allPeriods =
              List<Map<String, dynamic>>.from(data['data']);
          final validPeriods = allPeriods
              .where((p) =>
                  p['tanggal_mulai'] != null && p['tanggal_selesai'] != null)
              .toList();
          setState(() {
            _periods = validPeriods;
            _isLoading = false;
          });
        } else {
          setState(() => _isLoading = false);
        }
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _aktifkanPeriode(Map<String, dynamic> periode) async {
    final id = periode['periode_id'].toString();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_periode_id', id);
    setState(() => _activePeriodeId = id);

    final multiplier = periode['multiplier'] ?? 1.0;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Periode "${periode['nama_periode']}" diaktifkan (×$multiplier). Rekomendasi stok akan menyesuaikan.'),
        backgroundColor: const Color(0xFF803033),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _nonaktifkanPeriode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('selected_periode_id');
    setState(() => _activePeriodeId = null);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
            'Periode dinonaktifkan. Rekomendasi stok kembali ke data normal.'),
        backgroundColor: Colors.grey.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _navigateToTambahPeriode() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TambahPeriodeScreen(
          userName: widget.userName,
          userEmail: widget.userEmail,
        ),
      ),
    ).then((_) => _fetchPeriods());
  }

  void _editPeriode(Map<String, dynamic> periode) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TambahPeriodeScreen(
          userName: widget.userName,
          userEmail: widget.userEmail,
          periode: periode,
        ),
      ),
    ).then((_) => _fetchPeriods());
  }

  void _deletePeriode(Map<String, dynamic> periode) {
    final namaPeriode = periode['nama_periode'] ?? 'Periode ini';
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(color: Color(0xFFF5ECEA), shape: BoxShape.circle),
                child: const Icon(Icons.delete_outline, color: Color(0xFF803033), size: 32),
              ),
              const SizedBox(height: 16),
              Text(
                'Hapus Periode?',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF803033),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Apakah Anda yakin ingin menghapus periode $namaPeriode?',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        fixedSize: const Size(double.maxFinite, 41),
                        foregroundColor: const Color(0xFF803033),
                        side: const BorderSide(color: Color(0xFF803033), width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Batal', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        setState(() => _isLoading = true);
                        try {
                          final response = await http.delete(
                            Uri.parse(ApiBaseUrl.periodeById(periode['periode_id'])),
                            headers: {
                              'Authorization': 'Bearer $_token',
                              'Accept': 'application/json',
                            },
                          );
                          if (response.statusCode == 200) {
                            if (_activePeriodeId == periode['periode_id'].toString()) {
                              await _nonaktifkanPeriode();
                            }
                            await _fetchPeriods();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Periode $namaPeriode telah dihapus'),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          } else {
                            setState(() => _isLoading = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Gagal menghapus periode'), backgroundColor: Colors.red),
                            );
                          }
                        } catch (e) {
                          setState(() => _isLoading = false);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF803033),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: Text('Ya, Hapus', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String formatDate(DateTime date) => '${date.day} ${_getMonthName(date.month)} ${date.year}';

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return months[month - 1];
  }

  String formatDateRange(DateTime start, DateTime end) => '${formatDate(start)} → ${formatDate(end)}';

  String getStatus(DateTime start, DateTime end) {
    final now = DateTime.now();
    if (now.isAfter(start) && now.isBefore(end)) return 'Aktif';
    if (now.isBefore(start)) return 'Mendatang';
    return 'Selesai';
  }

  Color getStatusColor(DateTime start, DateTime end) {
    final now = DateTime.now();
    if (now.isAfter(start) && now.isBefore(end)) return Colors.green;
    if (now.isBefore(start)) return Colors.orange;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF5ECEA),
      drawer: SidebarWidget(
        userName: widget.userName,
        userEmail: widget.userEmail,
        selectedIndex: _selectedIndex,
        onItemSelected: (index) => Navigator.pop(context),
      ),
      body: Stack(
        children: [
          Container(color: const Color(0xFFF5ECEA)),
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                        icon: const Icon(Icons.menu, color: Colors.white, size: 24),
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
                        'Manajemen Periode',
                        style: GoogleFonts.playfairDisplay(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Data list periode',
                        style: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                if (_activePeriodeId != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF803033),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Periode aktif: ${_periods.firstWhere((p) => p['periode_id'].toString() == _activePeriodeId, orElse: () => {'nama_periode': '...'})['nama_periode']}',
                              style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ),
                          GestureDetector(
                            onTap: _nonaktifkanPeriode,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Nonaktifkan',
                                style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 12),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5ECEA),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFD8A5A8), width: 1),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD8A5A8).withOpacity(0.3),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.info_outline, color: Color(0xFF803033), size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Aktifkan periode khusus (mis. Ramadhan, Lebaran) agar rekomendasi stok menyesuaikan tren penjualan musiman.',
                            style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey.shade700, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFF803033)))
                      : _periods.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.calendar_today, size: 48, color: Colors.grey.shade400),
                                  const SizedBox(height: 12),
                                  Text('Belum ada periode', style: GoogleFonts.plusJakartaSans(fontSize: 14, color: Colors.grey.shade500)),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: _periods.length,
                              itemBuilder: (context, index) => _buildPeriodeCard(_periods[index]),
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: SizedBox(
        width: 160,
        height: 48,
        child: FloatingActionButton.extended(
          onPressed: _navigateToTambahPeriode,
          backgroundColor: const Color(0xFF803033),
          elevation: 0,
          icon: const Icon(Icons.add, color: Colors.white, size: 20),
          label: const Text('Tambah Periode', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildPeriodeCard(Map<String, dynamic> periode) {
    final namaPeriode = periode['nama_periode'] ?? 'Tanpa Nama';
    final catatan = periode['catatan'] ?? '';
    final tanggalMulai = periode['tanggal_mulai'];
    final tanggalSelesai = periode['tanggal_selesai'];
    final multiplier = (periode['multiplier'] ?? 1.0).toDouble();

    if (tanggalMulai == null || tanggalSelesai == null) {
      return const SizedBox.shrink();
    }

    final startDate = DateTime.parse(tanggalMulai).toLocal();
    final endDate = DateTime.parse(tanggalSelesai).toLocal();
    final periodeIdStr = periode['periode_id'].toString();
    
    final isUserActive = _activePeriodeId == periodeIdStr;
    final isDateActive = getStatus(startDate, endDate) == 'Aktif';
    final status = getStatus(startDate, endDate);
    
    String displayStatus;
    Color displayStatusColor;
    
    if (isUserActive) {
      displayStatus = 'Sedang Aktif';
      displayStatusColor = const Color(0xFF803033);
    } else {
      displayStatus = status;
      displayStatusColor = getStatusColor(startDate, endDate);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isUserActive ? Border.all(color: const Color(0xFF803033), width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5ECEA),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFD8A5A8), width: 1),
                ),
                child: const Icon(Icons.calendar_today, color: Color(0xFF803033), size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            namaPeriode,
                            style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF803033)),
                          ),
                        ),
                        if (isUserActive)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF803033),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '✓ Dipilih',
                              style: GoogleFonts.plusJakartaSans(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w700),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatDateRange(startDate, endDate),
                      style: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5ECEA),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '× $multiplier',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF803033),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: displayStatusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  displayStatus,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: displayStatusColor,
                  ),
                ),
              ),
            ],
          ),

          if (catatan.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(catatan, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey.shade600)),
          ],

          const Divider(color: Color(0xFFEEEEEE), height: 20),

          Row(
            children: [
              // Tombol Aktifkan 
              if ((status == 'Mendatang' || status == 'Aktif') && !isUserActive)
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.play_circle_outline,
                    label: 'Aktifkan',
                    color: const Color(0xFF803033),
                    backgroundColor: const Color(0xFFF5ECEA),
                    borderColor: const Color(0xFF803033),
                    onTap: () => _aktifkanPeriode(periode),
                  ),
                ),
              
              // Tombol Nonaktifkan 
              if (isUserActive)
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.power_settings_new,
                    label: 'Nonaktifkan',
                    color: Colors.grey.shade600,
                    backgroundColor: Colors.grey.shade100,
                    borderColor: Colors.grey.shade300,
                    onTap: _nonaktifkanPeriode,
                  ),
                ),
              
              if ((status == 'Mendatang' || status == 'Aktif') && !isUserActive)
                const SizedBox(width: 8),
              
              // Tombol Edit 
              SizedBox(
                width: 70,
                child: _buildActionButton(
                  icon: Icons.edit_outlined,
                  label: 'Edit',
                  color: Colors.blue.shade700,
                  backgroundColor: Colors.blue.shade50,
                  borderColor: Colors.blue.shade100,
                  onTap: () => _editPeriode(periode),
                ),
              ),
              const SizedBox(width: 8),
              
              // Tombol Hapus 
              SizedBox(
                width: 70,
                child: _buildActionButton(
                  icon: Icons.delete_outline,
                  label: 'Hapus',
                  color: Colors.red,
                  backgroundColor: const Color.fromARGB(144, 249, 192, 192),
                  borderColor: const Color.fromARGB(144, 249, 192, 192),
                  onTap: () => _deletePeriode(periode),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color backgroundColor,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 15),
            const SizedBox(width: 5),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: color),
            ),
          ],
        ),
      ),
    );
  }
}