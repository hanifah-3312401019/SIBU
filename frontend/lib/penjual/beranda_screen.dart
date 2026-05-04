// lib/penjual/beranda_screen.dart
import 'package:flutter/material.dart';
import 'package:frontend/widgets/sidebar_penjual.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'produk_screen.dart';

class BerandaScreen extends StatefulWidget {
  final String userName;
  final String userEmail;

  const BerandaScreen({
    super.key,
    required this.userName,
    required this.userEmail,
  });

  @override
  State<BerandaScreen> createState() => _BerandaScreenState();
}

class _BerandaScreenState extends State<BerandaScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;

  // ==================== DATA PRODUK TERLARIS ====================
  final List<Map<String, dynamic>> _topProducts = [
    {
      'name': 'Abaya Cokelat Elegan',
      'sales': 42,
      'rank': 1,
      'price': 385000,
      'category': 'Abaya',
      'imageAsset': 'assets/images/abaya_cokelat.jpg',
      'imageIcon': Icons.shopping_bag_outlined,
    },
    {
      'name': 'Gamis Ceruty Payet',
      'sales': 28,
      'rank': 2,
      'price': 295000,
      'category': 'Gamis',
      'imageAsset': 'assets/images/gamisceruty.jpg',
      'imageIcon': Icons.shopping_bag_outlined,
    },
    {
      'name': 'Baju Kurung Melayu',
      'sales': 12,
      'rank': 3,
      'price': 355000,
      'category': 'Baju Kurung',
      'imageAsset': 'assets/images/bajukurung.jpg',
      'imageIcon': Icons.shopping_bag_outlined,
    },
  ];

  // ==================== DATA CHART ====================
  final List<Map<String, dynamic>> _weeklySales = [
    {'day': 'Sen', 'value': 3.2},
    {'day': 'Sel', 'value': 4.5},
    {'day': 'Rab', 'value': 2.8},
    {'day': 'Kam', 'value': 4.2},
    {'day': 'Jum', 'value': 3.8},
    {'day': 'Sab', 'value': 2.5},
    {'day': 'Min', 'value': 3.0},
  ];

  // ==================== FUNGSI FORMAT HARGA ====================
  String formatPrice(int price) {
    return 'Rp ${price.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}';
  }

  // ==================== FUNGSI NAVIGASI ====================
  void _navigateToProduk() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProdukScreen(
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
        break;
      case 1:
        _navigateToProduk();
        break;
      default:
        break;
    }
  }

  void _onBottomNavTapped(int index) {
    switch (index) {
      case 0:
        break;
      case 1:
        _navigateToProduk();
        break;
      default:
        break;
    }
  }

  // ==================== WIDGET GAMBAR PRODUK ====================
  Widget _buildProductImage(Map<String, dynamic> product) {
    final String? imageAsset = product['imageAsset'];
    
    if (imageAsset != null && imageAsset.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          imageAsset,
          width: 55,
          height: 55,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              product['imageIcon'],
              color: const Color(0xFF803033).withOpacity(0.5),
              size: 30,
            );
          },
        ),
      );
    }
    
    return Icon(
      product['imageIcon'],
      color: const Color(0xFF803033).withOpacity(0.5),
      size: 30,
    );
  }

  // ==================== WIDGET ITEM PRODUK ====================
  Widget _buildProductItem(Map<String, dynamic> product) {
    return GestureDetector(
      onTap: _navigateToProduk,
      child: Container(
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
            // Gambar Produk
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                color: const Color(0xFFF5ECEA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _buildProductImage(product),
            ),
            const SizedBox(width: 16),
            // Info Produk
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'],
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatPrice(product['price']),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF803033),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${product['sales']} terjual minggu ini',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            // Rank dengan border
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF5ECEA),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFF5ECEA),
                  width: 1,
                ),
              ),
              child: Text(
                '#${product['rank']}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF803033),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== WIDGET BOTTOM NAVIGATION ====================
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
          _buildNavItem(icon: Icons.bar_chart_outlined, label: 'Laporan', index: 2),
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header dengan Menu Button
                  Row(
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
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Greeting
                  Text(
                    'Halo, ${widget.userName}',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Card Stok Menipis
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFFFE0B2), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF3E0),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFFFE0B2), width: 2),
                          ),
                          child: const Icon(
                            Icons.warning_amber_rounded,
                            color: Color(0xFFFFB74D),
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Stok Menipis',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF803033),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '5 produk perlu restock segera',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: _navigateToProduk,
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF803033),
                          ),
                          child: const Text('Lihat', style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Penjualan Minggu ini
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Penjualan Minggu ini',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            Text(
                              '7 hari',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Rp 12,4jt',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF803033),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 140,
                          child: LineChart(
                            LineChartData(
                              gridData: FlGridData(
                                show: true,
                                drawHorizontalLine: true,
                                drawVerticalLine: false,
                                horizontalInterval: 1,
                                getDrawingHorizontalLine: (value) {
                                  return FlLine(
                                    color: Colors.grey.shade200,
                                    strokeWidth: 1,
                                    dashArray: [5, 5],
                                  );
                                },
                              ),
                              titlesData: FlTitlesData(
                                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    interval: 1,
                                    getTitlesWidget: (value, meta) {
                                      if (value.toInt() >= 0 && value.toInt() < _weeklySales.length) {
                                        return Padding(
                                          padding: const EdgeInsets.only(top: 8),
                                          child: Text(
                                            _weeklySales[value.toInt()]['day'],
                                            style: GoogleFonts.plusJakartaSans(fontSize: 10, color: Colors.grey.shade500),
                                          ),
                                        );
                                      }
                                      return const Text('');
                                    },
                                  ),
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: _weeklySales.asMap().entries.map((entry) {
                                    return FlSpot(entry.key.toDouble(), entry.value['value']);
                                  }).toList(),
                                  isCurved: true,
                                  color: const Color(0xFF803033),
                                  barWidth: 3,
                                  isStrokeCapRound: true,
                                  dotData: FlDotData(
                                    show: true,
                                    getDotPainter: (spot, percent, barData, index) {
                                      return FlDotCirclePainter(
                                        radius: 4,
                                        color: Colors.white,
                                        strokeWidth: 2,
                                        strokeColor: const Color(0xFF803033),
                                      );
                                    },
                                  ),
                                  belowBarData: BarAreaData(show: false),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Produk Terlaris
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Produk Terlaris',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF803033),
                        ),
                      ),
                      GestureDetector(
                        onTap: _navigateToProduk,
                        child: Row(
                          children: [
                            const Icon(Icons.star, color: Color(0xFF803033), size: 16),
                            const SizedBox(width: 4),
                            Text(
                              'Lihat semua',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: const Color(0xFF803033),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ..._topProducts.map((product) => _buildProductItem(product)),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}