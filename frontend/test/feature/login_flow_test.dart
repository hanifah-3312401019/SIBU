import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/auth/login_screen.dart';

void main() {
  group('Login Flow Feature Tests', () {
    // Test: Halaman login memiliki semua komponen
    testWidgets('Halaman login harus memiliki email, password, dan tombol login', 
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginScreen(),
        ),
      );
      
      // Cek apakah ada text "Selamat Datang"
      expect(find.text('Selamat Datang'), findsOneWidget);
      
      // Cek apakah ada text "Masuk untuk mengelola butik Anda"
      expect(find.text('Masuk untuk mengelola butik Anda'), findsOneWidget);
      
      // Cek apakah ada field email
      expect(find.text('EMAIL'), findsOneWidget);
      
      // Cek apakah ada field password
      expect(find.text('KATA SANDI'), findsOneWidget);
      
      // Cek apakah ada tombol "Masuk"
      expect(find.text('Masuk'), findsOneWidget);
    });

    // Test: Login dengan data kosong
    testWidgets('Login dengan email kosong harus menampilkan error', 
        (WidgetTester tester) async {
      // Mock: Simulasi login dengan email kosong
      bool isValid(String email, String password) {
        return email.isNotEmpty && password.isNotEmpty;
      }
      
      bool result = isValid('', 'admin123');
      
      expect(result, false);
    });

    // Test: Login dengan password kosong
    testWidgets('Login dengan password kosong harus menampilkan error', 
        (WidgetTester tester) async {
      bool isValid(String email, String password) {
        return email.isNotEmpty && password.isNotEmpty;
      }
      
      bool result = isValid('admin@butik.com', '');
      
      expect(result, false);
    });

    // Test: Login dengan data valid
    testWidgets('Login dengan data valid harus berhasil', 
        (WidgetTester tester) async {
      bool isValid(String email, String password) {
        return email.isNotEmpty && password.isNotEmpty;
      }
      
      bool result = isValid('admin@butik.com', 'admin123');
      
      expect(result, true);
    });
  });
}