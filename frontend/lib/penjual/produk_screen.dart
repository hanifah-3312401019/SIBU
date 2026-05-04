// lib/penjual/produk_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/sidebar_penjual.dart';
import 'beranda_screen.dart';
import 'tambah_produk_screen.dart';
import 'edit_produk_screen.dart';

class ProdukScreen extends StatefulWidget {
  final String userName;
  final String userEmail;

  const ProdukScreen({
    super.key,
    required this.userName,
    required this.userEmail,
  });

  @override
  State<ProdukScreen> createState() => _ProdukScreenState();
}

class _ProdukScreenState extends State<ProdukScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 1;
  final TextEditingController _searchController = TextEditingController();
  
  // Filter kategori
  String _selectedCategory = 'Semua';
  final List<String> _categories = ['Semua', 'Abaya', 'Gamis', 'Baju Kurung', 'Khimar', 'Bergo'];

  // Data produk dengan gambar
  final List<Map<String, dynamic>> _products = [
    {
      'id': 1,
      'name': 'Abaya Cokelat Elegan',
      'price': 385000,
      'stock': 15,
      'category': 'Abaya',
      'isLowStock': false,
      'imageAsset': 'assets/images/abaya_cokelat.jpg', // Simpan path string
      'imageIcon': Icons.shopping_bag_outlined, // Fallback icon
    },
    {
      'id': 2,
      'name': 'Gamis Ceruty Payet',
      'price': 295000,
      'stock': 5,
      'category': 'Gamis',
      'isLowStock': true,
      'imageAsset': 'assets/images/gamisceruty.jpg',
      'imageIcon': Icons.shopping_bag_outlined,
    },
    {
      'id': 3,
      'name': 'Baju Kurung Melayu',
      'price': 355000,
      'stock': 7,
      'category': 'Baju Kurung',
      'isLowStock': true,
      'imageAsset': 'assets/images/bajukurung.jpg',
      'imageIcon': Icons.shopping_bag_outlined,
    },
    {
      'id': 4,
      'name': 'Khimar Saudi',
      'price': 175000,
      'stock': 20,
      'category': 'Khimar',
      'isLowStock': false,
      'imageAsset': 'assets/images/khimarsaudi.jpg',
      'imageIcon': Icons.shopping_bag_outlined,
    },
    {
      'id': 5,
      'name': 'Bergo Hamidah',
      'price': 45000,
      'stock': 8,
      'category': 'Bergo',
      'isLowStock': true,
      'imageAsset': 'assets/images/bergohamidah.jpg',
      'imageIcon': Icons.shopping_bag_outlined,
    },
    {
      'id': 6,
      'name': 'Abaya Putih Premium',
      'price': 425000,
      'stock': 12,
      'category': 'Abaya',
      'isLowStock': false,
      'imageAsset': 'assets/images/abayaputih.jpg',
      'imageIcon': Icons.shopping_bag_outlined,
    },
    {
      'id': 7,
      'name': 'Gamis Brukat',
      'price': 450000,
      'stock': 3,
      'category': 'Gamis',
      'isLowStock': true,
      'imageAsset': 'assets/images/gamisbrukat.jpg',
      'imageIcon': Icons.shopping_bag_outlined,
    },
    {
      'id': 8,
      'name': 'Baju Kurung Haera',
      'price': 389000,
      'stock': 10,
      'category': 'Baju Kurung',
      'isLowStock': false,
      'imageAsset': 'assets/images/bajukurunghaera.jpg',
      'imageIcon': Icons.shopping_bag_outlined,
    },
  ];

  List<Map<String, dynamic>> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    _filteredProducts = _products;
  }

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

void _navigateToTambahProduk() {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => TambahProdukScreen(
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
        break;
      case 2:
      case 3:
        break;
    }
  }

  void _onBottomNavTapped(int index) {
    switch (index) {
      case 0:
        _navigateToBeranda();
        break;
      case 1:
        break;
      case 2:
        break;
    }
  }

  void _filterProducts(String query) {
    setState(() {
      if (query.isEmpty && _selectedCategory == 'Semua') {
        _filteredProducts = _products;
      } else {
        _filteredProducts = _products.where((product) {
          final matchesSearch = query.isEmpty ||
              product['name'].toLowerCase().contains(query.toLowerCase()) ||
              product['category'].toLowerCase().contains(query.toLowerCase());
          final matchesCategory = _selectedCategory == 'Semua' ||
              product['category'] == _selectedCategory;
          return matchesSearch && matchesCategory;
        }).toList();
      }
    });
  }

  void _filterByCategory(String category) {
    setState(() {
      _selectedCategory = category;
      _filterProducts(_searchController.text);
    });
    Navigator.pop(context);
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filter Kategori',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF803033),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 12,
                children: _categories.map((category) {
                  final isSelected = _selectedCategory == category;
                  return FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      _filterByCategory(category);
                    },
                    backgroundColor: Colors.grey.shade100,
                    selectedColor: const Color(0xFF803033).withOpacity(0.2),
                    labelStyle: GoogleFonts.plusJakartaSans(
                      color: isSelected ? const Color(0xFF803033) : Colors.grey.shade700,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  String formatPrice(int price) {
    return 'Rp ${price.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}';
  }

  void _editProduct(Map<String, dynamic> product) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => EditProdukScreen(
        userName: widget.userName,
        userEmail: widget.userEmail,
        produk: product,
      ),
    ),
  );
}


