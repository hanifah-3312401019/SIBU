import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/widgets/sidebar_penjual.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'produk_screen.dart';
import 'laporan_penjualan.dart';
import '../api/api_base_url.dart';

class BerandaScreen extends StatefulWidget {
  final String userName;
  final String userEmail;
  final bool isLoggedIn;
  const BerandaScreen({
    super.key,
    required this.userName,
    required this.userEmail,
    this.isLoggedIn = false,
  });
  @override State<BerandaScreen> createState() => _BerandaScreenState();
}

class _BerandaScreenState extends State<BerandaScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;

  List<Map<String, dynamic>> _topProducts = [];
  List<Map<String, dynamic>> _weeklySales = [];
  List<Map<String, dynamic>> _lowStockProducts = [];
  bool _isLoading = true;
  String? _token;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTokenAndFetch();
  }

  // ==================== FETCH DATA ====================
  Future<void> _loadTokenAndFetch() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    await Future.wait([_fetchDashboardData(), _fetchLowStockProducts()]);
  }

  Future<void> _fetchDashboardData() async {
    setState(() => _isLoading = true);
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

      final resPenjualan = await http.get(
        Uri.parse('${ApiBaseUrl.laporanPenjualan}?periode=mingguan&tanggal=$dateStr'),
        headers: {'Authorization': 'Bearer $_token'},
      );
      final resProduk = await http.get(
        Uri.parse('${ApiBaseUrl.laporanProdukTerlaris}?periode=mingguan&tanggal=$dateStr'),
        headers: {'Authorization': 'Bearer $_token'},
      );

      if (resPenjualan.statusCode == 200 && resProduk.statusCode == 200) {
        final dataPenjualan = jsonDecode(resPenjualan.body);
        final dataProduk = jsonDecode(resProduk.body);

        if (dataPenjualan['success'] == true && dataProduk['success'] == true) {
          final pData = dataPenjualan['data'];
          final labels = List<String>.from(pData['labels']);
          final values = List<int>.from(pData['values']);
          final counts = List<int>.from(pData['transaction_counts']);

          setState(() {
            _weeklySales = List.generate(labels.length, (i) => {
              'day': labels[i],
              'value': values[i] / 1000000,
              'count': counts[i],
            });

            final prodList = dataProduk['data'] as List;
            _topProducts = prodList.map((item) {
              final map = item as Map<String, dynamic>;
              return {
                'nama_produk': map['nama_produk'] ?? '',
                'total_terjual': map['total_terjual'] ?? 0,
                'total_penjualan': map['total_penjualan'] ?? 0,
                'gambar': map['gambar'] ?? '',
                'harga': map['harga'] ?? 0,
                'rank': prodList.indexOf(item) + 1,
              };
            }).toList();

            _isLoading = false;
            _errorMessage = null;
          });
        }
      } else {
        setState(() => _isLoading = false);
        _errorMessage = 'Gagal memuat data dashboard';
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error: ${e.toString()}';
      });
    }
  }

  Future<void> _fetchLowStockProducts() async {
    try {
      final response = await http.get(
        Uri.parse(ApiBaseUrl.produk),
        headers: {'Authorization': 'Bearer $_token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final allProducts = data['data'] as List;
          final lowStock = allProducts.where((p) {
            final stok = p['stok'] ?? 0;
            final minStok = p['min_stok'] ?? 10;
            return stok <= minStok && stok > 0;
          }).toList()..sort((a, b) => (a['stok'] ?? 0).compareTo(b['stok'] ?? 0));

          setState(() {
            _lowStockProducts = lowStock.map((item) => {
              'produk_id': item['produk_id'],
              'nama_produk': item['nama_produk'] ?? '',
              'stok': item['stok'] ?? 0,
              'min_stok': item['min_stok'] ?? 10,
              'gambar': item['gambar'] ?? '',
              'harga': item['harga'] ?? 0,
            }).toList();
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching low stock: $e');
    }
  }

  // ==================== HELPERS ====================
  String _rupiah(int v) => v >= 1000000
      ? 'Rp ${(v / 1000000) % 1 == 0 ? (v / 1000000).toInt() : (v / 1000000).toStringAsFixed(1)}jt'
      : 'Rp ${v.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';

  String formatPrice(int price) => _rupiah(price);

  int _totalPenjualanMingguan() => _weeklySales.fold<int>(0, (sum, item) {
    final value = (item['value'] ?? 0) as num;
    return sum + (value * 1000000).toInt();
  });

  // ==================== NAVIGASI ====================
  void _navigateToProduk() => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProdukScreen(userName: widget.userName, userEmail: widget.userEmail),
        ),
      );

  void _navigateToLaporan() => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LaporanPenjualan(userName: widget.userName, userEmail: widget.userEmail),
        ),
      );

  void _navigateToProdukWithLowStock() => _navigateToProduk();

  void _onMenuItemSelected(int index) {
    Navigator.pop(context);
    if (index == 1) _navigateToProduk();
    if (index == 2) _navigateToLaporan();
  }

  void _onBottomNavTapped(int index) {
    if (index == 0) return;
    if (index == 1) _navigateToProduk();
    if (index == 2) _navigateToLaporan();
  }

  // ==================== WIDGETS ====================
  Widget _buildProductImage(Map<String, dynamic> product, {double size = 55}) {
    final image = product['gambar'];
    if (image != null && image.toString().isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          ApiBaseUrl.getImageUrl(image),
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Icon(Icons.checkroom, color: Colors.grey.shade400, size: 30),
        ),
      );
    }
    return Icon(Icons.checkroom, color: Colors.grey.shade400, size: 30);
  }

  Widget _buildProductItem(Map<String, dynamic> product) => GestureDetector(
        onTap: _navigateToProduk,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Row(
            children: [
              Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(color: const Color(0xFFF5ECEA), borderRadius: BorderRadius.circular(12)),
                child: _buildProductImage(product),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['nama_produk'] ?? '',
                      style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatPrice(product['harga'] ?? 0),
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF803033)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${product['total_terjual'] ?? 0} terjual minggu ini',
                      style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5ECEA),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFF5ECEA), width: 1),
                ),
                child: Text(
                  '#${product['rank'] ?? 0}',
                  style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF803033)),
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildNavItem({required IconData icon, required String label, required int index}) {
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

  Widget _buildBottomNavBar() => Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white, width: 1),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, -2))],
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

  Widget _buildChart() => SizedBox(
        height: 140,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawHorizontalLine: true,
                drawVerticalLine: false,
                horizontalInterval: 1,
                getDrawingHorizontalLine: (_) => FlLine(color: Colors.grey.shade200, strokeWidth: 1, dashArray: [5, 5]),
              ),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    getTitlesWidget: (value, _) {
                      if (value % 1 != 0) return const SizedBox.shrink();
                      final idx = value.toInt();
                      if (idx >= 0 && idx < _weeklySales.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 9),
                          child: Text(
                            _weeklySales[idx]['day'],
                            style: GoogleFonts.plusJakartaSans(fontSize: 10, color: Colors.grey.shade500),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              lineTouchData: LineTouchData(
                enabled: true,
                touchTooltipData: LineTouchTooltipData(
                  tooltipPadding: const EdgeInsets.all(8),
                  tooltipMargin: 8,
                  getTooltipColor: (_) => const Color(0xFF803033),
                  getTooltipItems: (spots) => spots.map((spot) {
                    final idx = spot.x.toInt();
                    final count = idx >= 0 && idx < _weeklySales.length ? _weeklySales[idx]['count'] ?? 0 : 0;
                    return LineTooltipItem(
                      '$count transaksi',
                      const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                    );
                  }).toList(),
                ),
                handleBuiltInTouches: true,
              ),
              minX: -0.3,
              maxX: (_weeklySales.length - 1) + 0.3,
              lineBarsData: [
                LineChartBarData(
                  spots: _weeklySales.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value['value'])).toList(),
                  isCurved: true,
                  color: const Color(0xFF803033),
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                      radius: 4,
                      color: Colors.white,
                      strokeWidth: 2,
                      strokeColor: const Color(0xFF803033),
                    ),
                  ),
                  belowBarData: BarAreaData(show: false),
                ),
              ],
            ),
          ),
        ),
      );

  // ==================== BUILD ====================
  @override
  Widget build(BuildContext context) => Scaffold(
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
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF803033)))
                  : _errorMessage != null
                      ? Center(child: Text(_errorMessage!))
                      : SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // HEADER
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
                                    child: const Icon(Icons.notifications_none, color: Color(0xFF803033), size: 22),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // GREETING
                              Text(
                                'Halo, ${widget.userName}',
                                style: GoogleFonts.playfairDisplay(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              const SizedBox(height: 24),

                              // CARD STOK MENIPIS
                              if (_lowStockProducts.isNotEmpty) ...[
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: const Color(0xFFFFE0B2), width: 2),
                                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
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
                                        child: const Icon(Icons.warning_amber_rounded, color: Color(0xFFFFB74D), size: 28),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Stok Menipis',
                                              style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF803033)),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${_lowStockProducts.length} produk perlu restock segera',
                                              style: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.grey.shade600),
                                            ),
                                          ],
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: _navigateToProdukWithLowStock,
                                        style: TextButton.styleFrom(foregroundColor: const Color(0xFF803033)),
                                        child: const Text('Lihat', style: TextStyle(fontWeight: FontWeight.w600)),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),
                              ],

                              // PENJUALAN MINGGU INI
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Penjualan Minggu ini',
                                          style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                                        ),
                                        Text(
                                          '7 hari',
                                          style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.grey.shade600),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _rupiah(_totalPenjualanMingguan()),
                                      style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF803033)),
                                    ),
                                    const SizedBox(height: 16),
                                    if (_weeklySales.isNotEmpty) _buildChart(),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),

                              // PRODUK TERLARIS
                              Text(
                                'Produk Terlaris',
                                style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF803033)),
                              ),
                              const SizedBox(height: 12),
                              if (_topProducts.isNotEmpty)
                                ..._topProducts.take(3).map((p) => _buildProductItem(p))
                              else
                                Center(
                                  child: Text(
                                    'Belum ada data produk terlaris',
                                    style: GoogleFonts.plusJakartaSans(fontSize: 14, color: Colors.grey.shade500),
                                  ),
                                ),
                              const SizedBox(height: 80),
                            ],
                          ),
                        ),
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomNavBar(),
      );
}
