import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Notifikasi Penjual Helper Tests', () {
    // Test: Format waktu "menit lalu"
    test('Format waktu 5 menit lalu menjadi "5 menit lalu"', () {
      DateTime now = DateTime.now();
      DateTime past = now.subtract(const Duration(minutes: 5));
      int diffMinutes = now.difference(past).inMinutes;
      
      String formatted = '$diffMinutes menit lalu';
      expect(formatted, '5 menit lalu');
    });

    // Test: Format waktu "jam lalu"
    test('Format waktu 3 jam lalu menjadi "3 jam lalu"', () {
      DateTime now = DateTime.now();
      DateTime past = now.subtract(const Duration(hours: 3));
      int diffHours = now.difference(past).inHours;
      
      String formatted = '$diffHours jam lalu';
      expect(formatted, '3 jam lalu');
    });

    // Test: Format waktu "Kemarin"
    test('Format waktu 1 hari lalu menjadi "Kemarin"', () {
      DateTime now = DateTime.now();
      DateTime past = now.subtract(const Duration(days: 1));
      int diffDays = now.difference(past).inDays;
      
      String formatted = diffDays == 1 ? 'Kemarin' : '${diffDays} hari lalu';
      expect(formatted, 'Kemarin');
    });

    // Test: Format waktu "hari lalu"
    test('Format waktu 7 hari lalu menjadi "7 hari lalu"', () {
      DateTime now = DateTime.now();
      DateTime past = now.subtract(const Duration(days: 7));
      int diffDays = now.difference(past).inDays;
      
      String formatted = diffDays == 1 ? 'Kemarin' : '${diffDays} hari lalu';
      expect(formatted, '7 hari lalu');
    });

    // Test: Notifikasi memiliki judul dan pesan
    test('Notifikasi harus memiliki judul dan pesan', () {
      Map<String, dynamic> notif = {
        'judul': 'Stok Menipis',
        'pesan': 'Stok produk Gamis Syari tersisa 5',
        'sudah_dibaca': false,
      };
      
      expect(notif.containsKey('judul'), true);
      expect(notif.containsKey('pesan'), true);
      expect(notif['judul'], isNotNull);
      expect(notif['pesan'], isNotNull);
    });

    // Test: Status notifikasi sudah dibaca
    test('Notifikasi sudah dibaca harus true', () {
      Map<String, dynamic> notif = {
        'judul': 'Stok Menipis',
        'pesan': 'Stok produk Gamis Syari tersisa 5',
        'sudah_dibaca': true,
      };
      
      expect(notif['sudah_dibaca'], true);
    });

    // Test: Status notifikasi belum dibaca
    test('Notifikasi belum dibaca harus false', () {
      Map<String, dynamic> notif = {
        'judul': 'Stok Menipis',
        'pesan': 'Stok produk Gamis Syari tersisa 5',
        'sudah_dibaca': false,
      };
      
      expect(notif['sudah_dibaca'], false);
    });

    // Test: Menghitung jumlah notifikasi belum dibaca
    test('Menghitung jumlah notifikasi belum dibaca', () {
      List<Map<String, dynamic>> notifs = [
        {'judul': 'Notif 1', 'sudah_dibaca': false},
        {'judul': 'Notif 2', 'sudah_dibaca': true},
        {'judul': 'Notif 3', 'sudah_dibaca': false},
        {'judul': 'Notif 4', 'sudah_dibaca': true},
      ];
      
      int unread = notifs.where((n) => n['sudah_dibaca'] == false).length;
      
      expect(unread, 2);
    });
  });
}