import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_base_url.dart';
import '../widgets/sidebar_penjual.dart';
import 'beranda_screen.dart';
import 'produk_screen.dart';
import 'tambah_transaksi_baru.dart';
import 'notifikasi_penjual.dart';

const _kPrimary2 = Color(0xFF803033);
const _kBg2 = Color(0xFFF5ECEA);

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

  // Data dari API
  List<Map<String, dynamic>> _transactions = [];
  bool _isLoading = true;
  String? _token;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  int _belumDibaca = 0;

  @override
  void initState() {
    super.initState();
    _loadTokenAndFetch();
  }

  Future<void> _loadTokenAndFetch() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    await _fetchTransactions();
    await _fetchJumlahNotifikasi();
  }

  Future<void> _fetchTransactions() async {
    setState(() => _isLoading = true);

    try {
      final response = await http.get(
        Uri.parse(ApiBaseUrl.riwayatTransaksi),
        headers: {'Authorization': 'Bearer $_token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() {
            _transactions = List<Map<String, dynamic>>.from(data['data']);
            _isLoading = false;
          });
        }
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error fetching transactions: $e');
    }
  }

  Future<void> _fetchJumlahNotifikasi() async {
    try {
      final response = await http.get(
        Uri.parse(ApiBaseUrl.notifikasi), 
        headers: {
          'Authorization': 'Bearer $_token',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List listNotif = data['data'] ?? [];
          // Menghitung jumlah data notifikasi yang belum dibaca
          final unread = listNotif.where((n) => 
            n['sudah_dibaca'] == false || n['sudah_dibaca'] == 0 || n['sudah_dibaca'] == '0'
          ).length;

          setState(() {
            _belumDibaca = unread;
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _showDetailDialog(Map<String, dynamic> transaction) async {
    try {
      final response = await http.get(
        Uri.parse(ApiBaseUrl.transaksiById(transaction['transaksi_id'])),
        headers: {'Authorization': 'Bearer $_token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          _showDetailContent(data['data']);
        }
      }
    } catch (e) {
      print('Error fetching detail: $e');
    }
  }

  void _showDetailContent(Map<String, dynamic> detail) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    detail['nomor_invoice'],
                    style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.bold, color: _kPrimary2),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: detail['status'] == 'selesai'
                          ? Colors.green
                          : (detail['status'] == 'dibatalkan' ? Colors.red : Colors.orange),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      detail['status'] == 'selesai'
                          ? 'Selesai'
                          : (detail['status'] == 'dibatalkan' ? 'Dibatalkan' : 'Pending'),
                      style: GoogleFonts.plusJakartaSans(fontSize: 10, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                _formatDate(detail['tanggal_transaksi']),
                style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey.shade600),
              ),
              const Divider(height: 24),
              ...detail['detail'].map<Widget>((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: _kBg2,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: item['gambar'] != null
                            ? Image.network(
                                ApiBaseUrl.getImageUrl(item['gambar']),
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Icon(Icons.checkroom, color: _kPrimary2, size: 30),
                              )
                            : Icon(Icons.checkroom, color: _kPrimary2, size: 30),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item['nama_produk'], style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 13)),
                          if (item['ukuran'] != null && item['ukuran'].isNotEmpty)
                            Text('Ukuran: ${item['ukuran']}', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.grey.shade600)),
                          Text('${item['jumlah']} x ${_rupiah(item['harga'])}', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.grey.shade600)),
                        ],
                      ),
                    ),
                    Text(_rupiah(item['subtotal']), style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13, color: _kPrimary2)),
                  ],
                ),
              )),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold)),
                  Text(_rupiah(detail['total']), style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: _kPrimary2)),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kPrimary2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Tutup', style: GoogleFonts.plusJakartaSans(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _rupiah(int v) {
    final s = v.toString();
    return 'Rp ${s.replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  String _formatDate(String? dateTime) {
    if (dateTime == null) return '-';
    final date = DateTime.parse(dateTime).toLocal();
    return '${date.day} ${_getMonthName(date.month)} ${date.year}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return months[month - 1];
  }

  List<Map<String, dynamic>> get _filteredTransactions {
    if (_searchQuery.isEmpty) return _transactions;
    return _transactions.where((transaction) {
      return transaction['nomor_invoice'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  void _navigateToBeranda() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => BerandaScreen(userName: widget.userName, userEmail: widget.userEmail),
      ),
    );
  }

  void _navigateToProduk() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ProdukScreen(userName: widget.userName, userEmail: widget.userEmail),
      ),
    );
  }

  void _navigateToTambahTransaksi() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TambahTransaksiBaru(userName: widget.userName, userEmail: widget.userEmail),
      ),
    ).then((_) => _fetchTransactions());
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

  @override
  Widget build(BuildContext context) {
    final filteredTransactions = _filteredTransactions;

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
                        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                        icon: const Icon(Icons.menu, color: Colors.white, size: 24),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const Spacer(),
                      Badge(
                        label: Text(
                          '$_belumDibaca',
                          style: const TextStyle(color: Colors.white, fontSize: 10),
                        ),
                        backgroundColor: const Color(0xFF803033),
                        isLabelVisible: _belumDibaca > 0, 
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NotifikasiPenjual(
                                  userName: widget.userName,
                                  userEmail: widget.userEmail,
                                ),
                              ),
                            ).then((_) {
                              _fetchJumlahNotifikasi();
                            });
                          },
                          child: Container(
                            child: const Icon(Icons.notifications_none, color: Color(0xFF803033), size: 20),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Riwayat Transaksi', style: GoogleFonts.playfairDisplay(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 4),
                      Text('Data transaksi penjualan', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.white70)),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5ECEA),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) => setState(() => _searchQuery = value),
                          style: GoogleFonts.plusJakartaSans(fontSize: 14, color: Colors.black87),
                          decoration: InputDecoration(
                            hintText: 'Cari riwayat transaksi...',
                            hintStyle: GoogleFonts.plusJakartaSans(color: Colors.grey.shade500, fontSize: 14),
                            prefixIcon: Icon(Icons.search, color: Colors.grey.shade500, size: 22),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                            filled: true,
                            fillColor: const Color(0xFFF5ECEA),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFF803033)))
                      : filteredTransactions.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey.shade400),
                                  const SizedBox(height: 12),
                                  Text(
                                    _searchQuery.isEmpty ? 'Belum ada transaksi' : 'Tidak ditemukan',
                                    style: GoogleFonts.plusJakartaSans(fontSize: 14, color: Colors.grey.shade500),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: filteredTransactions.length,
                              itemBuilder: (context, index) => _buildTransactionCard(filteredTransactions[index]),
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: SizedBox(
        width: 190,
        height: 58,
        child: FloatingActionButton.extended(
          onPressed: _navigateToTambahTransaksi,
          backgroundColor: const Color(0xFF803033),
          elevation: 0,
          icon: const Icon(Icons.add, color: Colors.white, size: 20),
          label: const Text('Tambah Transaksi Baru', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> transaction) {
    return GestureDetector(
      onTap: () => _showDetailDialog(transaction),
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
              width: 50,
              height: 50,
              decoration: BoxDecoration(color: const Color(0xFFF5ECEA), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.receipt_long_outlined, color: Color(0xFF803033), size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(transaction['nomor_invoice'], style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF803033))),
                  const SizedBox(height: 5),
                  Text(_formatDate(transaction['tanggal_transaksi']), style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.grey.shade800)),
                  Text('${transaction['items']} produk', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: Colors.grey.shade700)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(_rupiah(transaction['total']), style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: transaction['status'] == 'selesai'
                        ? Colors.green.withOpacity(0.1)
                        : (transaction['status'] == 'dibatalkan' ? Colors.red.withOpacity(0.1) : Colors.orange.withOpacity(0.1)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    transaction['status'] == 'selesai'
                        ? 'Selesai'
                        : (transaction['status'] == 'dibatalkan' ? 'Dibatalkan' : 'Pending'),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: transaction['status'] == 'selesai'
                          ? Colors.green
                          : (transaction['status'] == 'dibatalkan' ? Colors.red : Colors.orange),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, -2))],
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
