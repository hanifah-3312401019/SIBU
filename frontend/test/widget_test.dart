import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/pembeli/produk_pembeli.dart';

void main() {
  testWidgets('Halaman produk pembeli harus ditampilkan', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ProdukPembeli(),
      ),
    );
    
    // Cek apakah ada text "Ani Butik Syar'i"
    expect(find.text('Ani Butik Syar\'i'), findsOneWidget);
  });
}
