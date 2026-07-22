import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/auth/login_screen.dart';

void main() {
  group('Login Validation Tests', () {
    // Test: Email kosong
    test('Email kosong harus menampilkan error', () {
      const email = '';
      const password = 'admin123';
      
      bool isValid = email.isNotEmpty && password.isNotEmpty;
      
      expect(isValid, false);
    });

    // Test: Password kosong
    test('Password kosong harus menampilkan error', () {
      const email = 'admin@butik.com';
      const password = '';
      
      bool isValid = email.isNotEmpty && password.isNotEmpty;
      
      expect(isValid, false);
    });

    // Test: Email dan password valid
    test('Email dan password valid harus lolos validasi', () {
      const email = 'admin@butik.com';
      const password = 'admin123';
      
      bool isValid = email.isNotEmpty && password.isNotEmpty;
      
      expect(isValid, true);
    });

    // Test: Format email valid
    test('Format email harus valid', () {
      const email = 'admin@butik.com';
      
      bool isValidEmail = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
      
      expect(isValidEmail, true);
    });

    // Test: Format email tidak valid
    test('Format email tidak valid harus gagal', () {
      const email = 'adminbutik.com';
      
      bool isValidEmail = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
      
      expect(isValidEmail, false);
    });
  });
}