void _deleteProduct(Map<String, dynamic> product) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85, // Lebar dialog
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon Hapus / Peringatan
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
            
            // Judul
            Text(
              'Hapus Produk?',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF803033),
              ),
            ),
            const SizedBox(height: 12),
            
            // Pesan
            Text(
              'Apakah Anda yakin ingin menghapus produk ${product['name']}?',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),
            
            // Tombol Batal dan Ya, Hapus
            Row(
              children: [
                // Tombol Batal
                Expanded(
                  child: SizedBox(
                    height: 48, // Tinggi
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF803033),
                        side: const BorderSide(color: Color(0xFFD8A5A8), width: 1.5),
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
                ),
                const SizedBox(width: 12),
                
                // Tombol Ya, Hapus
                Expanded(
                  child: SizedBox(
                    height: 48, // Tinggi
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _products.remove(product);
                          _filterProducts(_searchController.text);
                        });
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${product['name']} telah dihapus'),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
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
                ),
              ],
            ),
          ],
        ),
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
              children: [
                // Header
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

                // Title dan Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Produk',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_filteredProducts.length} produk dalam katalog',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Search Bar & Filter Button
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5ECEA),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white, width: 1),
                              ),
                              child: TextField(
                                controller: _searchController,
                                onChanged: _filterProducts,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Cari produk...',
                                  hintStyle: GoogleFonts.plusJakartaSans(
                                    color: Colors.grey.shade500,
                                    fontSize: 14,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.search,
                                    color: Colors.grey.shade500,
                                    size: 22,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFF5ECEA),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: _showFilterDialog,
                            child: Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5ECEA),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white, width: 1),
                              ),
                              child: Icon(
                                Icons.filter_list,
                                color: const Color(0xFF803033),
                                size: 22,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Grid Produk
                Expanded(
                  child: _filteredProducts.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inventory_2_outlined,
                                size: 48,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Tidak ada produk',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        )
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            int crossAxisCount = 2;
                            if (constraints.maxWidth > 800) {
                              crossAxisCount = 3;
                            }
                            if (constraints.maxWidth > 1100) {
                              crossAxisCount = 4;
                            }
                            
                            return GridView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 0.65,
                              ),
                              itemCount: _filteredProducts.length,
                              itemBuilder: (context, index) {
                                final product = _filteredProducts[index];
                                return _buildProductCard(product);
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToTambahProduk,
        backgroundColor: const Color(0xFF803033),
        elevation: 0,
        mini: true,
        child: const Icon(Icons.add, color: Colors.white, size: 24),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildProductImage(Map<String, dynamic> product) {
  final String? imageAsset = product['imageAsset'];

  return ClipRRect(
    borderRadius: const BorderRadius.only(
      topLeft: Radius.circular(15),
      topRight: Radius.circular(15),
    ),
    child: imageAsset != null && imageAsset.isNotEmpty
        ? Image.asset(
            imageAsset,
            width: double.infinity,
            height: 120,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 120,
                width: double.infinity,
                color: const Color(0xFFF5ECEA),
                child: Icon(
                  product['imageIcon'],
                  color: const Color(0xFF803033).withOpacity(0.4),
                  size: 50,
                ),
              );
            },
          )
        : Container(
            height: 120,
            width: double.infinity,
            color: const Color(0xFFF5ECEA),
            child: Icon(
              product['imageIcon'],
              color: const Color(0xFF803033).withOpacity(0.4),
              size: 50,
            ),
          ),
  );
}

  Widget _buildProductCard(Map<String, dynamic> product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFD8A5A8),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Gambar Produk (menggunakan fungsi terpisah)
          _buildProductImage(product),
          
          // Info Produk
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    product['name'],
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatPrice(product['price']),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF803033),
                    ),
                  ),
                  const SizedBox(height: 6),
                  
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 10,
                        color: product['isLowStock'] ? Colors.orange : Colors.grey.shade500,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        'Stok: ${product['stock']}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          color: product['isLowStock'] ? Colors.orange : Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (product['isLowStock']) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF3E0),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Stok rendah',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 7,
                              color: const Color(0xFFFFB74D),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  
                  const Spacer(),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () => _editProduct(product),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5ECEA),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.edit_outlined,
                            color: Color(0xFF803033),
                            size: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => _deleteProduct(product),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5ECEA),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                            size: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}