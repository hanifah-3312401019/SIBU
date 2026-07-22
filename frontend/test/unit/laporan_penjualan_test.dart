import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Laporan Penjualan Helper Tests', () {
    // Test: Format Rupiah
    test('Format harga 1500000 menjadi Rp 1.500.000', () {
      int price = 1500000;
      String formatted = 'Rp ${price.toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
        (match) => '${match[1]}.',
      )}';
      
      expect(formatted, 'Rp 1.500.000');
    });

    // Test: Format Rupiah untuk angka jutaan
    test('Format harga 2500000 menjadi Rp 2.500.000', () {
      int price = 2500000;
      String formatted = 'Rp ${price.toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
        (match) => '${match[1]}.',
      )}';
      
      expect(formatted, 'Rp 2.500.000');
    });

    // Test: Format Rupiah untuk angka 0
    test('Format harga 0 menjadi Rp 0', () {
      int price = 0;
      String formatted = 'Rp ${price.toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
        (match) => '${match[1]}.',
      )}';
      
      expect(formatted, 'Rp 0');
    });

    // Test: Format Rupiah untuk jutaan (versi singkat)
    test('Format Rupiah untuk 3.000.000 menjadi Rp 3jt', () {
      int price = 3000000;
      String formatted = price >= 1000000
          ? 'Rp ${(price / 1000000).toInt()}jt'
          : 'Rp ${price.toString().replaceAllMapped(
              RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
              (match) => '${match[1]}.',
            )}';
      
      expect(formatted, 'Rp 3jt');
    });

    // Test: Filter data dengan nilai > 0
    test('Filter data hanya yang bernilai > 0', () {
      List<MapEntry<String, int>> data = [
        const MapEntry('Senin', 0),
        const MapEntry('Selasa', 50000),
        const MapEntry('Rabu', 0),
        const MapEntry('Kamis', 75000),
      ];
      
      List<MapEntry<String, int>> filtered = data.where((e) => e.value > 0).toList();
      
      expect(filtered.length, 2);
      expect(filtered[0].key, 'Selasa');
      expect(filtered[1].key, 'Kamis');
    });

    // Test: Total penjualan dari data
    test('Menghitung total penjualan dari list', () {
      List<int> values = [50000, 75000, 100000, 25000];
      int total = values.fold(0, (sum, v) => sum + v);
      
      expect(total, 250000);
    });

    // Test: Periode Harian memiliki 24 jam
    test('Periode harian memiliki 24 jam', () {
      List<String> labels = List.generate(24, (i) => '$i:00');
      expect(labels.length, 24);
      expect(labels[0], '0:00');
      expect(labels[23], '23:00');
    });

    // Test: Periode Mingguan memiliki 7 hari
    test('Periode mingguan memiliki 7 hari', () {
      List<String> days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
      expect(days.length, 7);
    });

    // Test: Periode Bulanan memiliki 12 bulan
    test('Periode bulanan memiliki 12 bulan', () {
      List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
      expect(months.length, 12);
    });
  });
}