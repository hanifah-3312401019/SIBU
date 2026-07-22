import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Produk Helper Tests', () {
    // Test: Format harga Rupiah
    test('Format harga 387000 menjadi Rp 387.000', () {
      int price = 387000;
      String formatted = 'Rp ${price.toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
        (match) => '${match[1]}.',
      )}';
      
      expect(formatted, 'Rp 387.000');
    });

    // Test: Format harga 0
    test('Format harga 0 menjadi Rp 0', () {
      int price = 0;
      String formatted = 'Rp ${price.toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
        (match) => '${match[1]}.',
      )}';
      
      expect(formatted, 'Rp 0');
    });

    // Test: Stok rendah
    test('Stok 5 dengan min_stok 10 harus dianggap rendah', () {
      int stock = 5;
      int minStock = 10;
      
      bool isLowStock = stock <= minStock;
      
      expect(isLowStock, true);
    });

    // Test: Stok cukup
    test('Stok 20 dengan min_stok 10 harus dianggap cukup', () {
      int stock = 20;
      int minStock = 10;
      
      bool isLowStock = stock <= minStock;
      
      expect(isLowStock, false);
    });

    // Test: Total stok dari multiple ukuran
    test('Total stok dari multiple ukuran harus dijumlahkan', () {
      List<Map<String, dynamic>> ukuranStok = [
        {'ukuran': 'M', 'stock': 10},
        {'ukuran': 'L', 'stock': 5},
        {'ukuran': 'XL', 'stock': 3},
      ];
      
      int totalStock = ukuranStok.fold(0, (sum, item) => sum + (item['stock'] as int));
      
      expect(totalStock, 18);
    });
  });
}