// lib/penjual/riwayat_transaksi_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/sidebar_penjual.dart';
import 'beranda_screen.dart';
import 'produk_screen.dart';

class RiwayatTransaksiScreen extends StatefulWidget {
  final String userName;
  final String userEmail;

  const RiwayatTransaksiScreen({
    super.key,
    required this.userName,
    required this.userEmail,
  });

  @override
  State<RiwayatTransaksiScreen> createState() => _RiwayatTransaksiScreenState();
}

class _RiwayatTransaksiScreenState extends State<RiwayatTransaksiScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 2;

  final List<Map<String, dynamic>> _transactions = [
    {
      'id': 'INV-2510',
      'date': '22 Jun, 14:22',
      'total': 450000,
      'items': 3,
      'status': 'completed',
    },
    {
      'id': 'INV-2509',
      'date': '20 Jun, 10:12',
      'total': 295000,
      'items': 2,
      'status': 'completed',
    },
    {
      'id': 'INV-2508',
      'date': '18 Jun, 13:32',
      'total': 740000,
      'items': 4,
      'status': 'completed',
    },
    {
      'id': 'INV-2507',
      'date': '15 Jun, 11:34',
      'total': 355000,
      'items': 1,
      'status': 'completed',
    },
    {
      'id': 'INV-2506',
      'date': '12 Jun, 15:25',
      'total': 520000,
      'items': 2,
      'status': 'completed',
    },
    {
      'id': 'INV-2505',
      'date': '10 Jun, 17:02',
      'total': 175000,
      'items': 1,
      'status': 'completed',
    },
    {
      'id': 'INV-2504',
      'date': '10 Jun, 13:20',
      'total': 389000,
      'items': 2,
      'status': 'completed',
    },
  ];

  void _navigateToBeranda() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => BerandaScreen(
          userName: widget.userName,
          userEmail: widget.userEmail,
        ),
      ),
    );
  }

  void _navigateToProduk() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ProdukScreen(
          userName: widget.userName,
          userEmail: widget.userEmail,
        ),
      ),
    );
  }

  void _navigateToTransaksiBaru() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RiwayatTransaksiScreen(
          userName: widget.userName,
          userEmail: widget.userEmail,
        ),
      ),
    );
  }

  void _onMenuItemSelected(int index) {
    Navigator.pop(context);
    switch (index) {
      case 0:
        _navigateToBeranda();
        break;
      case 1:
        _navigateToProduk();
        break;
      case 2:
        break;
    }
  }

  void _onBottomNavTapped(int index) {
    switch (index) {
      case 0:
        _navigateToBeranda();
        break;
      case 1:
        _navigateToProduk();
        break;
      case 2:
        break;
    }
  }

  String formatPrice(int price) {
    return 'Rp ${price.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}';
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
        onItemSelected: _onMenuItemSelected,
      ),
      body: Stack(
        children: [
          Container(color: const Color(0xFFF5ECEA)),

          // Header Gradasi
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

          // Content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header dengan Menu Button
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

                // Title 
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Riwayat Transaksi',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Data transaksi penjualan',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // List Transaksi
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = _transactions[index];
                      return _buildTransactionCard(transaction);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: SizedBox(
        width: 180,
        height: 48,
        child: FloatingActionButton.extended(
          onPressed: _navigateToTransaksiBaru,
          backgroundColor: const Color(0xFF803033),
          elevation: 0,
          icon: const Icon(Icons.add, color: Colors.white, size: 20),
          label: const Text(
            'Tambah Transaksi Baru',
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
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> transaction) {
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
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFF5ECEA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              color: Color(0xFF803033),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction['id'],
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF803033),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  transaction['date'],
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatPrice(transaction['total']),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Detail transaksi ${transaction['id']}'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF803033),
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Lihat detail',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF803033),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(icon: Icons.home_outlined, label: 'Beranda', index: 0),
          _buildNavItem(icon: Icons.inventory_2_outlined, label: 'Produk', index: 1),
          _buildNavItem(icon: Icons.receipt_long_outlined, label: 'Transaksi', index: 2),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _selectedIndex == index;
    final opacity = isSelected ? 1.0 : 0.5;

    return GestureDetector(
      onTap: () => _onBottomNavTapped(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
          border: isSelected ? Border.all(color: Colors.grey.shade200, width: 1) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFF803033).withOpacity(opacity), size: 18),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: const Color(0xFF803033).withOpacity(opacity),
              ),
            ),
          ],
        ),
      ),
    );
  }
}