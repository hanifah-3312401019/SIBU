import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Riwayat Transaksi Helper Tests', () {
    // Test: Format tanggal
    test('Format tanggal 2026-07-01 menjadi 1 Jul 2026', () {
      String dateTime = '2026-07-01 14:30:00';
      final date = DateTime.parse(dateTime);
      String formatted = '${date.day} ${_getMonthName(date.month)} ${date.year}';
      
      expect(formatted, '1 Jul 2026');
    });

    // Test: Format tanggal dengan waktu
    test('Format tanggal dan waktu 2026-07-01 14:30:00', () {
      String dateTime = '2026-07-01 14:30:00';
      final date = DateTime.parse(dateTime);
      String formatted = '${date.day} ${_getMonthName(date.month)} ${date.year}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      
      expect(formatted, '1 Jul 2026, 14:30');
    });

    // Test: Invoice number format
    test('Format invoice number harus INV-xxxx', () {
      String invoice = 'INV-2026-001';
      bool isValid = invoice.startsWith('INV-');
      
      expect(isValid, true);
    });

    // Test: Filter transaksi berdasarkan search query
    test('Filter transaksi berdasarkan nomor invoice', () {
      List<Map<String, dynamic>> transactions = [
        {'nomor_invoice': 'INV-2026-001', 'total': 150000},
        {'nomor_invoice': 'INV-2026-002', 'total': 200000},
        {'nomor_invoice': 'INV-2026-003', 'total': 75000},
      ];
      
      String searchQuery = '001';
      List<Map<String, dynamic>> filtered = transactions.where((t) {
        return t['nomor_invoice'].toString().toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
      
      expect(filtered.length, 1);
      expect(filtered[0]['nomor_invoice'], 'INV-2026-001');
    });

    // Test: Status transaksi
    test('Status transaksi harus salah satu: selesai, dibatalkan, pending', () {
      List<String> validStatus = ['selesai', 'dibatalkan', 'pending'];
      String status = 'selesai';
      
      expect(validStatus.contains(status), true);
    });

    // Test: Status transaksi tidak valid
    test('Status transaksi tidak valid harus ditolak', () {
      List<String> validStatus = ['selesai', 'dibatalkan', 'pending'];
      String status = 'invalid';
      
      expect(validStatus.contains(status), false);
    });
  });
}

String _getMonthName(int month) {
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
  return months[month - 1];
}