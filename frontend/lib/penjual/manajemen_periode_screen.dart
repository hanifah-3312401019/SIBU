// lib/penjual/manajemen_periode_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/sidebar_penjual.dart';
import 'tambah_periode_screen.dart';

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

  final List<Map<String, dynamic>> _periods = [
    {
      'id': 1,
      'name': 'Ramadhan 2026',
      'startDate': DateTime(2026, 2, 19),
      'endDate': DateTime(2026, 3, 20),
      'status': 'Aktif',
      'statusColor': Colors.green,
    },
    {
      'id': 2,
      'name': 'Lebaran 2026',
      'startDate': DateTime(2026, 3, 20),
      'endDate': DateTime(2026, 3, 30),
      'status': 'Mendatang',
      'statusColor': Colors.orange,
    },
    {
      'id': 3,
      'name': 'Ramadhan 2025',
      'startDate': DateTime(2025, 3, 1),
      'endDate': DateTime(2025, 3, 30),
      'status': 'Selesai',
      'statusColor': Colors.grey,
    },
  ];

  void _navigateToTambahPeriode() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TambahPeriodeScreen(
          userName: widget.userName,
          userEmail: widget.userEmail,
        ),
      ),
    );
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
    );
  }

  void _deletePeriode(Map<String, dynamic> periode) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5ECEA),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_outline,
                  color: Color(0xFF803033),
                  size: 32,
                ),
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
                'Apakah Anda yakin ingin menghapus periode ${periode['name']}?',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                ),
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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 0),
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _periods.remove(periode);
                        });
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Periode ${periode['name']} telah dihapus'),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF803033),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 0),
                      ),
                      child: Text(
                        'Ya, Hapus',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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

  String formatDate(DateTime date) {
    return '${date.day} ${_getMonthName(date.month)} ${date.year}';
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return months[month - 1];
  }

  String formatDateRange(DateTime start, DateTime end) {
    return '${formatDate(start)} → ${formatDate(end)}';
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
        onItemSelected: (index) {
          Navigator.pop(context);
        },
      ),
      body: Stack(
        children: [
          Container(color: const Color(0xFFF5ECEA)),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.28,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                  colors: const [
                    Color(0xFF803033),
                    Color(0xFFD8A5A8),
                    Color(0xFFF5ECEA),
                  ],
                ),
                borderRadius: const BorderRadius.only(
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
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.notifications_none,
                          color: Color(0xFF803033),
                          size: 20,
                        ),
                      ),
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
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Data list periode',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
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
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD8A5A8).withOpacity(0.3),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.info_outline,
                            color: Color(0xFF803033),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Tetapkan periode khusus (mis. Ramadhan, Lebaran) agar rekomendasi stok menyesuaikan tren penjualan musiman.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _periods.length,
                    itemBuilder: (context, index) {
                      final periode = _periods[index];
                      return _buildPeriodeCard(periode);
                    },
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
          label: const Text(
            'Tambah Periode',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildPeriodeCard(Map<String, dynamic> periode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
                  border: Border.all(
                    color: const Color(0xFFD8A5A8),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.calendar_today,
                  color: Color(0xFF803033),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      periode['name'],
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF803033),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatDateRange(
                        periode['startDate'],
                        periode['endDate'],
                      ),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: periode['statusColor'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  periode['status'],
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: periode['statusColor'],
                  ),
                ),
              ),
            ],
          ),
          
          const Divider(color: Color(0xFFEEEEEE), height: 15),
          
          const SizedBox(height: 5),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                width: 142,
                child: _buildActionButton(
                  icon: Icons.edit_outlined,
                  label: 'Edit',
                  color: const Color(0xFF803033),
                  backgroundColor: const Color(0xFFF5ECEA),
                  borderColor: const Color(0xFFF5ECEA),
                  onTap: () => _editPeriode(periode),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 142,
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
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: borderColor,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}